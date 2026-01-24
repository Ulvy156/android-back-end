# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder
WORKDIR /app

# enable pnpm
RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

# deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# source
COPY . .

# build NestJS only (NO prisma here)
RUN pnpm build


# ---------- PROD STAGE ----------
FROM node:20-alpine
WORKDIR /app

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

# prod deps only
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# app files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

# Prisma runs at runtime when env vars exist
CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
