# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder
WORKDIR /app

# enable pnpm
RUN corepack enable

# copy lock + manifest
COPY package.json pnpm-lock.yaml ./

# install deps
RUN pnpm install --frozen-lockfile

# copy source
COPY . .

# prisma + build
RUN pnpm prisma generate
RUN pnpm build
RUN pnpm prisma migrate deploy
RUN pnpm prisma db seed

# ---------- PROD STAGE ----------
FROM node:20-alpine
WORKDIR /app

RUN corepack enable

# install prod deps only
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# copy build output + prisma engine
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main.js"]
