# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder
WORKDIR /app

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

# dummy env just to satisfy Prisma
ENV DATABASE_URL="postgresql://user:pass@localhost:5432/db"

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm prisma generate --schema=prisma/schema.prisma
RUN pnpm build

# ---------- PROD STAGE ----------
FROM node:20-alpine
WORKDIR /app

RUN corepack enable
RUN pnpm config set enable-pre-post-scripts true

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main.js"]
