import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import App from './App';

beforeEach(() => {
  global.fetch = jest.fn();
  if (!global.crypto) {
    global.crypto = {};
  }
  global.crypto.randomUUID = jest.fn(() => 'test-uuid');
});

afterEach(() => {
  jest.resetAllMocks();
});

const jpegFile = () => new File([new Uint8Array([0xff, 0xd8, 0xff])], 'person.jpg', { type: 'image/jpeg' });

test('renders CloudPose heading', () => {
  render(<App />);
  const heading = screen.getByRole('heading', { name: /CloudPose/i });
  expect(heading).toBeInTheDocument();
});

test('hides action buttons until an image is selected', () => {
  render(<App />);
  expect(screen.queryByRole('button', { name: /Get Keypoints/i })).not.toBeInTheDocument();
  expect(screen.queryByRole('button', { name: /Get Annotated Image/i })).not.toBeInTheDocument();
});

test('shows action buttons after image upload', async () => {
  render(<App />);
  const input = document.querySelector('#image-upload');
  await userEvent.upload(input, jpegFile());
  expect(await screen.findByRole('button', { name: /Get Keypoints/i })).toBeInTheDocument();
  expect(screen.getByRole('button', { name: /Get Annotated Image/i })).toBeInTheDocument();
});

test('posts keypoints to the local API and renders the count', async () => {
  global.fetch.mockResolvedValue({
    ok: true,
    json: async () => ({
      id: 'test-uuid',
      count: 2,
      boxes: [],
      keypoints: [],
      processing_time: '0.12s',
      file_name: 'person.jpg',
    }),
  });

  render(<App />);
  await userEvent.upload(document.querySelector('#image-upload'), jpegFile());
  await userEvent.click(await screen.findByRole('button', { name: /Get Keypoints/i }));

  await waitFor(() => {
    expect(screen.getByText('2')).toBeInTheDocument();
  });
  expect(global.fetch).toHaveBeenCalledWith(
    'http://localhost:60000/api/pose',
    expect.objectContaining({ method: 'POST' })
  );
  expect(screen.getByText('0.12s')).toBeInTheDocument();
});

test('shows an error when the pose request fails', async () => {
  global.fetch.mockResolvedValue({
    ok: false,
    status: 500,
    json: async () => ({ error: 'Image processing failed' }),
  });

  render(<App />);
  await userEvent.upload(document.querySelector('#image-upload'), jpegFile());
  await userEvent.click(await screen.findByRole('button', { name: /Get Keypoints/i }));

  expect(await screen.findByText(/Image processing failed/i)).toBeInTheDocument();
});
