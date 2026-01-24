# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Add these for alpine + prisma reliability
RUN apk add --no-cache python3 make g++ gcc libc6-compat openssl libssl3

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY prisma ./prisma/
COPY . .

# Generate client HERE (only once)
RUN npx prisma generate

# Build app
RUN pnpm build

# ---------- PRODUCTION STAGE ----------
FROM node:20-alpine

WORKDIR /app

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

COPY package.json pnpm-lock.yaml ./
# Install only production deps → generated client gets copied over from builder
RUN pnpm install --prod --frozen-lockfile

# Copy built files + prisma schema (for migrate) + generated client lives in node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
# Optional: copy node_modules/.prisma if needed, but usually pnpm install --prod + build artifacts enough

ENV NODE_ENV=production

EXPOSE 3000

# Now you only need migrate + seed + start (no generate!)
CMD ["sh", "-c", "npx prisma migrate deploy && npx prisma db seed && node dist/main.js"]