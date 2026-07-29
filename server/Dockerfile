# ── Stage 1: Install dependencies ────────────────────────
FROM oven/bun:1 AS install

WORKDIR /app

# Copy root-level package files
COPY package.json ./

# Copy core package
COPY core/package.json core/
COPY core/src core/src/
COPY core/tsconfig.json core/

# Copy server package files
COPY server/package.json server/
COPY server/bun.lock server/
COPY server/prisma/ server/prisma/
COPY server/prisma.config.ts server/

# Install core dependencies
WORKDIR /app/core
RUN bun install

# Install server dependencies
WORKDIR /app/server
RUN bun install

# ── Stage 2: Production ─────────────────────────────────
FROM oven/bun:1 AS production

WORKDIR /app

# Copy core package
COPY core/ core/

# Copy server source and installed deps
COPY server/ server/
COPY --from=install /app/server/node_modules server/node_modules

WORKDIR /app/server

# Generate Prisma client
RUN bun prisma generate

# Expose port
ENV PORT=3001
EXPOSE 3001

# Start script: push schema + run server
CMD ["sh", "-c", "bun prisma migrate deploy && bun run src/index.ts"]
