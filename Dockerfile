# ================== BUILD STAGE ==================
FROM node:20-alpine AS builder
WORKDIR /app

# --- system deps for native modules (bcrypt, esbuild) ---
RUN apt-get update && apt-get install -y \
  python3 \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

# --- enable pnpm (LOCK VERSION) ---
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# --- install deps (FULL deps, no frozen to avoid lock mismatch) ---
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# --- copy source ---
COPY . .

# --- build NestJS ONLY ---
RUN pnpm build


# ================== RUNTIME STAGE ==================
FROM node:20-alpine
WORKDIR /app

# --- system deps (bcrypt runtime safety) ---
RUN apt-get update && apt-get install -y \
  python3 \
  && rm -rf /var/lib/apt/lists/*

# --- enable pnpm (same version) ---
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# --- install prod deps ---
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod

# --- copy build output ---
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

# --- Prisma ONLY runs at runtime (Render injects env here) ---
CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
