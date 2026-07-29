# ── Stage 1: Build the Vite app ──────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# Copy core package first (shared dependency)
COPY core/package.json core/
COPY core/src core/src/
COPY core/tsconfig.json core/

# Copy client package files
COPY client/package.json client/
COPY client/package-lock.json* client/

# Install core dependencies
WORKDIR /app/core
RUN npm install

# Install client dependencies
WORKDIR /app/client
RUN npm install

# Copy client source
WORKDIR /app
COPY client/ client/

# Build the Vite app
WORKDIR /app/client
RUN npm run build

# ── Stage 2: Serve with Nginx ────────────────────────────
FROM nginx:alpine AS production

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy the nginx config template
COPY client/nginx.conf.template /etc/nginx/templates/default.conf.template

# Copy built static files
COPY --from=build /app/client/dist /usr/share/nginx/html

# Railway uses $PORT, nginx needs to listen on it
# We'll use envsubst to replace BACKEND_URL at runtime
ENV BACKEND_URL=http://localhost:3001
ENV PORT=80

EXPOSE 80

# Start nginx with env substitution
CMD ["sh", "-c", "envsubst '${BACKEND_URL} ${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
