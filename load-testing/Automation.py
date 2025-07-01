import subprocess
import time
import csv
import os

# === Configuration ===
# SSH settings for remote hosts
HOSTS = {
    'Master': {
        'ssh_user': 'ubuntu',
        'ssh_host': '207.211.146.57',
        'ssh_key': r'C:\Users\ksara\Downloads\master.key'
    },
    'Nectar': {
        'ssh_user': 'ubuntu',
        'ssh_host': '203.101.224.184',
        'ssh_key': r'C:\Users\ksara\Downloads\nectar.key.txt'
    }
}

# Kubernetes deployment settings (on Master)
DEPLOYMENT_NAME = 'pose-estimator'
K8S_NAMESPACE = 'assignment1'

# Service URL (the target of Locust tests)
SERVICE_URL = os.getenv('SERVICE_URL', 'http://207.211.146.57:30080')

# Experiment parameters
POD_COUNTS = [8]
MAX_USERS_SEARCH = 500    # upper bound when searching
USER_STEP = 10            # increment when searching
INITIAL_SPAWN_RATE = 10   # for coarse search
VERIFY_SPAWN_RATE = 1     # for final verification
RUN_TIME = '1m'           # duration per test
LOCAL_RESULT_DIR = 'remote_results'
LOCUST_REMOTE_PATH = '~/locustfile.py'  # where locustfile.py will be placed
ASSETS_DIR = 'image'  # directory containing image assets for locustfile

# Ensure result directory exists
os.makedirs(LOCAL_RESULT_DIR, exist_ok=True)


def run_ssh(cmd, host_cfg):
    prefix = f'ssh -i "{host_cfg["ssh_key"]}" {host_cfg["ssh_user"]}@{host_cfg["ssh_host"]}'
    full_cmd = f'{prefix} "{cmd}"'
    subprocess.check_call(full_cmd, shell=True)


def scp_remote_to_local(remote_path, host_cfg, local_path):
    scp_cmd = (
        f'scp -i "{host_cfg["ssh_key"]}" '
        f'{host_cfg["ssh_user"]}@{host_cfg["ssh_host"]}:{remote_path} '
        f'{local_path}'
    )
    subprocess.check_call(scp_cmd, shell=True)


def copy_locust_assets(host_cfg):
    # Copy locustfile.py to remote
    scp_script = (
        f'scp -i "{host_cfg["ssh_key"]}" locustfile.py '
        f'{host_cfg["ssh_user"]}@{host_cfg["ssh_host"]}:{LOCUST_REMOTE_PATH}'
    )
    subprocess.check_call(scp_script, shell=True)

    # Ensure the remote image directory exists
    run_ssh(f'mkdir -p ~/{ASSETS_DIR}', host_cfg)

    # Copy contents of local image directory into remote
    scp_images = (
        f'scp -i "{host_cfg["ssh_key"]}" -r {ASSETS_DIR}/* '
        f'{host_cfg["ssh_user"]}@{host_cfg["ssh_host"]}:~/{ASSETS_DIR}/'
    )
    subprocess.check_call(scp_images, shell=True)


def scale_pods(pod_count, master_cfg):
    """
    Scale the Kubernetes deployment to the specified number of pods on the Master node.
    """
    kubeconfig = "/etc/kubernetes/admin.conf"
    scale_cmd = (
        f"sudo KUBECONFIG={kubeconfig} kubectl scale deployment {DEPLOYMENT_NAME} "
        f"--replicas={pod_count} -n {K8S_NAMESPACE}"
    )
    rollout_cmd = (
        f"sudo KUBECONFIG={kubeconfig} kubectl rollout status deployment/{DEPLOYMENT_NAME} "
        f"-n {K8S_NAMESPACE} --timeout=120s"
    )
    full_cmd = scale_cmd + " && " + rollout_cmd
    print(f"Scaling to {pod_count} pods on Master using kubeconfig {kubeconfig}...")
    try:
        run_ssh(full_cmd, master_cfg)
    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to scale pods: {e}")


def run_remote_locust(host_cfg, users, spawn_rate, client_name, pod_count):
    ts = int(time.time())
    prefix = f"/tmp/{client_name}_{pod_count}_{users}_{ts}_test"

    # Clean up old CSVs
    run_ssh(f'rm -f {prefix}_stats.csv {prefix}_failures.csv {prefix}_exceptions.csv', host_cfg)

    locust_cmd = (
        f'locust -f {LOCUST_REMOTE_PATH} --headless '
        f'--host {SERVICE_URL} --users {users} --spawn-rate {spawn_rate} '
        f'--run-time {RUN_TIME} --csv {prefix}'
    )
    print(f"Running {users} users @ {spawn_rate}/s on {client_name}... (pods={pod_count})")
    try:
        run_ssh(locust_cmd, host_cfg)
    except subprocess.CalledProcessError as e:
        print(f"Warning: Locust exited with status {e.returncode}. Fetching CSV anyway…")

    # Always fetch stats CSV
    remote_csv = f"{prefix}_stats.csv"
    local_csv = os.path.join(LOCAL_RESULT_DIR, os.path.basename(remote_csv))
    scp_remote_to_local(remote_csv, host_cfg, local_csv)

    with open(local_csv, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            name = row.get('Name')
            if name in ('Total', 'Aggregated'):
                total = int(row.get('Request Count', 0))
                fails = int(row.get('Failure Count', 0))
                success = 100.0 * (total - fails) / total if total else 0.0
                avg_rt = float(row.get('Average Response Time', 0.0))
                return success, avg_rt

    return 0.0, 0.0


def find_max_users_for_client(client_name, host_cfg, master_cfg, pod_count):
    # 1) Scale pods
    scale_pods(pod_count, master_cfg)
    # 2) Coarse stepping to find failure bracket
    low = 0
    high = None
    best_rt = 0.0
    for u in range(USER_STEP, MAX_USERS_SEARCH + USER_STEP, USER_STEP):
        success, avg_rt = run_remote_locust(host_cfg, u, INITIAL_SPAWN_RATE, client_name, pod_count)
        if success < 100.0:
            high = u
            break
        low = u
        best_rt = avg_rt
    # if never failed, return max low
    if high is None:
        return low, best_rt
    # 3) Linear search between low+1 and high-1 for precise max
    precise = low
    precise_rt = best_rt
    for u in range(low + 1, high):
        success, avg_rt = run_remote_locust(host_cfg, u, VERIFY_SPAWN_RATE, client_name, pod_count)
        if success == 100.0:
            precise = u
            precise_rt = avg_rt
        else:
            break
    return precise, precise_rt


def main():
    for name, cfg in HOSTS.items():
        print(f"Copying locust assets to {name}...")
        copy_locust_assets(cfg)

    out_csv = os.path.join(LOCAL_RESULT_DIR, 'experiment_results.csv')
    with open(out_csv, 'w', newline='') as f:
        csv.writer(f).writerow([
            'Client', 'Pods', 'Max Users', 'Avg Response Time (ms)'
        ])

    for client, cfg in HOSTS.items():
        for pods in POD_COUNTS:
            max_u, avg = find_max_users_for_client(
                client, cfg, HOSTS['Master'], pods
            )
            print(f"{client} | pods={pods} => max users={max_u}, avg rt={avg}ms")
            with open(out_csv, 'a', newline='') as f:
                csv.writer(f).writerow([client, pods, max_u, avg])

    print(f"All done; results in {out_csv}")

if __name__ == '__main__':
    main()
