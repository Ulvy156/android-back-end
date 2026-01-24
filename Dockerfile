# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml

RUN pnpm install --frozen-lockfile

COPY . .
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml

# THE FIX: Provide a fake DATABASE_URL so Prisma can generate the client
# This doesn't need to be your real DB string; it just needs to be a valid format.
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy" pnpm prisma generate

RUN pnpm build
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

# At runtime, the container WILL need the real DATABASE_URL 
# passed in via docker-compose or your cloud provider.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]