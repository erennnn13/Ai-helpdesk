import { NavLink, Outlet } from "react-router";
import { useAuth } from "../context/AuthContext";
import { authClient } from "../lib/auth-client";
import {
  LayoutDashboard, Ticket, Users as UsersIcon, LogOut,
  Headset, ShieldCheck, User, ChevronRight,
} from "lucide-react";
import { Role } from "core";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Logo } from "./Logo";

export default function Layout() {
  const { session } = useAuth();


  const handleLogout = async () => {
    await authClient.signOut();
    window.location.href = "/login";
  };

  const role = (session?.user as any)?.role || "USER";
  const isAdmin = role === Role.ADMIN;
  const isAgent = role === Role.AGENT;

  const navItems = [
    { to: "/", label: "Dashboard", icon: LayoutDashboard },
    { to: "/tickets", label: "Tickets", icon: Ticket },
    ...(isAdmin ? [{ to: "/users", label: "Users", icon: UsersIcon }] : []),
  ];

  const avatarSeed = session?.user?.email || "default";
  const avatarStyle = isAdmin ? "micah" : isAgent ? "fun-emoji" : "adventurer";
  const avatarUrl = isAdmin
    ? `https://api.dicebear.com/7.x/micah/svg?seed=${avatarSeed}&backgroundColor=b6e3f4,c0aede,ffd5dc&baseColor=apricot`
    : `https://api.dicebear.com/7.x/${avatarStyle}/svg?seed=${avatarSeed}&backgroundColor=b6e3f4,c0aede,ffd5dc`;

  return (
    <div style={{ display: "flex", height: "100vh", background: "#F8F7F4", fontFamily: "'Instrument Sans Variable', sans-serif", color: "#1C1917", overflow: "hidden" }}>

      {/* ── Sidebar ── */}
      <aside style={{
        width: 240,
        background: "#FFFFFF",
        borderRight: "1px solid #E7E5E0",
        display: "flex",
        flexDirection: "column",
        flexShrink: 0,
        zIndex: 20,
      }}>

        {/* Logo */}
        <div style={{
          height: 64,
          display: "flex",
          alignItems: "center",
          padding: "0 20px",
          borderBottom: "1px solid #E7E5E0",
        }}>
          <Logo size="md" />
        </div>

        {/* Nav section label */}
        <div style={{ padding: "20px 20px 6px" }}>
          <span style={{ fontSize: 10, fontWeight: 600, color: "#A8A29E", textTransform: "uppercase", letterSpacing: "0.08em" }}>
            Menu
          </span>
        </div>

        {/* Nav items */}
        <nav style={{ flex: 1, padding: "0 10px", overflowY: "auto" }}>
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === "/"}
              className={({ isActive }) => isActive ? "nav-active" : "nav-inactive"}
              style={{
                display: "flex", alignItems: "center", gap: 10,
                padding: "9px 12px",
                borderRadius: 10,
                marginBottom: 2,
                fontSize: 14,
                fontWeight: 500,
                textDecoration: "none",
                transition: "all 0.15s ease",
              }}
            >
              <item.icon style={{ width: 16, height: 16, flexShrink: 0 }} />
              {item.label}
            </NavLink>
          ))}
        </nav>

        {/* Sidebar footer badge */}
        <div style={{ padding: "16px 20px", borderTop: "1px solid #E7E5E0" }}>
          <div style={{ fontSize: 11, color: "#A8A29E", fontWeight: 500 }}>
            Helpdesk v1.0 &middot; AI Active
          </div>
        </div>
      </aside>

      {/* ── Main content ── */}
      <main style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>

        {/* Top header */}
        <header style={{
          height: 64,
          background: "#FFFFFF",
          borderBottom: "1px solid #E7E5E0",
          padding: "0 32px",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          flexShrink: 0,
        }}>
          {/* Breadcrumb / Location */}
          <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 13, color: "#A8A29E" }}>
            <Headset style={{ width: 14, height: 14, color: "#4F46E5" }} />
            <ChevronRight style={{ width: 13, height: 13 }} />
            <span style={{ color: "#1C1917", fontWeight: 500 }}>
              {navItems.find(n => n.to !== "/" || window.location.pathname === "/")?.label ?? "Dashboard"}
            </span>
          </div>

          {/* ── Top Right Admin / User Profile Panel ── */}
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            
            {/* User Profile Pill */}
            <div style={{
              display: "flex",
              alignItems: "center",
              gap: 10,
              padding: "4px 12px 4px 6px",
              background: "#F8F7F4",
              border: "1px solid #E7E5E0",
              borderRadius: "999px",
            }}>
              <Avatar style={{ width: 28, height: 28, border: "1px solid #E7E5E0" }}>
                <AvatarImage src={avatarUrl} alt={session?.user?.name || "User"} />
                <AvatarFallback style={{ background: "#EEF2FF", color: "#4338CA", fontSize: 11, fontWeight: 600 }}>
                  {isAdmin ? <ShieldCheck style={{ width: 13, height: 13 }} /> : <User style={{ width: 13, height: 13 }} />}
                </AvatarFallback>
              </Avatar>

              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontSize: 13, fontWeight: 600, color: "#1C1917", maxWidth: 120, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                  {session?.user?.name}
                </span>

                {isAdmin ? (
                  <span style={{ fontSize: 10, color: "#4338CA", fontWeight: 600, background: "#EEF2FF", border: "1px solid #C7D2FE", padding: "1px 7px", borderRadius: "999px", display: "inline-flex", alignItems: "center", gap: 3 }}>
                    <ShieldCheck style={{ width: 10, height: 10 }} />
                    Admin
                  </span>
                ) : isAgent ? (
                  <span style={{ fontSize: 10, color: "#065F46", fontWeight: 600, background: "#ECFDF5", border: "1px solid #A7F3D0", padding: "1px 7px", borderRadius: "999px", display: "inline-flex", alignItems: "center", gap: 3 }}>
                    <Headset style={{ width: 10, height: 10 }} />
                    Agent
                  </span>
                ) : (
                  <span style={{ fontSize: 10, color: "#78716C", fontWeight: 600, background: "#F0EEE9", border: "1px solid #E7E5E0", padding: "1px 7px", borderRadius: "999px" }}>
                    User
                  </span>
                )}
              </div>
            </div>

            {/* Quick Admin Users Link (if Admin) */}
            {isAdmin && (
              <NavLink
                to="/users"
                style={({ isActive }) => ({
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 6,
                  padding: "6px 12px",
                  fontSize: 12.5,
                  fontWeight: 600,
                  color: isActive ? "#4338CA" : "#44403C",
                  background: isActive ? "#EEF2FF" : "#F8F7F4",
                  border: isActive ? "1px solid #C7D2FE" : "1px solid #E7E5E0",
                  borderRadius: "8px",
                  textDecoration: "none",
                  transition: "all 0.15s ease",
                })}
              >
                <UsersIcon style={{ width: 14, height: 14, color: "#4F46E5" }} />
                Admin Panel
              </NavLink>
            )}

            {/* Sign Out Button */}
            <Dialog>
              <DialogTrigger
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 6,
                  padding: "6px 12px",
                  fontSize: 12.5,
                  fontWeight: 500,
                  color: "#78716C",
                  background: "transparent",
                  border: "1px solid #E7E5E0",
                  borderRadius: "8px",
                  cursor: "pointer",
                  transition: "all 0.15s ease",
                  fontFamily: "'Instrument Sans Variable', sans-serif",
                }}
                onMouseEnter={e => {
                  e.currentTarget.style.background = "#FEF2F2";
                  e.currentTarget.style.color = "#DC2626";
                  e.currentTarget.style.borderColor = "#FCA5A5";
                }}
                onMouseLeave={e => {
                  e.currentTarget.style.background = "transparent";
                  e.currentTarget.style.color = "#78716C";
                  e.currentTarget.style.borderColor = "#E7E5E0";
                }}
              >
                <LogOut style={{ width: 13, height: 13 }} />
                Sign out
              </DialogTrigger>
              <DialogContent showCloseButton={false} className="sm:max-w-md py-6">
                <DialogHeader>
                  <DialogTitle>Sign Out</DialogTitle>
                  <DialogDescription>
                    Are you sure you want to sign out?
                  </DialogDescription>
                </DialogHeader>
                <DialogFooter className="mt-4">
                  <DialogClose render={<Button variant="outline" />}>
                    Cancel
                  </DialogClose>
                  <Button onClick={handleLogout}>Sign Out</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>

          </div>
        </header>

        {/* Page Container */}
        <div style={{ flex: 1, overflowY: "auto", padding: "32px", maxWidth: 1280, width: "100%", margin: "0 auto" }}>
          <Outlet />
        </div>
      </main>
    </div>
  );
}
