# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@10.28.1 --activate

# 1. Setup workspace & install deps (The Cache layer)
COPY package.json pnpm-lock.yaml ./
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml
RUN pnpm install --frozen-lockfile

# 2. Copy Prisma folder and GENERATE BEFORE BUILD
# NestJS needs the generated types in node_modules to compile dist
COPY prisma ./prisma/
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" pnpm prisma generate

# 3. Copy source and build
COPY . .
# We force the workspace file AGAIN because 'COPY . .' might have deleted it
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml
RUN pnpm build

# 4. Cleanup dev deps
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma

USER node
EXPOSE 3000


# We explicitly pass the DATABASE_URL and the schema path to the binary.
# This overrides any config-file confusion in Prisma v7.
CMD ["sh", "-c", "./node_modules/.bin/prisma migrate deploy --schema=./prisma/schema.prisma && node dist/src/main.js"]
