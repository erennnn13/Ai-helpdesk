import { describe, it, expect, mock, beforeEach, afterEach } from "bun:test";
import {
  sendOutboundEmail,
  _setTransporterForTest,
  _setEmailLogLookupForTest,
  _resetTransporterForTest,
} from "./mailer";
import { prisma } from "./prisma";

// ─────────────────────────────────────────────────────────────────────────────
// Mailer Unit Tests
// ─────────────────────────────────────────────────────────────────────────────

describe("mailer - sendOutboundEmail", () => {
  let capturedMailOptions: any = null;

  beforeEach(() => {
    capturedMailOptions = null;

    // Inject mock transporter to bypass real SMTP entirely
    _setTransporterForTest({
      sendMail: mock(async (opts: any) => {
        capturedMailOptions = opts;
        return { messageId: "<mock-test-msg-id@test.local>" };
      }),
    } as any);

    // Default: EmailLog lookup returns null (no threading headers)
    _setEmailLogLookupForTest(async () => null);
  });

  afterEach(() => {
    // Reset transporter singleton fully between tests
    _resetTransporterForTest();
    _setEmailLogLookupForTest(async () => null);
  });

  // ─── Subject Formatting ─────────────────────────────────────────────────────

  it("should add [Ticket #ID] tag and Re: prefix to bare subject", async () => {
    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Cannot login to my account",
      text: "Here is the fix.",
      ticketId: 42,
    });

    expect(capturedMailOptions).not.toBeNull();
    expect(capturedMailOptions.subject).toBe("Re: [Ticket #42] Cannot login to my account");
  });

  it("should not double-add [Ticket #ID] if already present in subject", async () => {
    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "[Ticket #42] Cannot login to my account",
      text: "Here is the fix.",
      ticketId: 42,
    });

    expect(capturedMailOptions.subject).toBe("Re: [Ticket #42] Cannot login to my account");
    expect(capturedMailOptions.subject.match(/\[Ticket #42\]/g)?.length).toBe(1);
  });

  it("should not double-add Re: if subject already starts with Re:", async () => {
    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Re: [Ticket #42] Cannot login to my account",
      text: "Follow-up reply.",
      ticketId: 42,
    });

    expect(capturedMailOptions.subject).toBe("Re: [Ticket #42] Cannot login to my account");
    // Ensure only one "Re:" prefix
    expect((capturedMailOptions.subject.match(/^re:/i) || []).length).toBe(1);
  });

  it("should add Re: to subject even without a ticketId", async () => {
    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "General inquiry response",
      text: "Here is our answer.",
    });

    expect(capturedMailOptions.subject).toBe("Re: General inquiry response");
  });

  // ─── In-Reply-To / References Headers ──────────────────────────────────────

  it("should set In-Reply-To and References from EmailLog for ticketId", async () => {
    const originalMessageId = "<CAGx8original123@mail.gmail.com>";

    _setEmailLogLookupForTest(async (_ticketId) => ({
      messageId: originalMessageId,
    }));

    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Account issue",
      text: "We resolved your issue.",
      ticketId: 42,
    });

    expect(capturedMailOptions.inReplyTo).toBe(originalMessageId);
    expect(capturedMailOptions.references).toBe(originalMessageId);
  });

  it("should wrap bare Message-ID in angle brackets for In-Reply-To", async () => {
    _setEmailLogLookupForTest(async (_ticketId) => ({
      messageId: "bareMessageIdWithoutBrackets123@mail.gmail.com",
    }));

    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Test bare ID",
      text: "Wrapped ID test.",
      ticketId: 42,
    });

    expect(capturedMailOptions.inReplyTo).toBe("<bareMessageIdWithoutBrackets123@mail.gmail.com>");
    expect(capturedMailOptions.references).toBe("<bareMessageIdWithoutBrackets123@mail.gmail.com>");
  });

  it("should use manually provided inReplyTo/references and skip EmailLog lookup", async () => {
    const lookupMock = mock(async () => null);
    _setEmailLogLookupForTest(lookupMock);

    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Manual override test",
      text: "Reply body.",
      ticketId: 42,
      inReplyTo: "<manual-reply-to@gmail.com>",
      references: "<manual-reference@gmail.com>",
    });

    // Manually provided values must be used and lookup must not be called
    expect(capturedMailOptions.inReplyTo).toBe("<manual-reply-to@gmail.com>");
    expect(capturedMailOptions.references).toBe("<manual-reference@gmail.com>");
    expect(lookupMock).not.toHaveBeenCalled();
  });

  it("should set no threading headers when EmailLog returns null", async () => {
    _setEmailLogLookupForTest(async () => null);

    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "New ticket no log",
      text: "No threading for this one.",
      ticketId: 99,
    });

    expect(capturedMailOptions.inReplyTo).toBeUndefined();
    expect(capturedMailOptions.references).toBeUndefined();
  });

  // ─── SMTP Disabled / Error Handling ────────────────────────────────────────

  it("should return false when transporter is null (SMTP disabled)", async () => {
    _setTransporterForTest(null);

    const result = await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Test skip",
      text: "This should be skipped.",
    });

    expect(result).toBe(false);
    expect(capturedMailOptions).toBeNull();
  });

  it("should return false and log error when sendMail throws", async () => {
    _setTransporterForTest({
      sendMail: mock(async () => {
        throw new Error("SMTP connection refused");
      }),
    } as any);

    const result = await sendOutboundEmail({
      to: "customer@example.com",
      subject: "SMTP failure test",
      text: "This will fail.",
      ticketId: 55,
    });

    expect(result).toBe(false);
  });

  it("should pass correct from, to, text, and html fields to sendMail", async () => {
    await sendOutboundEmail({
      to: "customer@example.com",
      subject: "Field check",
      text: "Plain text body.",
      html: "<p>HTML body.</p>",
      ticketId: 7,
    });

    expect(capturedMailOptions.to).toBe("customer@example.com");
    expect(capturedMailOptions.text).toBe("Plain text body.");
    expect(capturedMailOptions.html).toBe("<p>HTML body.</p>");
  });
});


// ─────────────────────────────────────────────────────────────────────────────
// Webhook Controller — Internet Message-ID Extraction from Headers
// ─────────────────────────────────────────────────────────────────────────────

describe("webhook.controller - Internet Message-ID extraction", () => {
  const makeReqRes = (body: any) => {
    const req: any = { body, headers: {}, query: {} };
    let responseBody: any = null;
    let responseStatus: number = 200;
    const res: any = {
      status: (s: number) => { responseStatus = s; return res; },
      json: (data: any) => { responseBody = data; },
      _getStatus: () => responseStatus,
      _getBody: () => responseBody,
    };
    const next = mock((_err?: any) => {});
    return { req, res, next };
  };

  it("should extract true Internet Message-ID from payload.Headers and store it in EmailLog", async () => {
    const { handlePostmarkInbound } = await import("../controllers/webhook.controller");
    const trueMessageId = "<CAGx8z-test-internet-id@mail.gmail.com>";

    const { req, res, next } = makeReqRes({
      From: "testuser@example.com",
      FromFull: { Name: "Test User", Email: "testuser@example.com" },
      Subject: "Test Internet Message-ID Extraction",
      MessageID: "postmark-internal-uuid-abc123",
      Headers: [
        { Name: "Content-Type", Value: "text/plain; charset=utf-8" },
        { Name: "Message-ID", Value: trueMessageId },
        { Name: "Date", Value: "Mon, 28 Jul 2026 10:00:00 +0000" },
      ],
      TextBody: "Testing message ID extraction.",
    });

    await handlePostmarkInbound(req, res, next);

    expect(res._getStatus()).toBe(201);
    const ticketId = res._getBody().ticketId;

    const log = await prisma.emailLog.findFirst({ where: { ticketId } });
    expect(log?.messageId).toBe(trueMessageId);

    // Cleanup
    await prisma.emailLog.deleteMany({ where: { ticketId } });
    await prisma.ticket.delete({ where: { id: ticketId } });
  });

  it("should fallback to payload.MessageID when Headers has no Message-ID entry", async () => {
    const { handlePostmarkInbound } = await import("../controllers/webhook.controller");
    const fallbackId = `postmark-fallback-${Date.now()}`;

    const { req, res, next } = makeReqRes({
      From: "fallback@example.com",
      FromFull: { Name: "Fallback User", Email: "fallback@example.com" },
      Subject: "Fallback to Postmark ID",
      MessageID: fallbackId,
      Headers: [
        { Name: "Content-Type", Value: "text/plain" },
        // Intentionally no Message-ID header
      ],
      TextBody: "Testing fallback.",
    });

    await handlePostmarkInbound(req, res, next);

    expect(res._getStatus()).toBe(201);
    const ticketId = res._getBody().ticketId;

    const log = await prisma.emailLog.findFirst({ where: { ticketId } });
    expect(log?.messageId).toBe(fallbackId);

    // Cleanup
    await prisma.emailLog.deleteMany({ where: { ticketId } });
    await prisma.ticket.delete({ where: { id: ticketId } });
  });

  it("should fallback to payload.MessageID when Headers field is absent entirely", async () => {
    const { handlePostmarkInbound } = await import("../controllers/webhook.controller");
    const noHeadersId = `postmark-no-headers-${Date.now()}`;

    const { req, res, next } = makeReqRes({
      From: "noheaders@example.com",
      FromFull: { Name: "No Headers", Email: "noheaders@example.com" },
      Subject: "No Headers Field Test",
      MessageID: noHeadersId,
      // Headers key absent
      TextBody: "No headers in this payload.",
    });

    await handlePostmarkInbound(req, res, next);

    expect(res._getStatus()).toBe(201);
    const ticketId = res._getBody().ticketId;

    const log = await prisma.emailLog.findFirst({ where: { ticketId } });
    expect(log?.messageId).toBe(noHeadersId);

    // Cleanup
    await prisma.emailLog.deleteMany({ where: { ticketId } });
    await prisma.ticket.delete({ where: { id: ticketId } });
  });

  it("should return 200 ignored when sender email is missing", async () => {
    const { handlePostmarkInbound } = await import("../controllers/webhook.controller");

    const { req, res, next } = makeReqRes({
      From: "",
      FromFull: { Name: "", Email: "" },
      Subject: "No Sender",
      MessageID: "no-sender-msg-id",
      TextBody: "No sender address.",
    });

    await handlePostmarkInbound(req, res, next);

    expect(res._getStatus()).toBe(200);
    expect(res._getBody().status).toBe("ignored");
    expect(res._getBody().reason).toBe("missing_sender");
  });
});
