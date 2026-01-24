# ================== BUILD STAGE ==================
FROM node:20-slim AS builder
WORKDIR /app

# lock pnpm version (important)
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# install deps (FULL deps, incl prisma + ts)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# copy source
COPY . .

# build NestJS ONLY
# ❌ NO PRISMA HERE
RUN pnpm build


# ================== RUNTIME STAGE ==================
FROM node:20-slim
WORKDIR /app

RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# install prod deps (prisma MUST be in dependencies)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod

# copy build output + prisma files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

# Prisma runs ONLY at runtime (DATABASE_URL exists here)
CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
