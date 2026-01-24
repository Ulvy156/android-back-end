# ================ BUILD STAGE ================
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# system deps for native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

# pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# install deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# copy source + build
COPY . .
RUN pnpm build

# ================ RUNTIME STAGE ================
FROM node:20-bullseye-slim
WORKDIR /app

# runtime small deps (if bcrypt needs python at runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  && rm -rf /var/lib/apt/lists/*

# pnpm
RUN corepack enable
RUN corepack prepare pnpm@9.12.0 --activate

# prod deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod

# copy build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

ENV NODE_ENV=production
EXPOSE 3000

CMD ["sh", "-c", "pnpm prisma generate && pnpm prisma migrate deploy && pnpm prisma db seed && node dist/main.js"]
