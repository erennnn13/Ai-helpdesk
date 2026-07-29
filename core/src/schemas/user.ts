import { z } from "zod";

export enum Role {
  USER = "USER",
  AGENT = "AGENT",
  ADMIN = "ADMIN",
}

export const userSchema = z.object({
  name: z.string().trim().min(3, "Name must be at least 3 characters long"),
  email: z.string().email("Please enter a valid email id"),
  password: z.string().trim().min(8, "Password must be at least 8 characters long"),
  role: z.nativeEnum(Role)
});

export const updateUserSchema = z.object({
  name: z.string().trim().min(3, "Name must be at least 3 characters long").optional(),
  email: z.string().email("Please enter a valid email id").optional(),
  password: z.string().trim().min(8, "Password must be at least 8 characters long").optional().or(z.literal("")),
  role: z.nativeEnum(Role).optional()
});

export type UserFormValues = z.infer<typeof userSchema>;
export type UpdateUserFormValues = z.infer<typeof updateUserSchema>;
