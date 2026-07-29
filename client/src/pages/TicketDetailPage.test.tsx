import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi, beforeEach } from "vitest";
import TicketDetailPage from "./TicketDetailPage";
import { renderWithProviders } from "../utils/test-utils";
import { api } from "../services/api";
import { Route, Routes } from "react-router";

// Mock the AuthContext
const mockSession = {
  user: {
    id: "agent-id",
    name: "Agent Smith",
    email: "agent@example.com",
    role: "AGENT",
  },
};

vi.mock("../context/AuthContext", () => ({
  useAuth: () => ({
    session: mockSession,
    isPending: false,
  }),
}));

vi.mock("../services/api", () => ({
  api: {
    get: vi.fn(),
    patch: vi.fn(),
    post: vi.fn(),
  },
}));

const mockTicket = {
  id: 1,
  subject: "Can't login",
  status: "OPEN",
  category: "TECHNICAL",
  customerName: "Jane",
  customerEmail: "jane@example.com",
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  aiSummary: "User is unable to login due to forgotten password.",
  assignedToId: null,
  assignedTo: null,
  messages: [
    {
      id: "msg1",
      ticketId: 1,
      body: "I forgot my password.",
      sender: "CUSTOMER",
      senderType: "CUSTOMER",
      senderEmail: "jane@example.com",
      createdAt: new Date().toISOString(),
    },
  ],
};

const renderPage = (initialEntries = ["/tickets/1"]) => {
  return renderWithProviders(
    <Routes>,
      <Route path="/tickets/:id" element={<TicketDetailPage />} />
      <Route path="/tickets" element={<div>Tickets List Page</div>} />
    </Routes>,
    initialEntries
  );
};

describe("TicketDetailPage Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders all detail page sections", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: mockTicket });
    });

    renderPage(["/tickets/1"]);

    await waitFor(() => {
      expect(screen.getByText("Can't login")).toBeInTheDocument();
    });

    expect(screen.getAllByText("Jane")[0]).toBeInTheDocument();
    expect(screen.getAllByText(/jane@example.com/)[0]).toBeInTheDocument();
    expect(screen.getByText("User is unable to login due to forgotten password.")).toBeInTheDocument();
    expect(screen.getByText("I forgot my password.")).toBeInTheDocument();
  });

  it("displays 'Ticket not found' for 404 response", async () => {
    (api.get as any).mockRejectedValue({ status: 404 });

    renderPage(["/tickets/999"]);

    await waitFor(() => {
      expect(screen.getByText("Ticket not found")).toBeInTheDocument();
      expect(screen.getByRole("button", { name: /Back to tickets/i })).toBeInTheDocument();
    });
  });

  it("navigates back to tickets list when 'Back to tickets' is clicked on 404 page", async () => {
    (api.get as any).mockRejectedValue({ status: 404 });

    renderPage(["/tickets/999"]);

    const backBtn = await screen.findByRole("button", { name: /Back to tickets/i });
    const user = userEvent.setup();
    await user.click(backBtn);

    await waitFor(() => {
      expect(screen.getByText("Tickets List Page")).toBeInTheDocument();
    });
  });

  it("reply composer is hidden for CLOSED tickets", async () => {
    (api.get as any).mockResolvedValue({ ticket: { ...mockTicket, status: "CLOSED" } });

    renderPage(["/tickets/1"]);

    await waitFor(() => {
      expect(screen.getByText("Can't login")).toBeInTheDocument();
    });

    expect(screen.queryByPlaceholderText("Type your reply...")).not.toBeInTheDocument();
  });

  it("reply Send button is disabled when textarea is empty", async () => {
    (api.get as any).mockResolvedValue({ ticket: mockTicket });

    renderPage(["/tickets/1"]);

    const textarea = await screen.findByPlaceholderText("Type your reply...");
    const sendButton = screen.getByRole("button", { name: "Send Reply" });

    expect(sendButton).toBeDisabled();

    const user = userEvent.setup();
    await user.type(textarea, "Here is a reply");

    expect(sendButton).toBeEnabled();
  });

  it("allows updating status via status select", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: mockTicket });
    });
    (api.patch as any).mockResolvedValue({ ticket: { ...mockTicket, status: "RESOLVED" } });

    renderPage(["/tickets/1"]);

    await waitFor(() => {
      expect(screen.getByText("Can't login")).toBeInTheDocument();
    });

    const statusSelect = screen.getByRole("combobox", { name: /Status/i });
    const user = userEvent.setup();
    await user.click(statusSelect);

    const option = await screen.findByRole("option", { name: /Resolved/i });
    await user.click(option);

    await waitFor(() => {
      expect(api.patch).toHaveBeenCalledWith("/tickets/1", { status: "RESOLVED" });
    });
  });

  it("allows assigning ticket to logged-in user via 'Assign to me' button", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: mockTicket });
    });
    (api.patch as any).mockResolvedValue({ ticket: { ...mockTicket, assignedToId: "agent-id" } });

    renderPage(["/tickets/1"]);

    const assignToMeBtn = await screen.findByRole("button", { name: /Assign to me/i });
    expect(assignToMeBtn).toBeInTheDocument();

    const user = userEvent.setup();
    await user.click(assignToMeBtn);

    await waitFor(() => {
      expect(api.patch).toHaveBeenCalledWith("/tickets/1", { assignedToId: "agent-id" });
    });
  });

  it("hides 'Assign to me' button when ticket is already assigned to current user", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({
        ticket: { ...mockTicket, assignedToId: "agent-id" },
      });
    });

    renderPage(["/tickets/1"]);

    await waitFor(() => {
      expect(screen.getByText("Can't login")).toBeInTheDocument();
    });

    expect(screen.queryByRole("button", { name: /Assign to me/i })).not.toBeInTheDocument();
  });

  it("submits a reply and calls api.post to the reply route /tickets/:id/messages", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: mockTicket });
    });
    (api.post as any).mockResolvedValue({
      message: {
        id: "msg2",
        ticketId: 1,
        body: "We are looking into your issue.",
        sender: "AGENT",
        senderType: "AGENT",
        createdAt: new Date().toISOString(),
      },
    });

    renderPage(["/tickets/1"]);

    const textarea = await screen.findByPlaceholderText("Type your reply...");
    const sendButton = screen.getByRole("button", { name: "Send Reply" });

    const user = userEvent.setup();
    await user.type(textarea, "We are looking into your issue.");
    await user.click(sendButton);

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith("/tickets/1/messages", {
        body: "We are looking into your issue.",
      });
    });
  });

  it("renders AI Summary section with Generate button when aiSummary is null", async () => {
    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: { ...mockTicket, aiSummary: null } });
    });

    renderPage(["/tickets/1"]);

    await waitFor(() => {
      expect(screen.getByText("Can't login")).toBeInTheDocument();
    });

    // AI Summary card is always shown
    expect(screen.getByText("AI Summary")).toBeInTheDocument();
    // When no summary, placeholder text is shown
    expect(screen.getByText(/No summary yet/i)).toBeInTheDocument();
    // Generate button shown
    expect(screen.getByRole("button", { name: /Generate/i })).toBeInTheDocument();
  });

  it("calls api.post /tickets/:id/summarize when Generate button is clicked and shows updated summary", async () => {
    const newSummary = "Jane is unable to login and has requested a password reset. The issue remains open pending resolution.";

    (api.get as any).mockImplementation((url: string) => {
      if (url.includes("/users")) return Promise.resolve({ users: [] });
      return Promise.resolve({ ticket: { ...mockTicket, aiSummary: null } });
    });
    (api.post as any).mockResolvedValue({ aiSummary: newSummary });

    renderPage(["/tickets/1"]);

    const generateBtn = await screen.findByRole("button", { name: /Generate/i });
    const user = userEvent.setup();
    await user.click(generateBtn);

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith("/tickets/1/summarize", {});
    });

    // Updated summary rendered after call
    await waitFor(() => {
      expect(screen.getByText(newSummary)).toBeInTheDocument();
    });

    // Button label changes to "Re-generate" after summary is set
    expect(screen.getByRole("button", { name: /Re-generate/i })).toBeInTheDocument();
  });
});

