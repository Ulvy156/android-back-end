# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@10.28.1 --activate

# workspace + deps
COPY package.json pnpm-lock.yaml ./
RUN printf "packages:\n  - '.'\n" > pnpm-workspace.yaml
RUN pnpm config set enable-pre-post-scripts true
RUN pnpm install --frozen-lockfile

# prisma schema + generate (for TS build only)
COPY prisma ./prisma/
RUN DATABASE_URL="postgresql://dummy:dummy@127.0.0.1:5432/dummy" \
    pnpm exec prisma generate --schema=prisma/schema.prisma

# app source + build
COPY . .
RUN pnpm build

# prune dev deps
RUN pnpm prune --prod


# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

# copy runtime essentials only
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/prisma.config.ts ./prisma.config.ts

USER node
EXPOSE 3000

# We point directly to the config file to stop Prisma from guessing
CMD ["sh", "-c", "./node_modules/.bin/prisma migrate deploy && node dist/src/main.js"]
