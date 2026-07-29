import { Headset } from "lucide-react";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  showText?: boolean;
}

export function Logo({ size = "md", showText = true }: LogoProps) {
  const dimensions = {
    sm: { container: 30, icon: 15, fontSize: 13.5, subtitleSize: 9 },
    md: { container: 36, icon: 18, fontSize: 15, subtitleSize: 10 },
    lg: { container: 48, icon: 24, fontSize: 24, subtitleSize: 12 },
  }[size];

  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10, userSelect: "none" }}>
      <div
        style={{
          width: dimensions.container,
          height: dimensions.container,
          borderRadius: size === "lg" ? 14 : 10,
          background: "linear-gradient(135deg, #6366F1 0%, #4F46E5 50%, #4338CA 100%)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: "0 3px 10px rgba(79, 70, 229, 0.35)",
          flexShrink: 0,
        }}
      >
        <Headset style={{ width: dimensions.icon, height: dimensions.icon, color: "#FFFFFF" }} />
      </div>
      {showText && (
        <div style={{ display: "flex", flexDirection: "column" }}>
          <div
            style={{
              fontSize: dimensions.fontSize,
              fontWeight: 700,
              color: "#1C1917",
              letterSpacing: "-0.01em",
              lineHeight: 1.2,
            }}
          >
            Helpdesk
          </div>
          <div
            style={{
              fontSize: dimensions.subtitleSize,
              color: "#A8A29E",
              fontWeight: 600,
              letterSpacing: "0.04em",
              textTransform: "uppercase",
            }}
          >
            AI Support Ops
          </div>
        </div>
      )}
    </div>
  );
}
