# Build
```
docker build -t local/geoserver .
```

# Run
```
docker run -p 8080:8080 -v $(pwd)/data:/var/lib/geoserver_data local/geoserver \
  -e PG_HOST=... -e PG_PORT=... -e PG_DATABASE=... -e PG_USER=... -e PG_PASSWORD=...
open http://localhost:8080/geoserver
```

Default JAVA_OPTS="-server -Xms1g -Xmx1g".

# data directory
This data directory is not really released/deployed any further. For more deatils how do we manage GeoServer configuration please contact Ops Team.
