import nodemailer from "nodemailer";
import { prisma } from "./prisma";

// Exposed for testing — can be replaced in tests via _setEmailLogLookup
let _emailLogLookup = async (ticketId: number): Promise<{ messageId: string } | null> => {
  return prisma.emailLog.findFirst({
    where: { ticketId },
    orderBy: { createdAt: "desc" },
  });
};

/**
 * FOR TESTING ONLY — override EmailLog lookup to avoid real DB calls.
 */
export function _setEmailLogLookupForTest(
  fn: (ticketId: number) => Promise<{ messageId: string } | null>
): void {
  _emailLogLookup = fn;
}

export interface SendEmailOptions {
  to: string;
  subject: string;
  text: string;
  html?: string;
  ticketId?: number;
  inReplyTo?: string;
  references?: string;
}

// Sentinel used by _setTransporterForTest to represent "explicitly disabled"
const DISABLED = Symbol("DISABLED");

let transporter: nodemailer.Transporter | null | typeof DISABLED = null;

/**
 * FOR TESTING ONLY — inject a mock transporter to bypass SMTP.
 * Pass null to explicitly disable sending (simulates missing SMTP_HOST).
 */
export function _setTransporterForTest(mock: nodemailer.Transporter | null): void {
  // null sentinel = disabled; an actual mock transporter = use it
  transporter = mock === null ? DISABLED : mock;
}

/**
 * Reset the transporter so it will be re-created on next use.
 * FOR TESTING ONLY.
 */
export function _resetTransporterForTest(): void {
  transporter = null;
}

function getTransporter(): nodemailer.Transporter | null {
  // Explicitly disabled by test
  if (transporter === DISABLED) return null;
  // Already created
  if (transporter !== null) return transporter;
  // Not yet created — build from env
  const host = process.env.SMTP_HOST;
  if (!host) return null;

  const port = parseInt(process.env.SMTP_PORT || "2525", 10);
  const user = process.env.SMTP_USER || "";
  const pass = process.env.SMTP_PASS || "";
  const secure = port === 465;
  const requireTLS = port === 587 || port === 2525 || port === 25;

  transporter = nodemailer.createTransport({
    host,
    port,
    secure,
    requireTLS,
    auth: user && pass ? { user, pass } : undefined,
  });

  return transporter;
}

/**
 * Ensure Message-ID is properly wrapped in angle brackets for email headers.
 * "abc123" -> "<abc123>"
 * "<abc123>" -> "<abc123>"
 */
function formatMessageHeaderId(id: string): string {
  const trimmed = id.trim();
  if (!trimmed) return "";
  if (trimmed.startsWith("<") && trimmed.endsWith(">")) {
    return trimmed;
  }
  return `<${trimmed}>`;
}

/**
 * Send an outbound email to a customer.
 */
export async function sendOutboundEmail(options: SendEmailOptions): Promise<boolean> {
  const { to, subject, text, html, ticketId } = options;
  let { inReplyTo, references } = options;

  const mailTransporter = getTransporter();

  // Format subject line with Ticket ID tag and "Re:" prefix for email client thread grouping
  let formattedSubject = subject.trim();
  if (ticketId && !formattedSubject.includes(`[Ticket #${ticketId}]`)) {
    formattedSubject = `[Ticket #${ticketId}] ${formattedSubject}`;
  }
  if (!/^re:/i.test(formattedSubject)) {
    formattedSubject = `Re: ${formattedSubject}`;
  }

  // Fetch original incoming Message-ID from EmailLog for inReplyTo/references if not provided
  if (ticketId && (!inReplyTo || !references)) {
    try {
      const emailLog = await _emailLogLookup(ticketId);

      if (emailLog?.messageId) {
        const formattedId = formatMessageHeaderId(emailLog.messageId);
        inReplyTo = inReplyTo || formattedId;
        references = references || formattedId;
      }
    } catch (err) {
      console.warn(`⚠️ [Mailer] Could not lookup EmailLog for ticket #${ticketId}:`, err);
    }
  }

  if (!mailTransporter) {
    console.log(`📧 [Mailer] SMTP_HOST not configured — skipping email dispatch to ${to}: "${formattedSubject}"`);
    return false;
  }

  const fromAddress = process.env.SMTP_FROM || process.env.SMTP_USER || "support@helpdesk.local";

  try {
    const info = await mailTransporter.sendMail({
      from: fromAddress,
      to,
      subject: formattedSubject,
      text,
      html: html || undefined,
      inReplyTo: inReplyTo ? formatMessageHeaderId(inReplyTo) : undefined,
      references: references ? formatMessageHeaderId(references) : undefined,
    });

    console.log(`✅ [Mailer] Email sent to ${to} (Subject: "${formattedSubject}", MessageId: ${info.messageId})`);
    return true;
  } catch (err) {
    console.error(`❌ [Mailer] Failed to send email to ${to}:`, err);
    return false;
  }
}
