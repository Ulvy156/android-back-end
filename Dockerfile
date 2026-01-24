# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

# 1. Copy the core config files
COPY package.json pnpm-lock.yaml ./

# 2. THE FIX: Create a workspace file if it doesn't exist 
# This tells pnpm "Yes, the current folder is the only package"
RUN echo "packages:\n  - '.'" > pnpm-workspace.yaml

COPY prisma ./prisma/

# 3. Now install should work without the "packages field" error
RUN pnpm install --frozen-lockfile

# 4. Copy the rest and build
COPY . .
RUN pnpm build
RUN pnpm prisma generate
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
# (Keep the runtime stage exactly the same as before)
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
USER node
EXPOSE 3000
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]