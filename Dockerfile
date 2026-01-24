# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# Install build tools (for native deps + Prisma reliability)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Setup pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# Skip Prisma auto-generate in postinstall (avoids weird fails)
ENV PRISMA_SKIP_POSTINSTALL_GENERATE=true

# Copy dep files first for caching
COPY package.json pnpm-lock.yaml ./

# Install ALL deps (dev included for generate + build)
RUN pnpm install --frozen-lockfile

# Copy Prisma schema + source
COPY prisma ./prisma/
COPY . .

# Generate Prisma Client (only here!)
RUN pnpm prisma generate

# Build the NestJS app
RUN pnpm build

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim

WORKDIR /app

# Minimal runtime deps (drop python/build-essential if no bcrypt/sharp/etc)
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Setup pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# Copy dep files + install PROD deps only
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Copy built stuff + Prisma schema (needed for migrate deploy)
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# If Prisma client missing at runtime (rare with pnpm), uncomment these:
# COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
# COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

ENV NODE_ENV=production

EXPOSE 3000

# Startup: migrate + seed + run app (no generate needed!)
CMD ["sh", "-c", "pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]