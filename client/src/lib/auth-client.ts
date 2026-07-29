import { createAuthClient } from "better-auth/react";
import { Role } from "core";

export const authClient = createAuthClient({
  baseURL: import.meta.env.VITE_API_URL || "",
  fetchOptions: {
    credentials: "include",
  },
});

// Extend the inferred session type to include our custom role field
export type Session = Omit<typeof authClient.$Infer.Session, "user"> & {
  user: typeof authClient.$Infer.Session.user & {
    role: Role;
  };
};
