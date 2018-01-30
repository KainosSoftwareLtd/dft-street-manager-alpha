# OpenLayers example app with persistence

Proof of concept to draw a point and persist that to a postgis instance.

Simple Node Express app based on the examples [here](https://openlayers.org/en/latest/examples/index.html).

![screenshot](https://raw.githubusercontent.com/KainosSoftwareLtd/dft-street-manager-alpha/master/proof-of-concepts/example-app-openlayers-persist-postgis/public/images/screenshot.png)

## Requires

 * Docker 17.05 or higher on the daemon and client is required (for example [docker4mac](https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac)).

## Run

```
docker-compose up --build (you will see logs)
- or -
docker-compose up -d --build (you won't see logs)
open http://localhost:3000
```

## Stop

```
docker-compose stop
docker-compoe rm
```
