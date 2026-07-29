import { createContext, useContext, type ReactNode } from 'react';

import { authClient } from "../lib/auth-client";
import type { Session } from "../lib/auth-client";

interface AuthContextType {
  session: Session | null;
  isPending: boolean;
  error: Error | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const { data: session, isPending, error } = authClient.useSession();

  return (
    <AuthContext.Provider value={{ session: (session as Session) || null, isPending, error }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

