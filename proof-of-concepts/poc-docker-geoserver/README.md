# Build
```
docker build -t local/geoserver .
```

# Run
```
docker run -p 8080:8080 -v $(pwd)/data:/var/lib/geoserver_data local/geoserver
open http://localhost:8080/geoserver
```
