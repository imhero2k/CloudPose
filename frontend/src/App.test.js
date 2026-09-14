import { render, screen } from '@testing-library/react';
import App from './App';

test('renders CloudPose heading', () => {
  render(<App />);
  const heading = screen.getByRole('heading', { name: /CloudPose/i });
  expect(heading).toBeInTheDocument();
});
