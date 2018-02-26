# dft-street-manager-alpha
Repo for the DfT Street Manager alpha project

## Works database

The works database for the technical prototype is a single table in PostGis with the column to hold the shape geometry and some works data fields. 

Works table

| column | type |
|------|------|
| p_id | int |
| work_reference_number | varchar |
| promoter_name | varchar |
| start_date | Date |
| end_date | Date |
| works_category | varchar |
| the_geom | geometry |

Only a subset of the fields that will be used to create a work in Street Manager will be used for this prototype as it will be used to prove filtering and the operation of the API.
The create table command is detailed below:

```
CREATE TABLE works (
  p_id INTEGER PRIMARY KEY,
  work_reference_number VARCHAR,
  promoter_name VARCHAR,
  start_date DATE,
  end_date DATE,
  works_category VARCHAR
);
```

A specific PostGIS command will be used to add the geometry column to the table:
```
SELECT AddGeometryColumn('works','the_geom','3857','POINT',2);
```
For the technical prototype, this geometry is just a point, and will use the SRID Projection of 3857 as this is the default ‘web’ projection used by most online mapping services. This will likely change for the real implementation but it will work for our needs.

## Maps API

The Maps API project is a node application that will expose two rest endpoints that can be used to create works in the database or search for works.

The API project uses express and postgres (‘pg’) modules to communicate with the database.

The connection parameters to the database are specified in the db.js, and they can be provided as node environment variables.

The two endpoints are can be found in the file work_routes.js

### Create Works

The Create Works endpoint (/works) is a POST method that expects the following information to be posted as form fields:

startdateday

startdatemonth

startdateyear

enddateday

enddatemonth

enddateyear

workreferencenumber

promotername

workcategorygroup

coords (provided as GeoJSON string)


The method uses pgPool object to get a postgres database connection from the pool. 
```
return client.query('select max(p_id) from works')
```

The first task this method does is retrieves the max id from the table in order to get the id for the next row item.

```
const query = {
    text: 'INSERT INTO works(p_id, work_reference_number, promoter_name, start_date, end_date, works_category, the_geom)' +
    'VALUES($1, $2, $3, to_date($4, \'DD/MM/YYY\'), to_date($5, \'DD/MM/YYY\'), $6, ST_SetSRID(ST_GeomFromGeoJSON($7), 3857));',
    values: [pid, req.body.workreferencenumber, req.body.promotername, startDate, endDate, req.body.workcategorygroup, req.body.coords]
}
```

node-postgres provides good support for parameter substitution so the insert statement will look like the above. This is standard sql statement apart from the value to insert the GeoJSON works co-ordinates.

The PostGIS command ST_GeomFromGeoJSON($7) is used to convert the GeoJSON coordinates into a PostGIS geometry object. This statement is wrapped in another PostGIS statement to set the correct projection: ST_SetSRID(ST_GeomFromGeoJSON($7), ‘3857’) which will set the projection to ESP3857.

### Retrieve Works

The retrieve works endpoint (/allworks) is a GET method that retrieves work information from the database. The following items may be entered as filter values but at least one filter value must be added.
workcategory  (multiple values can be provided)

startDate

endDate

extent (bounding box coordinates)

e.g. 
```
http://localhost:8000/allworks?workcategory=Standard&workcategory=Major&startDate=01/01/2018&endDate=31/12/2018&extent=-33023.30717557531,6709632.77402439,-26578.71022828139,6712317.624642907
```

The extent filter is populated at the start of the method as below:
```
var extentFilter = 'ST_MakeEnvelope(' + req.query.extent + ')';
```

The ST_MakeEnvelope command converts the bounding box extent into a PostGIS geometry.

The query text is as follows:
```
SELECT jsonb_build_object('type','FeatureCollection','features', jsonb_agg(feature))
FROM (
SELECT jsonb_build_object('type', 'Feature','id', p_id,'geometry', ST_AsGeoJSON(the_geom)::jsonb,'properties', to_jsonb(row) - 'p_id' - 'the_geom'  ) AS feature  
FROM (
SELECT p_id, work_reference_number, promoter_name, to_char(start_date, \'DD/MM/YYYY\') as start_date, to_char(end_date, \'DD/MM/YYYY\') as end_date, works_category, the_geom 
FROM works 
where works_category = ANY($1) AND (start_date, end_date) OVERLAPS (to_date($2, 'DD/MM/YYYY'), to_date($3, 'DD/MM/YYYY')) AND the_geom && " + extentFilter + ") row) features;
```

Unravelling this query, the following selects the rows from the works database that will be returned:
```
SELECT p_id, work_reference_number, promoter_name, to_char(start_date, \'DD/MM/YYYY\') as start_date, to_char(end_date, \'DD/MM/YYYY\') as end_date, works_category, the_geom 
FROM works 
where works_category = ANY($1) AND (start_date, end_date) OVERLAPS (to_date($2, 'DD/MM/YYYY'), to_date($3, 'DD/MM/YYYY')) AND the_geom && " + extentFilter + ") row;
```

The ‘where‘ clause is where the filtering of records is done and is filtered on 3 fields:

1)	Works category: works_category = ANY($1) This uses postgres ANY statement for checking if the value matches any of the values supplied in the array.

2)	Start and End Date: (start_date, end_date) OVERLAPS (to_date($2, 'DD/MM/YYYY'), to_date($3, 'DD/MM/YYYY')) This clause checks if the works start and end dates overlaps with the provided start and end date

3)	Extent Filter: the_geom && " + extentFilter + " This clause checks if any part of the geometry object of the row overlaps with the extent of the map.

This query will return the rows that match the filter clause.

```
SELECT jsonb_build_object('type', 'Feature','id', p_id,'geometry', ST_AsGeoJSON(the_geom)::jsonb,'properties', to_jsonb(row) - 'p_id' - 'the_geom'  ) AS feature  
FROM ( ) row
```

The next part of the query will build a JSON object from the output specifying the following items:

type: Feature

id: p_id of the row

geometry: ST_AsGeoJSON(the_geom) This PostGIS command converts the geometry object to a GeoJSON object

properties: to_jsonb(row) – ‘p_id’ – ‘the_geom’  This command will add all columns to the properties element of the json except the id and the geometry columns as they are used elsewhere.

The final part of this query will wrap all the JSON objects which have been created for each row into a single JSON object to be returned and sets the type as FeatureCollection:

```
SELECT jsonb_build_object('type','FeatureCollection','features', jsonb_agg(feature))
FROM ();
```

The returned JSON object will look like the below:
```
{
    "type": "FeatureCollection",
    "features": [
        {
            "id": 7,
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [
                    -27696.0046026686,
                    6711411.12926059
                ]
            },
            "properties": {
                "end_date": "10/09/2018",
                "start_date": "09/09/2018",
                "promoter_name": "Poaoaoa",
                "works_category": "Standard",
                "work_reference_number": "CT2396976"
            }
        },
        {
            "id": 8,
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [
                    -27696.0046026686,
                    6711411.12926059
                ]
            },
            "properties": {
                "end_date": "10/09/2018",
                "start_date": "09/09/2018",
                "promoter_name": "Poaoaoa",
                "works_category": "Standard",
                "work_reference_number": "CT2396976"
            }
        }
    ]
}
```

## Street Manager UI

The UI project is based on the UX prototype we are developing as a demo application that is built in Node and Express. It is a slimmed down version of the UX prototype featuring a form that will capture a subset of the fields that are captured in the full UX prototype.

The starting point for this application is http://localhost:3000/tech-proto/map-search-results

The maps logic for connecting to the API is contained in map-search-results.html

### Displaying works

On initiation a GeoJSON layer is added to the OpenLayers map in order to display the works in the database:```

```
MAP_CONFIG.vector_source = new ol.source.Vector();

MAP_CONFIG.geojson_layer = new ol.layer.Vector({
  source: MAP_CONFIG.vector_source,
  style: styleFunction
})
```

The map screen works search can be initiated in two places on the screen by:

1)	Changing the layers:
```
$('input[name=layer-types]').change(function (event) {
    showWorks();
});
```

2)	Changing the dates on the slider:
```
$('#slider-id').slider({
  …
  change: function (event, ui) {
      startDate = ui.values[0];
      endDate = ui.values[1];
      showWorks();
  },
  …
});
```

When the search is initiated the showWorks() method will be initiated. The method detailed below will build up the query params from the UI controls on the screen, using the workcategory checkbox and the dates from the slider.

The map extent is retrieved using an OpenLayers method: map.getView().calculateExtent().

The query params are then sent to the /works request which will call the Maps API.

```
function showWorks() {
    var queryParams = []
    $('input[type=checkbox]').each(function () {
        if (this.checked) {
            var filter = 'workcategory=' + $(this).val();
            queryParams.push(filter)
        }
    });


    MAP_CONFIG.vector_source.clear();

    if(queryParams.length != 0){
        var startDateParam = 'startDate=' + (new Date(startDate *1000).toLocaleString('en-GB', dateOptions));
        queryParams.push(startDateParam)
        var endDateParam = 'endDate=' + (new Date(endDate *1000).toLocaleString('en-GB', dateOptions));
        queryParams.push(endDateParam)

        var extent = 'extent=' + map.getView().calculateExtent();
        queryParams.push(extent);

        var queryString = queryParams.join('&');

        fetch('/works?' + queryString, {
            method: 'GET',
        }).then(function (response) {
            return response.json();
        }).then(function (json) {
            var features = new ol.format.GeoJSON().readFeatures(json);
            MAP_CONFIG.vector_source.addFeatures(features);
        });
    }
}
```

In routes.js the configuration for /works retrieves the query params from the incoming request and routes them to the API works request:
```
router.get('/works', function(req, res) {
  var i = req.url.indexOf('?');
  var queryParams = req.url.substr(i+1);

  var options = {
    url: access.apiUrl + '/allworks?' + queryParams,
    method: 'GET'
  }

  request(options, function(err, response, body) {
    if (response && (response.statusCode === 200 || response.statusCode === 201)) {
      console.log(body);
      res.send(body);
    }
  });
})
```

The api url is configured in access.js and can also be configured in environment variables for the application.

The properties of the works features returned are also accessed on clicking of the markers in the map:
```
map.on('click', function(e) {
  overlay.setPosition();
  var features = map.getFeaturesAtPixel(e.pixel);
  if (features) {
    var coords = features[0].getGeometry().getCoordinates();
    var properties = features[0].getProperties();
    if(properties['work_reference_number']) {
        var string = 'WRN: ' + properties['work_reference_number'] + '<br/>' +
                'Promoter Name: ' + properties['promoter_name'] + '<br/>' +
                'Works Category: ' + properties['works_category'] + '<br/>' +
                'Start Date: ' + properties['start_date'] + '<br/>' +
                'End Date: ' + properties['end_date'];
        overlay.getElement().innerHTML = string;
        overlay.setPosition(coords);
    }
  }
});
```

### Adding works
In map_controls.js, functionality has been added to retrieve the GeoJSON text associated with the drawn polygon. The writer will retrieve the JSON text for the geometry and add this to a hidden form field so it will be part of the works created. 
```
MAP_CONTROLS.current_interaction.on('drawend', function (event) {
  …
  var writer = new ol.format.GeoJSON()
  var geojsonstr = writer.writeGeometry(event.feature.getGeometry())
  if (document.getElementById('geoJsonString') != null) {
    document.getElementById('geoJsonString').innerHTML = geojsonstr;
    $('#shapecoords').val(geojsonstr);
  }
})
```

Progressing through the application, the user will fill in form fields relating to the works and the route described in routes.js ('/tech-proto/confirm-permit-application') will post that work information to the Maps API.  This will simply take all the form fields and post them to the Map API create works request.

```
router.post('/tech-proto/confirm-permit-application', function (req, res) {

  var options = {
    url: access.apiUrl + '/works',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    form: req.body
  }

  request(options, function(err, res, body) {
    if (res && (res.statusCode === 200 || res.statusCode === 201)) {
      console.log(body);
    }
  });

  res.redirect('tech-proto/confirm-permit-application.html')
})
```
