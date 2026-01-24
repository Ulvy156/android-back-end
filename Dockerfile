# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder
WORKDIR /app

# enable pnpm
RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

# copy only lock + manifest for caching
COPY package.json pnpm-lock.yaml ./

# install all dependencies
RUN pnpm install --frozen-lockfile

# copy all files
COPY . .

# build NestJS app only
RUN pnpm build

# ---------- PRODUCTION STAGE ----------
FROM node:20-alpine
WORKDIR /app

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

# copy dep files
COPY package.json pnpm-lock.yaml ./

# install prod deps only
RUN pnpm install --prod --frozen-lockfile

# copy build artifacts from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

# at startup: generate Prisma client, run migrations & seed, then start the app
CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
