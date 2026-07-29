-- AlterTable
ALTER TABLE "user" ADD COLUMN     "passwordHash" TEXT,
ADD COLUMN     "role" TEXT NOT NULL DEFAULT 'AGENT';
