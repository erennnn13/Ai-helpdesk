import "dotenv/config";
import { PrismaClient, Role } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import pg from "pg";
import bcrypt from "bcryptjs";
import crypto from "crypto";

// ─── Bootstrap Prisma with the pg adapter ───────────────
const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
});
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.error("❌ ADMIN_EMAIL and ADMIN_PASSWORD must be set in .env");
    process.exit(1);
  }

  console.log("🌱 Seeding database...\n");

  // ─── Hash the password ────────────────────────────────
  const hashedPassword = await bcrypt.hash(password, 12);

  // ─── Upsert admin user ────────────────────────────────
  const admin = await prisma.user.upsert({
    where: { email },
    update: {},
    create: {
      id: crypto.randomUUID(),
      name: "Admin",
      email,
      role: Role.ADMIN,
      emailVerified: true,
      accounts: {
        create: {
          id: crypto.randomUUID(),
          accountId: email,
          providerId: "credential",
          password: hashedPassword,
        },
      },
    },
  });

  console.log(`✅ Admin user seeded: ${admin.email} (role: ${admin.role})`);

  // ─── Upsert agent user ────────────────────────────────
  const agentEmail = "agent@example.com";
  const agentPasswordHash = await bcrypt.hash("password123", 12);

  const agent = await prisma.user.upsert({
    where: { email: agentEmail },
    update: {},
    create: {
      id: crypto.randomUUID(),
      name: "Support Agent",
      email: agentEmail,
      role: Role.AGENT,
      emailVerified: true,
      accounts: {
        create: {
          id: crypto.randomUUID(),
          accountId: agentEmail,
          providerId: "credential",
          password: agentPasswordHash,
        },
      },
    },
  });

  console.log(`✅ Agent user seeded: ${agent.email} (role: ${agent.role})`);

  // ─── Seed a Ticket ──────────────────────────────────────
  const ticket = await prisma.ticket.create({
    data: {
      subject: "Test E2E Ticket",
      customerName: "E2E User",
      customerEmail: "e2e@example.com",
      status: "OPEN",
      messages: {
        create: {
          body: "This is a test ticket for E2E testing.",
          sender: "CUSTOMER",
          senderEmail: "e2e@example.com"
        }
      }
    }
  });
  console.log(`✅ Ticket seeded: ${ticket.subject}`);

  console.log("\n🎉 Seeding complete!");
}

main()
  .catch((e) => {
    console.error("❌ Seed error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
