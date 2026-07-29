import { screen, waitFor } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import DashboardPage from "./DashboardPage";
import { renderWithProviders } from "../utils/test-utils";
import { api } from "../services/api";

vi.mock("../services/api", () => ({
  api: {
    get: vi.fn(),
  }
}));

const mockRecentTickets = [
  {
    id: 1,
    subject: "Dashboard Test Ticket",
    status: "OPEN",
    category: "GENERAL",
    customerName: "Dash",
    customerEmail: "dash@example.com",
    createdAt: new Date().toISOString(),
  }
];

describe("DashboardPage Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("displays all stat cards", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/tickets/stats")) {
        return Promise.resolve({ stats: { open: 40, resolved: 30, closed: 30, total: 100, aiResolved: 15 } });
      }
      if (url.includes("/tickets")) {
        return Promise.resolve({ tickets: [] });
      }
      return Promise.resolve({});
    });
    
    renderWithProviders(<DashboardPage />);
    
    await waitFor(() => {
      expect(screen.getAllByText(/Total/i).length).toBeGreaterThan(0);
      expect(screen.getAllByText("100").length).toBeGreaterThan(0);
      expect(screen.getAllByText("Open").length).toBeGreaterThan(0);
      expect(screen.getAllByText("40").length).toBeGreaterThan(0);
      expect(screen.getAllByText("Resolved by AI").length).toBeGreaterThan(0);
    });
  });

  it("displays Recent Tickets section", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/tickets/stats")) return Promise.resolve({ stats: { open: 1, resolved: 0, closed: 0, total: 1 } });
      if (url.includes("limit=5")) return Promise.resolve({ tickets: mockRecentTickets });
      return Promise.resolve({});
    });
    
    renderWithProviders(<DashboardPage />);
    
    await waitFor(() => {
      expect(screen.getByText("Dashboard Test Ticket")).toBeInTheDocument();
      expect(screen.getByText("Dash · dash@example.com")).toBeInTheDocument();
    });
  });
});
