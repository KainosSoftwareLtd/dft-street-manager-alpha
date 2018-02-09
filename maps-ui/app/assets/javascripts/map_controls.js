var MAP_CONTROLS = {}

MAP_CONTROLS.current_interaction = null
MAP_CONTROLS.current_style = draw_layer_styles.NONE
// Used to generate IDs for newly created features
MAP_CONTROLS.feature_id = 0

// Toolbar Of Available Map Controls
MAP_CONTROLS.draw_controls = function () {
  var container = document.createElement('div')
  container.id = 'draw-controls'
  container.className = 'ol-control'
  container.appendChild(MAP_CONTROLS.point_button())
  ol.control.Control.call(this, {
    element: container
  })
}

// Draw Polygon Button
MAP_CONTROLS.polygon_button = function () {
  var button = document.createElement('button')
  button.setAttribute('class', 'map-button polygon')
  button.setAttribute('title', 'Draw Polygon')
  button.innerHTML = 'Draw'
  var handlePolygon = function () {
    MAP_CONTROLS.add_draw_interaction('Polygon', button)
  }

  button.addEventListener('click', handlePolygon, false)
  return button
}

// Draw Polygon Button
MAP_CONTROLS.point_button = function () {
  var button = document.createElement('button')
  button.setAttribute('class', 'map-button point')
  button.setAttribute('title', 'Map Point')
  button.innerHTML = 'Start'
  var handlePoint = function () {
    MAP_CONTROLS.add_draw_interaction('Point', button)
  }

  button.addEventListener('click', handlePoint, false)
  return button
}

// Toggle/Untoggle Control
MAP_CONTROLS.toggle_button = function(button) {
  // Clear any active controls
  var is_active_control = button.id == 'active-control'
  $('#active-control').removeAttr('id')
  if (is_active_control) {
    MAP_CONTROLS.toggle_draw_layer_style(draw_layer_styles.NONE)
    MAP_CONTROLS.current_interaction = null
    return false
  } else {
    button.setAttribute('id', 'active-control')
    return true
  }
}

// Add Draw Interactions
MAP_CONTROLS.add_draw_interaction = function (type, button) {
  // Remove the previous interaction
  map.removeInteraction(MAP_CONTROLS.current_interaction)
  // Toggle the draw control as needed
  var toggled_on = MAP_CONTROLS.toggle_button(button)

  if (toggled_on) {
    MAP_CONTROLS.toggle_draw_layer_style(draw_layer_styles.DRAW)

    MAP_CONTROLS.current_interaction = new ol.interaction.Draw({
      features: MAP_CONFIG.draw_features,
      type: type,
      style: draw_layer_styles.style[draw_layer_styles.DRAW]
    })

    MAP_CONTROLS.current_interaction.on('drawend', function (event) {
      event.feature.setProperties({
        'id': Date.now()
      })
      var text = "New point selected, click below to create work for this area:";
      document.getElementById('drawnArea').innerHTML = text;
      document.getElementById('create-work-button').style.display = "";
      document.getElementById('results').style.display = "none";
      document.getElementById('create-work-button').classList.add("button");

      var writer = new ol.format.GeoJSON()
      var geojsonstr = writer.writeGeometry(event.feature.getGeometry())
      if (document.getElementById('geoJsonString') != null) {
        document.getElementById('geoJsonString').innerHTML = geojsonstr;
        $('#shapecoords').val(geojsonstr);
      }
    })

    map.addInteraction(MAP_CONTROLS.current_interaction)
  }
}

// Toggle Feature Styles on draw layer for current style
MAP_CONTROLS.toggle_draw_layer_style = function (style) {
  MAP_CONTROLS.current_style = style
  MAP_CONFIG.draw_layer.setStyle(draw_layer_styles.style[style])
}

ol.inherits(MAP_CONTROLS.draw_controls, ol.control.Control)
