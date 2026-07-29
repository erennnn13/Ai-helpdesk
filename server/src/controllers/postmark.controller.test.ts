import { describe, it, expect, beforeAll, afterAll } from "vitest";
import request from "supertest";
import app from "../index";
import { prisma } from "../lib/prisma";

describe("Postmark Inbound Webhook API", () => {
  const testMessageId = `test-msg-${Date.now()}-${Math.random()}`;

  afterAll(async () => {
    // Cleanup created test email logs & tickets
    await prisma.emailLog.deleteMany({ where: { messageId: { contains: "test-msg" } } });
    await prisma.ticket.deleteMany({ where: { customerEmail: "postmark-test@example.com" } });
  });

  it("should create a new ticket from a valid Postmark inbound webhook payload", async () => {
    const payload = {
      FromName: "Postmark Test User",
      From: "postmark-test@example.com",
      FromFull: {
        Email: "postmark-test@example.com",
        Name: "Postmark Test User",
      },
      Subject: "Need Help with Billing",
      MessageID: testMessageId,
      TextBody: "I was charged twice for my subscription.",
      HtmlBody: "<p>I was charged twice for my subscription.</p>",
    };

    const res = await request(app)
      .post("/api/webhooks/postmark")
      .send(payload);

    expect(res.status).toBe(201);
    expect(res.body.status).toBe("created");
    expect(res.body.ticketId).toBeDefined();

    // Verify ticket in DB
    const ticket = await prisma.ticket.findUnique({
      where: { id: res.body.ticketId },
      include: { messages: true },
    });

    expect(ticket).not.toBeNull();
    expect(ticket?.subject).toBe("Need Help with Billing");
    expect(ticket?.customerEmail).toBe("postmark-test@example.com");
    expect(ticket?.customerName).toBe("Postmark Test User");
    expect(ticket?.source).toBe("EMAIL");
    expect(ticket?.messages.length).toBe(1);
    expect(ticket?.messages[0]?.body).toBe("I was charged twice for my subscription.");
  });

  it("should ignore duplicate MessageID payloads", async () => {
    const payload = {
      From: "postmark-test@example.com",
      Subject: "Duplicate Message Test",
      MessageID: testMessageId,
      TextBody: "This is a duplicate payload.",
    };

    const res = await request(app)
      .post("/api/webhooks/postmark")
      .send(payload);

    expect(res.status).toBe(200);
    expect(res.body.status).toBe("duplicate");
  });

  it("should thread reply message to existing ticket when subject includes [Ticket #ID]", async () => {
    // Create an initial ticket
    const initialTicket = await prisma.ticket.create({
      data: {
        subject: "Password Reset Issue",
        customerName: "Postmark Test User",
        customerEmail: "postmark-test@example.com",
        source: "EMAIL",
        status: "RESOLVED",
        messages: {
          create: {
            body: "Original problem description",
            sender: "CUSTOMER",
            senderEmail: "postmark-test@example.com",
          },
        },
      },
    });

    const replyMessageId = `test-msg-reply-${Date.now()}`;
    const payload = {
      From: "postmark-test@example.com",
      Subject: `Re: [Ticket #${initialTicket.id}] Password Reset Issue`,
      MessageID: replyMessageId,
      TextBody: "It is still not working for me.",
    };

    const res = await request(app)
      .post("/api/webhooks/postmark")
      .send(payload);

    expect(res.status).toBe(200);
    expect(res.body.status).toBe("threaded");
    expect(res.body.ticketId).toBe(initialTicket.id);

    // Verify ticket has 2 messages and status is reopened to OPEN
    const updatedTicket = await prisma.ticket.findUnique({
      where: { id: initialTicket.id },
      include: { messages: true },
    });

    expect(updatedTicket?.messages.length).toBe(2);
    expect(updatedTicket?.status).toBe("OPEN");
    expect(updatedTicket?.messages[1]?.body).toBe("It is still not working for me.");
  });
});
