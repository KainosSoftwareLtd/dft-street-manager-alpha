var raster = new ol.layer.Tile({
  source: new ol.source.OSM()
})



var map = new ol.Map({
  layers: [raster],
  target: 'map',
  view: new ol.View({
    center: ol.proj.fromLonLat([-0.25, 51.5074]),
    zoom: 11
  })
})

const position = new ol.source.Vector()
const vector = new ol.layer.Vector({
  source: position
})
map.addLayer(vector)

vector.setStyle(new ol.style.Style({
  image: new ol.style.Icon({
    src: '/images/map-marker-red.png'
  })
}))

var coords = document.getElementById('coords').innerText

if (coords) {
  var parsedCoords = JSON.parse(coords)
  parsedCoords.forEach(function(coord) {
    position.addFeature(new ol.Feature(new ol.geom.Point(ol.proj.fromLonLat([coord.y1, coord.x1]))))
  })
}

//var coord = [-27437.90733296088, 6711495.343644402]
//position.addFeature(new ol.Feature(new ol.geom.Point(coord)))
//position.addFeature(new ol.Feature(new ol.geom.Point(ol.proj.fromLonLat([-0.25, 51.5074]))))

map.on('click', function (evt) {
  var coords = ol.proj.toLonLat(evt.coordinate)
  var lat = coords[1]
  var lon = coords[0]
  document.getElementById('lat').value = lat
  document.getElementById('lon').value = lon
})
