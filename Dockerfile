# ================= BUILD STAGE =================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# system deps for prisma + node-gyp
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# pnpm
RUN corepack enable && corepack prepare pnpm@10.28.1 --activate

# deps
COPY package.json pnpm-lock.yaml ./
RUN printf "packages:\n  - '.'\n" > pnpm-workspace.yaml
RUN pnpm install --frozen-lockfile

# prisma generate (build-time only)
COPY prisma ./prisma/
RUN DATABASE_URL="postgresql://dummy:dummy@127.0.0.1:5432/dummy" \
    pnpm exec prisma generate

# app source + build
COPY . .
RUN pnpm build

# remove dev deps
RUN pnpm prune --prod


# ================= RUNTIME STAGE =================
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

# copy runtime artifacts only
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# run as non-root (Render-friendly)
USER node

# Render injects PORT automatically
EXPOSE 3000

# 🚫 NO prisma migrate here
# ✅ env vars are read at runtime
CMD ["node", "dist/src/main.js"]
