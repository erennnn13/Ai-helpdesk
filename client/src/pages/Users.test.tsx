import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { Users } from "./Users";
import { renderWithProviders } from "../utils/test-utils";

// Mock the AuthContext
const mockSession = {
  user: {
    id: "admin-id",
    name: "Admin User",
    email: "admin@example.com",
    role: "ADMIN"
  }
};

vi.mock("../context/AuthContext", () => ({
  useAuth: () => ({
    session: mockSession,
    isPending: false,
  })
}));

// Mock the API service
vi.mock("../services/api", () => ({
  api: {
    get: vi.fn(),
    post: vi.fn(),
    delete: vi.fn(),
  }
}));

import { api } from "../services/api";

describe("Users Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Use `as any` or cast depending on your TS configuration for mocked functions
  });

  it("renders the loading skeleton initially", () => {
    (api.get as any).mockImplementation(() => new Promise(() => {})); // Never resolves
    
    renderWithProviders(<Users />);
    expect(screen.getByText("User Management")).toBeInTheDocument();
    
    // We expect the skeleton components to be rendered (you might need to check for a specific test-id if skeleton doesn't have text, but our table body renders them)
    // Here we can just check if the table headers are there.
    expect(screen.getByRole("columnheader", { name: "Name" })).toBeInTheDocument();
  });

  it("fetches and displays users", async () => {
    const mockUsers = [
      { id: "1", name: "John Doe", email: "john@example.com", role: "AGENT", createdAt: new Date().toISOString() },
      { id: "admin-id", name: "Admin User", email: "admin@example.com", role: "ADMIN", createdAt: new Date().toISOString() }
    ];
    
    (api.get as any).mockResolvedValue({ users: mockUsers });

    renderWithProviders(<Users />);

    await waitFor(() => {
      expect(screen.getByText("John Doe")).toBeInTheDocument();
    });

    expect(screen.getByText("john@example.com")).toBeInTheDocument();
    expect(screen.getByText("Admin User")).toBeInTheDocument();
    expect(screen.getByText("admin@example.com")).toBeInTheDocument();
  });

  it("opens the create user dialog when 'Add User' is clicked", async () => {
    (api.get as any).mockResolvedValue({ users: [] });
    
    renderWithProviders(<Users />);
    
    const user = userEvent.setup();
    const addButton = await screen.findByText(/Add User/i);
    
    await user.click(addButton);
    
    expect(await screen.findByText("Create New User")).toBeInTheDocument();
    expect(screen.getByLabelText(/Name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Password/i)).toBeInTheDocument();
  });

  it("submits the new user form and calls api.post", async () => {
    (api.get as any).mockResolvedValue({ users: [] });
    (api.post as any).mockResolvedValue({ user: { id: "new" } });
    
    renderWithProviders(<Users />);
    
    const user = userEvent.setup();
    const addButton = await screen.findByText(/Add User/i);
    await user.click(addButton);
    
    // Fill out the form
    await user.type(screen.getByLabelText(/Name/i), "Jane Doe");
    await user.type(screen.getByLabelText(/Email/i), "jane@example.com");
    await user.type(screen.getByLabelText(/Password/i), "password123");
    
    // Submit
    const submitBtn = screen.getByRole("button", { name: /Create User/i });
    await user.click(submitBtn);
    
    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith("/users", expect.objectContaining({
        name: "Jane Doe",
        email: "jane@example.com",
        password: "password123",
        role: "AGENT" // default role
      }));
    });
  });

  it("calls api.delete when delete button is clicked", async () => {
    const mockUsers = [
      { id: "1", name: "John Doe", email: "john@example.com", role: "AGENT", createdAt: new Date().toISOString() },
    ];
    (api.get as any).mockResolvedValue({ users: mockUsers });
    (api.delete as any).mockResolvedValue({});
    
    renderWithProviders(<Users />);

    const deleteBtn = await screen.findByRole("button", { name: /Delete/i });
    
    const user = userEvent.setup();
    await user.click(deleteBtn);

    // Find and click the confirm button in the AlertDialog
    const confirmBtn = await screen.findByRole("button", { name: /Delete User/i });
    await user.click(confirmBtn);

    await waitFor(() => {
      expect(api.delete).toHaveBeenCalledWith("/users/1");
    });
  });

  it("hides the dialog when clicking outside of it", async () => {
    (api.get as any).mockResolvedValue({ users: [] });
    
    renderWithProviders(<Users />);
    
    const user = userEvent.setup();
    const addButton = await screen.findByText(/Add User/i);
    
    await user.click(addButton);
    expect(await screen.findByText("Create New User")).toBeInTheDocument();
    
    // Click outside the dialog
    await user.click(document.body);
    
    await waitFor(() => {
      expect(screen.queryByText("Create New User")).not.toBeInTheDocument();
    });
  });

  it("hides the dialog when Esc is pressed", async () => {
    (api.get as any).mockResolvedValue({ users: [] });
    
    renderWithProviders(<Users />);
    
    const user = userEvent.setup();
    const addButton = await screen.findByText(/Add User/i);
    
    await user.click(addButton);
    expect(await screen.findByText("Create New User")).toBeInTheDocument();
    
    // Press Escape key
    await user.keyboard("{Escape}");
    
    await waitFor(() => {
      expect(screen.queryByText("Create New User")).not.toBeInTheDocument();
    });
  });
});
