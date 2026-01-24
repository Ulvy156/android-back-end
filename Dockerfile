# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# system deps for native modules + prisma engine handling
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# deps (full, incl dev for prisma generate)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# copy + generate + build
COPY prisma ./prisma/
COPY . .
RUN pnpm prisma generate   # or npx prisma generate if pnpm bin acts weird
RUN pnpm build

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim

WORKDIR /app

# minimal runtime deps (only if bcrypt/sharp/etc needs it; drop python3 if not)
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# prod deps only
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# copy artifacts + prisma schema (for migrate) + generated client is in node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# If client still missing (rare with pnpm), add this explicit copy:
# COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
# COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

ENV NODE_ENV=production

EXPOSE 3000

# No generate needed anymore!
CMD ["sh", "-c", "pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]