import dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.join(process.cwd(), ".env") });

async function main() {
  const { sendOutboundEmail } = await import("./lib/mailer");
  const targetEmail = process.argv[2] || "test@example.com";
  
  console.log(`🚀 Starting Postmark SMTP test...`);
  console.log(`📧 Attempting to send a test email to: ${targetEmail}`);
  console.log(`(If this fails, ensure you have set your actual Postmark API Token in server/.env)`);
  
  const success = await sendOutboundEmail({
    to: targetEmail,
    subject: "Test from Postmark SMTP Upgrade",
    text: "Hello! If you are seeing this, the Postmark SMTP configuration on localhost is working correctly. 🎉\n\n- AI Helpdesk System",
  });

  if (success) {
    console.log("✅ Email sent successfully!");
    process.exit(0);
  } else {
    console.error("❌ Failed to send email. Check your .env file to ensure SMTP_USER and SMTP_PASS are set correctly.");
    process.exit(1);
  }
}

main();
