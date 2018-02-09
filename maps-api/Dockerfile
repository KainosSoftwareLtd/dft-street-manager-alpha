# Base
FROM alpine:3.7 AS base

RUN apk upgrade --no-cache && \
    apk add --no-cache \
      nodejs \
      nodejs-npm \
      tini \
    && \
    adduser -D nodejs

WORKDIR /opt/app
ENTRYPOINT ["/sbin/tini", "--"]
COPY package.json .
COPY package-lock.json .

# Deps
FROM base AS dependencies
RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production
RUN cp -R node_modules prod_node_modules
RUN npm install

# Tests
FROM dependencies AS test
COPY . .
#RUN npm test

# Final image
FROM base AS release
COPY --from=dependencies /opt/app/prod_node_modules ./node_modules
COPY . .
RUN chown nodejs:nodejs -R /opt/app
USER nodejs
EXPOSE 8000
CMD npm run start
