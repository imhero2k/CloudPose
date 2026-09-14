import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_locustfile_and_automation_parse():
    for rel in ("load-testing/locustfile.py", "load-testing/Automation.py"):
        ast.parse((ROOT / rel).read_text(), filename=rel)


def test_locustfile_tolerates_missing_image_dir():
    text = (ROOT / "load-testing" / "locustfile.py").read_text()
    assert "os.path.isdir(IMAGE_DIR)" in text
    assert "if not encoded_images" in text
