import { useState } from 'react';
import { useNavigate } from "react-router";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { authClient } from "../lib/auth-client";
import { Loader2, ArrowRight, KeyRound, ShieldCheck } from "lucide-react";
import { Logo } from "../components/Logo";

const loginSchema = z.object({
  email: z.string().min(1, "Email is required").email("Invalid email address"),
  password: z.string().min(1, "Password is required"),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export function Login() {
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    mode: "onTouched",
  });

  const onSubmit = async (data: LoginFormValues) => {
    setError("");
    const { error: signInError } = await authClient.signIn.email({
      email: data.email,
      password: data.password,
    });
    if (signInError) {
      setError(signInError.message || "Failed to login. Please check your credentials.");
    } else {
      navigate("/");
    }
  };

  // Quick fill helper for testing/demo
  const fillDemo = (email: string) => {
    setValue("email", email, { shouldValidate: true });
    setValue("password", "password123", { shouldValidate: true });
  };

  return (
    <div style={{
      minHeight: "100vh",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "'Instrument Sans Variable', sans-serif",
      background: "#F8F7F4",
      position: "relative",
      padding: "24px 16px",
      overflow: "hidden",
    }}>

      {/* Ambient background decoration */}
      <div style={{
        position: "absolute",
        top: "20%",
        left: "50%",
        transform: "translateX(-50%)",
        width: "600px",
        height: "600px",
        background: "radial-gradient(circle, rgba(79, 70, 229, 0.07) 0%, transparent 70%)",
        pointerEvents: "none",
        borderRadius: "50%",
      }} />

      {/* Main card */}
      <div style={{
        width: "100%",
        maxWidth: "420px",
        background: "#FFFFFF",
        border: "1px solid #E7E5E0",
        borderRadius: "20px",
        padding: "40px 36px",
        boxShadow: "0 12px 32px -8px rgba(28, 25, 23, 0.08), 0 2px 6px rgba(28, 25, 23, 0.03)",
        position: "relative",
        zIndex: 10,
      }}>

        {/* Logo & Header */}
        <div style={{ textAlign: "center", marginBottom: "32px", display: "flex", flexDirection: "column", alignItems: "center" }}>
          <div style={{ marginBottom: "16px" }}>
            <Logo size="lg" showText={false} />
          </div>

          <h1 style={{
            fontFamily: "'Fraunces', Georgia, serif",
            fontSize: "28px",
            fontWeight: 700,
            color: "#1C1917",
            letterSpacing: "-0.02em",
            marginBottom: "6px",
            lineHeight: 1.2,
          }}>
            Helpdesk
          </h1>
          <p style={{ fontSize: "14px", color: "#78716C" }}>
            Sign in to manage support tickets
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit(onSubmit)} noValidate style={{ display: "flex", flexDirection: "column", gap: "20px" }}>

          {/* Email field */}
          <div>
            <label htmlFor="email" style={{ display: "block", fontSize: "13px", fontWeight: 600, color: "#44403C", marginBottom: "7px" }}>
              Email address
            </label>
            <input
              id="email"
              type="email"
              {...register("email")}
              placeholder="agent@example.com"
              style={{
                width: "100%",
                padding: "11px 14px",
                fontSize: "14px",
                background: "#FAFAFA",
                border: errors.email ? "1.5px solid #DC2626" : "1.5px solid #E7E5E0",
                borderRadius: "10px",
                color: "#1C1917",
                outline: "none",
                transition: "all 0.15s ease",
                boxSizing: "border-box",
                fontFamily: "'Instrument Sans Variable', sans-serif",
              }}
              onFocus={e => {
                e.target.style.background = "#FFFFFF";
                e.target.style.borderColor = "#4F46E5";
                e.target.style.boxShadow = "0 0 0 3px rgba(79, 70, 229, 0.12)";
              }}
              onBlur={e => {
                e.target.style.background = "#FAFAFA";
                e.target.style.borderColor = errors.email ? "#DC2626" : "#E7E5E0";
                e.target.style.boxShadow = "none";
              }}
            />
            {errors.email && (
              <p style={{ marginTop: "5px", fontSize: "12px", color: "#DC2626", fontWeight: 500 }}>
                {errors.email.message}
              </p>
            )}
          </div>

          {/* Password field */}
          <div>
            <label htmlFor="password" style={{ display: "block", fontSize: "13px", fontWeight: 600, color: "#44403C", marginBottom: "7px" }}>
              Password
            </label>
            <input
              id="password"
              type="password"
              {...register("password")}
              placeholder="••••••••"
              style={{
                width: "100%",
                padding: "11px 14px",
                fontSize: "14px",
                background: "#FAFAFA",
                border: errors.password ? "1.5px solid #DC2626" : "1.5px solid #E7E5E0",
                borderRadius: "10px",
                color: "#1C1917",
                outline: "none",
                transition: "all 0.15s ease",
                boxSizing: "border-box",
                fontFamily: "'Instrument Sans Variable', sans-serif",
              }}
              onFocus={e => {
                e.target.style.background = "#FFFFFF";
                e.target.style.borderColor = "#4F46E5";
                e.target.style.boxShadow = "0 0 0 3px rgba(79, 70, 229, 0.12)";
              }}
              onBlur={e => {
                e.target.style.background = "#FAFAFA";
                e.target.style.borderColor = errors.password ? "#DC2626" : "#E7E5E0";
                e.target.style.boxShadow = "none";
              }}
            />
            {errors.password && (
              <p style={{ marginTop: "5px", fontSize: "12px", color: "#DC2626", fontWeight: 500 }}>
                {errors.password.message}
              </p>
            )}
          </div>

          {/* Error Message */}
          {error && (
            <div style={{
              padding: "10px 14px",
              background: "#FEF2F2",
              border: "1px solid #FCA5A5",
              borderRadius: "10px",
              fontSize: "13px",
              color: "#DC2626",
              textAlign: "center",
              fontWeight: 500,
            }}>
              {error}
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isSubmitting}
            style={{
              width: "100%",
              padding: "12px 20px",
              background: "#4F46E5",
              color: "#FFFFFF",
              border: "none",
              borderRadius: "10px",
              fontSize: "14px",
              fontWeight: 600,
              cursor: isSubmitting ? "not-allowed" : "pointer",
              opacity: isSubmitting ? 0.7 : 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: "8px",
              boxShadow: "0 2px 8px rgba(79, 70, 229, 0.25)",
              transition: "all 0.15s ease",
              marginTop: "4px",
              fontFamily: "'Instrument Sans Variable', sans-serif",
            }}
            onMouseEnter={e => {
              if (!isSubmitting) (e.currentTarget as HTMLButtonElement).style.background = "#4338CA";
            }}
            onMouseLeave={e => {
              if (!isSubmitting) (e.currentTarget as HTMLButtonElement).style.background = "#4F46E5";
            }}
          >
            {isSubmitting ? (
              <>
                <Loader2 style={{ width: "16px", height: "16px", animation: "spin 1s linear infinite" }} />
                Signing in...
              </>
            ) : (
              <>
                Sign in
                <ArrowRight style={{ width: "15px", height: "15px" }} />
              </>
            )}
          </button>
        </form>

        {/* Demo Account Pills (Quick Fill) */}
        <div style={{
          marginTop: "28px",
          paddingTop: "20px",
          borderTop: "1px solid #F0EEE9",
        }}>
          <div style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: "5px",
            fontSize: "11px",
            fontWeight: 600,
            color: "#A8A29E",
            textTransform: "uppercase",
            letterSpacing: "0.05em",
            marginBottom: "12px",
          }}>
            <KeyRound style={{ width: "12px", height: "12px" }} />
            Quick Demo Login
          </div>

          <div style={{ display: "flex", gap: "8px" }}>
            <button
              type="button"
              onClick={() => fillDemo("admin@example.com")}
              style={{
                flex: 1,
                padding: "7px 10px",
                background: "#F8F7F4",
                border: "1px solid #E7E5E0",
                borderRadius: "8px",
                fontSize: "12px",
                fontWeight: 500,
                color: "#44403C",
                cursor: "pointer",
                transition: "all 0.15s ease",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "4px",
              }}
              onMouseEnter={e => {
                e.currentTarget.style.background = "#EEF2FF";
                e.currentTarget.style.borderColor = "#C7D2FE";
                e.currentTarget.style.color = "#4338CA";
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = "#F8F7F4";
                e.currentTarget.style.borderColor = "#E7E5E0";
                e.currentTarget.style.color = "#44403C";
              }}
            >
              <ShieldCheck style={{ width: "12px", height: "12px", color: "#4F46E5" }} />
              Admin
            </button>

            <button
              type="button"
              onClick={() => fillDemo("agent@example.com")}
              style={{
                flex: 1,
                padding: "7px 10px",
                background: "#F8F7F4",
                border: "1px solid #E7E5E0",
                borderRadius: "8px",
                fontSize: "12px",
                fontWeight: 500,
                color: "#44403C",
                cursor: "pointer",
                transition: "all 0.15s ease",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "4px",
              }}
              onMouseEnter={e => {
                e.currentTarget.style.background = "#ECFDF5";
                e.currentTarget.style.borderColor = "#A7F3D0";
                e.currentTarget.style.color = "#065F46";
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = "#F8F7F4";
                e.currentTarget.style.borderColor = "#E7E5E0";
                e.currentTarget.style.color = "#44403C";
              }}
            >
              Agent
            </button>
          </div>
        </div>

      </div>

      {/* Footer text */}
      <p style={{
        marginTop: "24px",
        fontSize: "12px",
        color: "#A8A29E",
        position: "relative",
        zIndex: 10,
      }}>
        Helpdesk Platform &copy; {new Date().getFullYear()}
      </p>
    </div>
  );
}
