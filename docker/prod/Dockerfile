# Base image for building the application
FROM node:18-alpine AS base

# Define the application directory as a build argument
ARG APP_DIR=/hacktrack-testing

FROM base AS deps
RUN apk add --no-cache libc6-compat

# Set the working directory
WORKDIR $APP_DIR

# Install pnpm globally
RUN npm install -g pnpm

# Copy package.json and pnpm-lock.yaml to the container
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

RUN \
  if [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then \
    npm ci; \
  elif [ -f pnpm-lock.yaml ]; then \
    pnpm install --frozen-lockfile; \
  else \
    echo "Lockfile not found." && exit 1; \
  fi

FROM base AS dev

# Set the working directory
WORKDIR $APP_DIR

COPY --from=deps $APP_DIR/node_modules ./node_modules

# Copy all project files to the container
COPY . .

# Rebuild the source code only when needed
FROM base AS builder

# Set the working directory
WORKDIR $APP_DIR

COPY --from=deps $APP_DIR/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

# Install pnpm globally
RUN npm install -g pnpm

# Compile TypeScript to JavaScript and build the application in standalone mode
RUN pnpm run build

# Remove devDependencies
RUN pnpm prune --prod

# Production image, copy all the files and run next
FROM base AS runner

# Set the working directory
WORKDIR $APP_DIR

ENV NODE_ENV production

# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder $APP_DIR/public ./public
COPY --from=builder --chown=nextjs:nodejs $APP_DIR/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs $APP_DIR/.next/static ./.next/static

# Copy the .env.production to .env to ensure only production variables are used
COPY .env.production .env

FROM runner AS production

# Set the working directory
WORKDIR $APP_DIR

USER nextjs

EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"
ENV NODE_ENV production

CMD ["node", "/hacktrack-testing/server.js"]
