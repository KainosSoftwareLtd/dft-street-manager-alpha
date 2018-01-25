# OpenLayers example app with persistence

Proof of concept to draw a point and persist that to a postgis instance.

Simple Node Express app based on the examples [here](https://openlayers.org/en/latest/examples/index.html).

![screenshot](https://raw.githubusercontent.com/KainosSoftwareLtd/dft-street-manager-alpha/master/proof-of-concepts/example-app-openlayers-persist-postgis/public/images/screenshot.png)

## Requires

* NodeJS
* PostGIS DB (see below)

## Run

```
npm install
npm start
# runs at http://localhost:3000
```

### PostGIS

The application requires a PostGres Database with PostGIS extensions installed and a table `points` setup via the script `create_table_points.sql`.

You can use the Docker command below to create a PostGres Database instance with database created and default credentials used by the application using the following command:

```
docker run --name "postgis" -p 5432:5432 -d -t kartoza/postgis:9.4-2.1
```

Otherwise set the env values below to access your own PostGIS database:

```
export PG_USER = 'docker'
export PG_HOST = 'localhost'
export PG_DATABASE = 'gis'
export PG_PASSWORD = 'docker'
export PG_PORT = '5432'
```
