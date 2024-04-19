ARG NODE_VERSION=20.12.2

FROM node:${NODE_VERSION}-slim

RUN apt-get update && apt-get install -y openssl

WORKDIR /app

# DATABASE_URL environment variable takes precedence over .env file configuration
ENV DATABASE_URL=file:/app/sqlite/chatollama.sqlite

COPY pnpm-lock.yaml package.json ./
RUN npm install -g pnpm
RUN pnpm i

COPY . .

# Make sure .env file is present
RUN if [ -f /app/.env ]; then \
  echo ".env file exists"; \
  else \
  echo "" > .env; \
  fi

RUN pnpm run prisma-generate
RUN pnpm run prisma-migrate
RUN pnpm run build

EXPOSE 3000

# Nodejs 20.6.0+ supports env-file
# https://nodejs.org/dist/latest-v20.x/docs/api/cli.html#--env-fileconfig
CMD ["node", "--env-file=.env", ".output/server/index.mjs"]
