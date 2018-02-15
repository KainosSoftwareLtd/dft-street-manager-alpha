# DfT Street Manager UX prototype

This repository is forked off [alphagov/govuk_prototype_kit](https://github.com/alphagov/govuk_prototype_kit).

## About

This is a simple UX prototype and style guide for the DfT Street Manager service, intended to help share designs and patterns.

## Requires

* [Node JS](https://nodejs.org)

## Run
**NOTE:**
* Docker 17.05 or higher on the daemon and client is required (for example [docker4mac](https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac)).
* Delete existing node_module folder if you already run `npm install` locally to prevent issues starting container with incompatible libraries

```
./start_dev.sh
# open browser to http://localhost:3000
```

If for any reason you need to shell into container, use:

`docker exec -it $(docker ps|grep local/dft-street-manager-ux|cut -d" " -f1) /bin/sh`

Restart:

`docker kill $(docker ps|grep local/dft-street-manager-ux|cut -d" " -f1)`

Stop:

`docker kill $(docker ps|grep local/dft-street-manager-ux|cut -d" " -f1)`

**NOTE: If you need to regenerate SASS files, plese restart (or stop and run again) container.**

## Creating a new iteration

1. Copy previous iteration folder to create new folder for views, e.g. `/app/views/alpha/v1-0` to `/app/views/alpha/v1-1`
2. Update `/app/views/index.html` with link and header to new iteration

See `/docs/views/examples` for page examples and [prototype documentation](https://govuk-prototype-kit.herokuapp.com/docs/tutorials-and-examples) for details on how to handle interactions.

## Env variables

| Name | Default |
|------|---------|
| MAP_API_URL | http://localhost:8080 |