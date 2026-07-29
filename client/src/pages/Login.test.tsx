import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { Login } from "./Login";
import { renderWithProviders } from "../utils/test-utils";
import { authClient } from "../lib/auth-client";
import { useNavigate } from "react-router";

// Mock the AuthContext
vi.mock("../context/AuthContext", () => ({
  useAuth: () => ({
    session: null,
    isPending: false,
  })
}));

// Mock better-auth client
vi.mock("../lib/auth-client", () => ({
  authClient: {
    signIn: {
      email: vi.fn(),
    }
  }
}));

// Mock react-router
vi.mock("react-router", async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...(actual as any),
    useNavigate: vi.fn(),
  };
});

describe("Login Component", () => {
  const mockNavigate = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    (useNavigate as any).mockReturnValue(mockNavigate);
  });

  it("renders login form correctly", () => {
    renderWithProviders(<Login />);
    
    expect(screen.getByPlaceholderText("agent@example.com")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("••••••••")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Sign in/i })).toBeInTheDocument();
  });

  it("shows validation errors for empty form submission", async () => {
    renderWithProviders(<Login />);
    const user = userEvent.setup();
    
    const submitBtn = screen.getByRole("button", { name: /Sign in/i });
    await user.click(submitBtn);

    // Expect Zod schema validation errors
    await waitFor(() => {
      expect(screen.getByText("Email is required")).toBeInTheDocument();
      expect(screen.getByText("Password is required")).toBeInTheDocument();
    });

    expect(authClient.signIn.email).not.toHaveBeenCalled();
  });

  it("shows error for wrong credentials", async () => {
    (authClient.signIn.email as any).mockResolvedValue({
      error: { message: "Invalid email or password" },
    });

    renderWithProviders(<Login />);
    const user = userEvent.setup();
    
    await user.type(screen.getByPlaceholderText("agent@example.com"), "wrong@example.com");
    await user.type(screen.getByPlaceholderText("••••••••"), "wrongpassword");
    
    const submitBtn = screen.getByRole("button", { name: /Sign in/i });
    await user.click(submitBtn);

    await waitFor(() => {
      expect(screen.getByText("Invalid email or password")).toBeInTheDocument();
    });
  });

  it("navigates to dashboard on successful login", async () => {
    (authClient.signIn.email as any).mockResolvedValue({
      error: null,
      data: { user: { id: "1" } },
    });

    renderWithProviders(<Login />);
    const user = userEvent.setup();
    
    await user.type(screen.getByPlaceholderText("agent@example.com"), "admin@example.com");
    await user.type(screen.getByPlaceholderText("••••••••"), "password123");
    
    const submitBtn = screen.getByRole("button", { name: /Sign in/i });
    await user.click(submitBtn);

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith("/");
    });
  });
});
