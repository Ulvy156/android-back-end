# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# 1. Essential system deps for Prisma/Native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup pnpm
RUN corepack enable && corepack prepare pnpm@9.12.0 --activate

# 3. Copy config files (The fix for your error is here)
COPY package.json pnpm-lock.yaml ./
# If you have a pnpm-workspace.yaml, this MUST be here
COPY pnpm-workspace.yaml* ./ 
COPY prisma ./prisma/

# 4. Install all deps (including dev)
RUN pnpm install --frozen-lockfile

# 5. Copy source and build NestJS
COPY . .
RUN pnpm build

# 6. Generate Prisma Client and strip devDependencies
RUN pnpm prisma generate
RUN pnpm prune --prod

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app

# Set to prod mode
ENV NODE_ENV=production

# 7. Copy only what's needed for the app to run
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma

# 8. Security: Run as non-root user
USER node

EXPOSE 3000

# 9. Startup sequence
# 'migrate deploy' keeps your DB in sync without wiping it
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]