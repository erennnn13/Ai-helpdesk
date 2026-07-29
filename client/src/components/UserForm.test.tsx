import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { UserForm } from "./UserForm";
import { renderWithProviders } from "../utils/test-utils";
import { api } from "../services/api";

// Mock the API service
vi.mock("../services/api", () => ({
  api: {
    post: vi.fn(),
    patch: vi.fn(),
  }
}));

describe("UserForm Component", () => {
  const mockOnSuccess = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders all form fields correctly", () => {
    renderWithProviders(<UserForm onSuccess={mockOnSuccess} />);
    
    expect(screen.getByLabelText(/Name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Password/i)).toBeInTheDocument();
    expect(screen.getByText(/Role/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Create User/i })).toBeInTheDocument();
  });

  it("shows validation errors for empty required fields on submit", async () => {
    renderWithProviders(<UserForm onSuccess={mockOnSuccess} />);
    const user = userEvent.setup();
    
    const submitBtn = screen.getByRole("button", { name: /Create User/i });
    await user.click(submitBtn);

    // Assuming the schema requires these, we should see error messages
    await waitFor(() => {
      // Check that at least one error message is displayed
      const errorMessages = document.querySelectorAll('.text-destructive');
      expect(errorMessages.length).toBeGreaterThan(0);
    });
    
    expect(api.post).not.toHaveBeenCalled();
  });

  it("shows validation error for invalid email format", async () => {
    renderWithProviders(<UserForm onSuccess={mockOnSuccess} />);
    const user = userEvent.setup();
    
    await user.type(screen.getByLabelText(/Name/i), "John Doe");
    await user.type(screen.getByLabelText(/Email/i), "invalid-email");
    await user.type(screen.getByLabelText(/Password/i), "password123");
    
    const submitBtn = screen.getByRole("button", { name: /Create User/i });
    await user.click(submitBtn);

    await waitFor(() => {
      expect(screen.getByText(/Please enter a valid email id/i)).toBeInTheDocument();
    });
    
    expect(api.post).not.toHaveBeenCalled();
  });

  it("submits successfully with valid data and calls onSuccess", async () => {
    (api.post as any).mockResolvedValue({ data: { id: "new-user" } });
    
    renderWithProviders(<UserForm onSuccess={mockOnSuccess} />);
    const user = userEvent.setup();
    
    await user.type(screen.getByLabelText(/Name/i), "John Doe");
    await user.type(screen.getByLabelText(/Email/i), "john@example.com");
    await user.type(screen.getByLabelText(/Password/i), "password123");
    
    const submitBtn = screen.getByRole("button", { name: /Create User/i });
    await user.click(submitBtn);

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith("/users", {
        name: "John Doe",
        email: "john@example.com",
        password: "password123",
        role: "AGENT", // default role
      });
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });

  it("handles server error 409 (Email already exists)", async () => {
    (api.post as any).mockRejectedValue({ status: 409 });
    
    renderWithProviders(<UserForm onSuccess={mockOnSuccess} />);
    const user = userEvent.setup();
    
    await user.type(screen.getByLabelText(/Name/i), "Jane Doe");
    await user.type(screen.getByLabelText(/Email/i), "existing@example.com");
    await user.type(screen.getByLabelText(/Password/i), "password123");
    
    const submitBtn = screen.getByRole("button", { name: /Create User/i });
    await user.click(submitBtn);

    await waitFor(() => {
      expect(screen.getByText(/Email already exists/i)).toBeInTheDocument();
    });
    
    expect(mockOnSuccess).not.toHaveBeenCalled();
  });
});
