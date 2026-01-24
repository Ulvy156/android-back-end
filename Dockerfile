# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# 1. System deps for native modules (bcrypt, sharp, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup pnpm
RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

# 3. Copy config files first (Layer caching win)
COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma/

# 4. Install all deps (including dev)
# If this fails, run 'pnpm install' locally to sync your lockfile!
RUN pnpm install --frozen-lockfile

# 5. Copy source and build
COPY . .
RUN pnpm build

# 6. Generate Prisma Client & cleanup devDependencies
RUN pnpm prisma generate
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app

ENV NODE_ENV=production

# 7. Copy only the essentials from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma

# 8. Security: Don't run as root
USER node

EXPOSE 3000

# 9. Startup: Apply migrations then launch
# 'migrate deploy' is the move for production
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]