import { Router } from "express";
import {
  getUsers,
  createUser,
  updateUser,
  deleteUser,
} from "../controllers/user.controller";
import { requireAuth, requireAdmin } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import { userSchema, updateUserSchema } from "core";

export const userRouter = Router();

// All user routes require auth
userRouter.use(requireAuth);

// Any authenticated user can list users (for ticket assignment)
userRouter.get("/", getUsers);

// Admin-only routes for user creation, modification, deletion
userRouter.post("/", requireAdmin, validate(userSchema), createUser);
userRouter.patch("/:id", requireAdmin, validate(updateUserSchema), updateUser);
userRouter.delete("/:id", requireAdmin, deleteUser);
