/*
  Warnings:

  - You are about to drop the column `passwordHash` on the `user` table. All the data in the column will be lost.
  - The `role` column on the `user` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'AGENT', 'ADMIN');

-- AlterTable
ALTER TABLE "user" DROP COLUMN "passwordHash",
DROP COLUMN "role",
ADD COLUMN     "role" "Role" NOT NULL DEFAULT 'AGENT';
