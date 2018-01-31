# Base
FROM alpine:3.7 AS base
RUN apk add --no-cache nodejs nodejs-npm tini
WORKDIR /root/app
ENTRYPOINT ["/sbin/tini", "--"]
COPY package.json .
COPY package-lock.json .

ENV PG_USER="docker"
ENV PG_HOST="localhost"
ENV PG_DATABASE="gis"
ENV PG_PASSWORD="docker"
ENV PG_PORT="5432"

# Deps
FROM base AS dependencies
RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production
RUN cp -R node_modules prod_node_modules
RUN npm install

# Tests
FROM dependencies AS test
COPY . .
RUN npm test

# Final image
FROM base AS release
COPY --from=dependencies /root/app/prod_node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD npm run start
