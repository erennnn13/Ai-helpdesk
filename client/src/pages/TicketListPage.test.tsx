import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi, beforeEach } from "vitest";
import TicketListPage from "./TicketListPage";
import { renderWithProviders } from "../utils/test-utils";
import { api } from "../services/api";

// Mock the API service
vi.mock("../services/api", () => ({
  api: {
    get: vi.fn(),
  }
}));

const mockTickets = [
  {
    id: 1,
    subject: "Test Ticket 1",
    status: "OPEN",
    category: "GENERAL",
    customerName: "Alice",
    customerEmail: "alice@example.com",
    createdAt: new Date().toISOString(),
    _count: { messages: 2 }
  },
  {
    id: 2,
    subject: "Tech Issue",
    status: "RESOLVED",
    category: "TECHNICAL",
    customerName: "Bob",
    customerEmail: "bob@example.com",
    createdAt: new Date().toISOString(),
    _count: { messages: 5 }
  }
];

describe("TicketListPage Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders page heading and table headers", async () => {
    (api.get as any).mockResolvedValue({ tickets: mockTickets, pagination: { totalPages: 1 } });
    
    renderWithProviders(<TicketListPage />);
    
    expect(screen.getByText("Tickets")).toBeInTheDocument();
    
    await waitFor(() => {
      expect(screen.getByText("Test Ticket 1")).toBeInTheDocument();
    });
    
    const table = screen.getByRole("table");
    expect(within(table).getByText("Subject")).toBeInTheDocument();
    expect(within(table).getByText("Customer")).toBeInTheDocument();
    expect(within(table).getByText("Status")).toBeInTheDocument();
  });

  it("search filter updates query params and re-fetches", async () => {
    (api.get as any).mockResolvedValue({ tickets: [], pagination: { totalPages: 1 } });
    const user = userEvent.setup();
    
    renderWithProviders(<TicketListPage />);
    
    const searchInput = screen.getByPlaceholderText(/Search tickets/i);
    await user.type(searchInput, "Test query");
    
    // There is a 500ms debounce on search
    await waitFor(() => {
      expect(api.get).toHaveBeenCalledWith(expect.stringContaining("search=Test+query"));
    }, { timeout: 1000 });
  });

  it("status filter updates API call", async () => {
    (api.get as any).mockResolvedValue({ tickets: [], pagination: { totalPages: 1 } });
    const user = userEvent.setup();
    
    renderWithProviders(<TicketListPage />);
    
    // Assuming Select component displays "All Statuses" initially
    const statusSelect = await screen.findByRole("combobox", { name: /Status/i });
    await user.click(statusSelect);
    
    // Select 'Open'
    const option = await screen.findByRole("option", { name: "Open" });
    await user.click(option);
    
    await waitFor(() => {
      expect(api.get).toHaveBeenCalledWith(expect.stringContaining("status=OPEN"));
    });
  });

  it("shows empty state when no tickets found", async () => {
    (api.get as any).mockResolvedValue({ tickets: [], pagination: { totalPages: 1 } });
    
    renderWithProviders(<TicketListPage />);
    
    await waitFor(() => {
      expect(screen.getByText("No tickets found")).toBeInTheDocument();
      expect(screen.getByText("Try adjusting your search or filters to find what you're looking for.")).toBeInTheDocument();
    });
  });

  it("pagination controls only appear when there is more than 1 page", async () => {
    // 1. One page -> No pagination
    (api.get as any).mockResolvedValue({ tickets: [], pagination: { totalPages: 1, page: 1 } });
    const { unmount } = renderWithProviders(<TicketListPage />);
    
    await waitFor(() => {
      expect(screen.queryByText(/Page \d+ of \d+/)).not.toBeInTheDocument();
    });
    unmount();

    // 2. Multiple pages -> Pagination appears
    (api.get as any).mockResolvedValue({ tickets: mockTickets, pagination: { totalPages: 3, page: 1 } });
    renderWithProviders(<TicketListPage />);
    
    await waitFor(() => {
      expect(screen.getByText(/Page 1 of 3/)).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Next" })).toBeInTheDocument();
    });
  });

  it("ticket rows render gracefully when category is null", async () => {
    const nullCategoryTicket = [{ ...mockTickets[0], category: null }];
    (api.get as any).mockResolvedValue({ tickets: nullCategoryTicket, pagination: { totalPages: 1 } });
    
    renderWithProviders(<TicketListPage />);
    
    await waitFor(() => {
      expect(screen.getByText("Test Ticket 1")).toBeInTheDocument();
      // Uncategorized badge should be present
      expect(screen.getByText("Uncategorized")).toBeInTheDocument();
    });
  });

  it("agent filter updates API call with assignedToId query param", async () => {
    const mockUsers = [{ id: "user-100", name: "Agent Agent", email: "agent@example.com", role: "AGENT" }];
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: mockUsers });
      return Promise.resolve({ tickets: [], pagination: { totalPages: 1 } });
    });
    const user = userEvent.setup();
    
    renderWithProviders(<TicketListPage />);
    
    const agentSelect = await screen.findByRole("combobox", { name: /Agent Filter/i });
    await user.click(agentSelect);
    
    const option = await screen.findByRole("option", { name: "Agent Agent" });
    await user.click(option);
    
    await waitFor(() => {
      expect(api.get).toHaveBeenCalledWith(expect.stringContaining("assignedToId=user-100"));
    });
  });
});
