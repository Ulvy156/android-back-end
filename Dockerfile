# ---------- BUILD STAGE ----------
FROM node:20-slim AS builder
WORKDIR /app

# enable pnpm
RUN corepack enable

# install deps (FULL deps, including prisma + ts)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# copy source
COPY . .

# build NestJS ONLY
# ❌ NO PRISMA HERE
RUN pnpm build


# ---------- PRODUCTION STAGE ----------
FROM node:20-alpine
WORKDIR /app

RUN corepack enable

# install prod deps (prisma MUST be in dependencies)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# copy build + prisma files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

# Prisma ONLY runs here (Render env exists here)
CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
