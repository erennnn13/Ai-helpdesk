import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { prisma } from "./prisma";
import bcrypt from "bcryptjs";

export const auth = betterAuth({
  baseURL: process.env.CLIENT_URL ? `${process.env.CLIENT_URL}/api/auth` : undefined,
  database: prismaAdapter(prisma, {
    provider: "postgresql",
  }),
  emailAndPassword: {
    enabled: true,
    disableSignUp: true,
    password: {
      hash: async (password) => {
        return await bcrypt.hash(password, 12);
      },
      verify: async ({ hash, password }) => {
        return await bcrypt.compare(password, hash);
      },
    },
  },
  rateLimit: {
    enabled: process.env.NODE_ENV === "production",
  },
  user: {
    additionalFields: {
      role: {
        type: "string",
      },
    },
  },
  trustedOrigins: [
    process.env.CLIENT_URL || "http://localhost:5173",
    "http://localhost:3001",
  ],
});
