import type { Request, Response, NextFunction } from "express";
import { Role, Prisma } from "@prisma/client";
import type { UserFormValues, UpdateUserFormValues } from "core";
import bcrypt from "bcryptjs";
import { prisma } from "../lib/prisma";
import { createError } from "../middleware/error.middleware";

/**
 * GET /api/users
 * List all users (admin only)
 */
export async function getUsers(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const users = await prisma.user.findMany({
      where: {
        deletedAt: null,
        NOT: { email: { contains: "_deleted_" } },
      },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: { createdAt: "desc" },
    });

    res.json({ users });
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/users
 * Create a new user/agent (admin only)
 */
export async function createUser(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { email, name, password, role } = req.body as UserFormValues;

    // Check for existing user
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return next(createError("A user with this email already exists", 409));
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await prisma.user.create({
      data: {
        email,
        name,
        role: (role as Role) || Role.AGENT,
        emailVerified: true,
        accounts: {
          create: {
            accountId: email,
            providerId: "credential",
            password: passwordHash,
          },
        },
      },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
      },
    });

    res.status(201).json({ user });
  } catch (error) {
    next(error);
  }
}

/**
 * PATCH /api/users/:id
 * Update a user (admin only)
 */
export async function updateUser(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = String(req.params.id);
    const { email, name, role, password } = req.body as UpdateUserFormValues;

    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing || existing.deletedAt) {
      return next(createError("User not found", 404));
    }

    const data: Prisma.UserUpdateInput = {};
    if (email) data.email = email;
    if (name) data.name = name;
    if (role) data.role = role as Role;

    if (password) {
      const passwordHash = await bcrypt.hash(password, 12);
      await prisma.account.updateMany({
        where: { userId: id, providerId: "credential" },
        data: { password: passwordHash },
      });
    }

    const user = await prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        updatedAt: true,
      },
    });

    res.json({ user });
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/users/:id
 * Delete a user (admin only)
 */
export async function deleteUser(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = String(req.params.id);

    // Prevent deleting yourself
    if (id === res.locals.user?.id) {
      return next(createError("You cannot delete your own account", 400));
    }

    const user = await prisma.user.findUnique({ where: { id } });
    if (!user || user.deletedAt) {
      return next(createError("User not found", 404));
    }

    // Prevent deleting admins
    if (user.role === Role.ADMIN) {
      return next(createError("Admin users cannot be deleted", 400));
    }

    await prisma.$transaction([
      prisma.ticket.updateMany({
        where: { assignedToId: id },
        data: { assignedToId: null },
      }),
      prisma.user.update({
        where: { id },
        data: {
          deletedAt: new Date(),
          email: `${user.email}_deleted_${Date.now()}`,
          sessions: { deleteMany: {} },
          accounts: { deleteMany: {} },
        },
      }),
    ]);

    res.json({ message: "User deleted successfully" });
  } catch (error) {
    next(error);
  }
}
