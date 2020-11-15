# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile.multistage

# Stage 1: Building the code
FROM mhart/alpine-node AS builder
ARG GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
ARG BASE_REPO_FULL_NAME=${BASE_REPO_FULL_NAME}
ARG GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
ARG SIGNING_KEY=${SIGNING_KEY}

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build
#RUN yarn install --production --frozen-lockfile


# Stage 2: And then copy over node_modules, etc from that stage to the smaller base image
FROM mhart/alpine-node:base as production

WORKDIR /app

# COPY package.json next.config.js .env* ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

ENTRYPOINT ["node_modules/.bin/next", "start"]
