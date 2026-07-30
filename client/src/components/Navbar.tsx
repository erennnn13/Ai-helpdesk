import { useAuth } from "../context/AuthContext";
import { authClient } from "../lib/auth-client";
import { useNavigate, Link } from "react-router";
import { Role } from "core";
import { Button, buttonVariants } from "@/components/ui/button";

export function Navbar() {
  const { session } = useAuth();
  const navigate = useNavigate();

  const handleSignOut = async () => {
    await authClient.signOut({
      fetchOptions: {
        onSuccess: () => {
          window.location.href = "/login";
        },
      },
    });
  };

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex-shrink-0">
            <Link to="/" className="text-xl font-bold tracking-tight hover:opacity-80 transition-opacity">
              AI Helpdesk
            </Link>
          </div>

          {session?.user && (
            <div className="flex items-center gap-6">
              {session.user.role === Role.ADMIN && (
                <Link to="/users" className={buttonVariants({ variant: "ghost", size: "sm" })}>
                  Users
                </Link>
              )}
              
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center border border-primary/20">
                  <span className="text-primary font-medium text-sm">
                    {session.user.name?.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div className="flex flex-col items-start">
                  <span className="text-foreground font-medium text-sm leading-none">
                    {session.user.name}
                  </span>
                  <span className="text-muted-foreground text-xs uppercase mt-1">
                    {session.user.role || "Role missing"}
                  </span>
                </div>
              </div>

              <Button
                onClick={handleSignOut}
                variant="outline"
                size="sm"
                className="hover:bg-black hover:text-white transition-colors"
              >
                Sign Out
              </Button>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}
