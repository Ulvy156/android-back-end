# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# System deps for native modules (bcrypt, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma/

# 1. Install all deps and generate the Prisma Client
RUN pnpm install --frozen-lockfile
RUN pnpm prisma generate

COPY . .
# 2. Build the NestJS app
RUN pnpm build

# 3. Prune devDependencies to keep the image slim
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app

# Set to production
ENV NODE_ENV=production

# 4. Copy only what's needed for execution
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma

# 5. Security: Run as non-root user
USER node

EXPOSE 3000

# 6. Optimized startup
# Use 'prisma migrate deploy' for prod (it's faster/safer than 'dev')
# Note: In a scaled environment, move migrations to your CI/CD pipeline
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]