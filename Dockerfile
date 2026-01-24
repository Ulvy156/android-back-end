# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# 1. Install system deps ONCE (This rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

# 2. ONLY copy files needed for install (The "Cache Win")
COPY package.json pnpm-lock.yaml ./
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml

# 3. Install deps BEFORE copying source code
# Now, if you change a .ts file, Docker skips this step entirely!
RUN pnpm install --frozen-lockfile

# 4. Copy Prisma and generate client (Before full source copy)
COPY prisma ./prisma/
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" pnpm prisma generate

# 5. Copy the rest of the source and build
COPY . .
RUN pnpm build

# 6. Prune for production
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

# Copy from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma

USER node
EXPOSE 3000

# runtime: generate (if needed), run migrations & seed, then start app
# use pnpm exec to avoid workspace resolution issues and avoid 'npx'.
CMD ["sh", "-c", "pnpm exec prisma generate --schema=prisma/schema.prisma && pnpm exec prisma migrate deploy --schema=prisma/schema.prisma && pnpm exec prisma db seed --schema=prisma/schema.prisma && node dist/main.js"]