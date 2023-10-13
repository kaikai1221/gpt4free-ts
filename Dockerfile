# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=18.16.0
FROM node:${NODE_VERSION}-slim as base

LABEL fly_launch_runtime="NodeJS"

# NodeJS app lives here
WORKDIR /app

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build node modules
RUN apt-get update -qq && \
    apt-get install -y python-is-python3 pkg-config build-essential 


WORKDIR /usr/src/build

COPY --chown=pptruser package.json /usr/src/build/

RUN npm i --registry=https://registry.npm.taobao.org

COPY --chown=pptruser . /usr/src/build

RUN npm run build && \
    find ./dist -name "*.js" -exec npx terser {} -o {} \; && \
    mkdir -p /usr/src/app && \
    cp -r ./dist/* /usr/src/app/ && \
    cp -r ./node_modules /usr/src/app/ && \
    rm -rf /usr/src/build

WORKDIR /usr/src/app

COPY run /usr/src/app/

VOLUME [ "/usr/src/app/run" ]

EXPOSE 3000

CMD ["node", "index.js"]