import { describe, it, expect, mock } from "bun:test";
import { TicketStatus } from "@prisma/client";

describe("kb-solver.lib - processTicketAutoResolution", () => {
  it("should update ticket status to OPEN if AI generation throws an error", async () => {
    const { prisma } = await import("./prisma");
    const { processTicketAutoResolution } = await import("./kb-solver.lib");

    // Mock prisma findUnique to return a test ticket
    const originalFindUnique = prisma.ticket.findUnique;
    const originalUpdate = prisma.ticket.update;

    let updatedStatus: any = null;

    (prisma.ticket as any).findUnique = mock(async () => ({
      id: 9999,
      subject: "Test exception ticket",
      status: "PROCESSING",
      category: null,
      messages: [{ body: "Sample message body" }],
    }));

    (prisma.ticket as any).update = mock(async (args: any) => {
      if (args.data.status) {
        updatedStatus = args.data.status;
      }
      return { id: 9999, status: args.data.status || "OPEN" };
    });

    // Mock fetch to simulate an exception during AI text generation
    const originalFetch = global.fetch;
    global.fetch = mock(async () => {
      throw new Error("Gemini API network timeout exception");
    }) as any;

    try {
      const finalStatus = await processTicketAutoResolution(9999);

      expect(finalStatus).toEqual(TicketStatus.OPEN);
      expect(updatedStatus).toEqual(TicketStatus.OPEN);
    } finally {
      // Restore mocks
      global.fetch = originalFetch;
      (prisma.ticket as any).findUnique = originalFindUnique;
      (prisma.ticket as any).update = originalUpdate;
    }
  });
});
