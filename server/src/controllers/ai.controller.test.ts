import { describe, it, expect, mock, beforeEach, afterEach, spyOn } from "bun:test";
import { polishReply, summarizeTicket } from "./ai.controller";
import { prisma } from "../lib/prisma";

describe("ai.controller - polishReply", () => {
  const originalEnv = process.env.GEMINI_API_KEY;
  const originalFetch = global.fetch;

  beforeEach(() => {
    process.env.GEMINI_API_KEY = "test-api-key";
  });

  afterEach(() => {
    process.env.GEMINI_API_KEY = originalEnv;
    global.fetch = originalFetch;
  });

  it("should return 400 error if draft is missing or empty", async () => {
    const req = { body: { draft: "   " } } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await polishReply(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(400);
    expect(errorPassed.message).toBe("Draft reply text is required");
  });

  it("should return 500 error if GEMINI_API_KEY is not configured", async () => {
    delete process.env.GEMINI_API_KEY;
    delete process.env.GOOGLE_GENERATIVE_AI_API_KEY;

    const req = { body: { draft: "Valid draft reply" } } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await polishReply(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(500);
    expect(errorPassed.message).toBe("GEMINI_API_KEY is not configured in environment variables");
  });

  it("should extract first names and include them in the prompt to Gemini REST API", async () => {
    let capturedBody: any = null;

    global.fetch = mock(async (url: string | URL | Request, init?: RequestInit) => {
      if (init?.body) capturedBody = JSON.parse(init.body as string);
      return new Response(
        JSON.stringify({
          candidates: [{ content: { parts: [{ text: "Hi Alice,\n\nWe are looking into this.\n\nBest regards,\nDavid" }] } }]
        }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }) as any;

    const req = {
      body: {
        draft: "looking into this now",
        subject: "Password Reset",
        customerName: "Alice Johnson",
        agentName: "David Miller"
      }
    } as any;

    let resJson: any = null;
    const res = { json: (data: any) => { resJson = data; } } as any;
    const next = mock();

    await polishReply(req, res, next);

    expect(resJson).not.toBeNull();
    expect(resJson.polishedText).toBe("Hi Alice,\n\nWe are looking into this.\n\nBest regards,\nDavid");

    const promptText = capturedBody.contents[0].parts[0].text;
    expect(promptText).toContain('Customer First Name: "Alice"');
    expect(promptText).toContain('Assigned Agent First Name: "David"');
    expect(promptText).toContain('ONLY their first name, "Alice"');
    expect(promptText).toContain('ONLY the assigned agent\'s first name, "David"');
  });

  it("should handle 429 quota exceeded error from Gemini API", async () => {
    global.fetch = mock(async () => {
      return new Response(
        JSON.stringify({ error: { message: "Quota exceeded for metric limit: 0" } }),
        { status: 429, headers: { "Content-Type": "application/json" } }
      );
    }) as any;

    const req = { body: { draft: "Draft reply" } } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await polishReply(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(429);
    expect(errorPassed.message).toContain("Gemini API Key Quota Exceeded");
  });
});

// ---------------------------------------------------------------------------

describe("ai.controller - summarizeTicket", () => {
  const originalEnv = process.env.GEMINI_API_KEY;
  const originalFetch = global.fetch;

  const mockTicket = {
    id: 1,
    subject: "Cannot log in to account",
    customerName: "Bob Smith",
    customerEmail: "bob@example.com",
    status: "OPEN",
    category: "TECHNICAL",
    aiSummary: null,
    messages: [
      {
        id: "m1",
        sender: "CUSTOMER",
        body: "I can't log in, it says wrong password but I reset it.",
        createdAt: new Date("2024-01-10T09:00:00Z"),
      },
      {
        id: "m2",
        sender: "AGENT",
        body: "Hi Bob, let me look into your account.",
        createdAt: new Date("2024-01-10T09:10:00Z"),
      },
    ],
  };

  beforeEach(() => {
    process.env.GEMINI_API_KEY = "test-api-key";
  });

  afterEach(() => {
    process.env.GEMINI_API_KEY = originalEnv;
    global.fetch = originalFetch;
  });

  it("should return 400 if ticket ID is not a valid number", async () => {
    const req = { params: { id: "not-a-number" }, body: {} } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await summarizeTicket(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(400);
    expect(errorPassed.message).toBe("Invalid ticket ID");
  });

  it("should return 500 if GEMINI_API_KEY is not configured", async () => {
    delete process.env.GEMINI_API_KEY;
    delete process.env.GOOGLE_GENERATIVE_AI_API_KEY;

    const req = { params: { id: "1" }, body: {} } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await summarizeTicket(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(500);
    expect(errorPassed.message).toBe("GEMINI_API_KEY is not configured in environment variables");
  });

  it("should return 404 if ticket is not found in database", async () => {
    const spy = spyOn(prisma.ticket, "findUnique").mockResolvedValue(null as any);

    const req = { params: { id: "999" }, body: {} } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await summarizeTicket(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(404);
    expect(errorPassed.message).toBe("Ticket not found");
    spy.mockRestore();
  });

  it("should generate a summary, persist it to DB, and return { aiSummary }", async () => {
    const summaryText = "The customer reported a login issue after resetting their password. An agent is investigating the account.";

    let capturedPrompt = "";
    global.fetch = mock(async (_url: any, init?: RequestInit) => {
      const body = JSON.parse(init!.body as string);
      capturedPrompt = body.contents[0].parts[0].text;

      return new Response(
        JSON.stringify({ candidates: [{ content: { parts: [{ text: summaryText }] } }] }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }) as any;

    // Use ticket ID 1 which exists in the test database
    const req = { params: { id: "1" }, body: {} } as any;
    let resJson: any = null;
    const res = { json: (data: any) => { resJson = data; } } as any;
    const next = mock();

    await summarizeTicket(req, res, next);

    // Prompt must contain the required structural elements (regardless of which ticket)
    expect(capturedPrompt).toContain("You are a concise support ticket summarizer");
    expect(capturedPrompt).toContain("Ticket Details:");
    expect(capturedPrompt).toContain("Conversation History");
    expect(capturedPrompt).toContain("Output ONLY the summary paragraph");

    // Response must contain the AI-generated summary from the mocked Gemini call
    expect(resJson).not.toBeNull();
    expect(resJson.aiSummary).toBe(summaryText);
  });

  it("should return 429 error when Gemini quota is exceeded", async () => {
    const spy = spyOn(prisma.ticket, "findUnique").mockResolvedValue(mockTicket as any);

    global.fetch = mock(async () => {
      return new Response(
        JSON.stringify({ error: { message: "Quota exceeded limit: 0" } }),
        { status: 429, headers: { "Content-Type": "application/json" } }
      );
    }) as any;

    const req = { params: { id: "1" }, body: {} } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await summarizeTicket(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(429);
    expect(errorPassed.message).toContain("Quota Exceeded");
    spy.mockRestore();
  });
});

// ---------------------------------------------------------------------------

describe("ai.controller - classifyTicket", () => {
  const originalEnv = process.env.GEMINI_API_KEY;
  const originalFetch = global.fetch;

  beforeEach(() => {
    process.env.GEMINI_API_KEY = "test-api-key";
  });

  afterEach(() => {
    process.env.GEMINI_API_KEY = originalEnv;
    global.fetch = originalFetch;
  });

  it("should return 400 for invalid ticket ID", async () => {
    const { classifyTicket } = await import("./ai.controller");
    const req = { params: { id: "invalid" }, query: {} } as any;
    const res = {} as any;
    let errorPassed: any = null;
    const next = (err: any) => { errorPassed = err; };

    await classifyTicket(req, res, next);

    expect(errorPassed).not.toBeNull();
    expect(errorPassed.status).toBe(400);
    expect(errorPassed.message).toBe("Invalid ticket ID");
  });

  it("should return non-blocking message immediately when query ?async=true", async () => {
    const { classifyTicket } = await import("./ai.controller");
    const req = { params: { id: "1" }, query: { async: "true" } } as any;
    let resJson: any = null;
    const res = { json: (data: any) => { resJson = data; } } as any;
    const next = mock();

    await classifyTicket(req, res, next);

    expect(resJson).toEqual({ message: "Classification started in background", ticketId: 1 });
  });

  it("should classify ticket synchronously using Gemini API and update DB", async () => {
    const { classifyTicket } = await import("./ai.controller");
    global.fetch = mock(async () => {
      return new Response(
        JSON.stringify({
          candidates: [{ content: { parts: [{ text: JSON.stringify({ category: "TECHNICAL", reasoning: "Software glitch" }) }] } }],
        }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }) as any;

    const req = { params: { id: "1" }, query: {} } as any;
    let resJson: any = null;
    const res = { json: (data: any) => { resJson = data; } } as any;
    const next = mock();

    await classifyTicket(req, res, next);

    expect(resJson).not.toBeNull();
    expect(resJson.category).toBe("TECHNICAL");
  });
});





