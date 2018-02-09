// Styles for Draw Layer
draw_layer_styles = {
  // Draw Interactions
  DRAW: 0,
  // Edit Interactions
  EDIT: 1,
  // Remove Interactions
  REMOVE: 2,
  // No Interactions Toggled
  NONE: 3,
  // Associated Feature Styles for mode
  style: {
    0: new ol.style.Style({
      fill: new ol.style.Fill({
        color: [255, 255, 255, 0.4]
      }),
      stroke: new ol.style.Stroke({
        color: '#0658e5',
        width: 2
      }),
      image: new ol.style.Circle({
        radius: 5,
        fill: new ol.style.Fill({
          color: '#0658e5'
        })
      })
    }),
    1: new ol.style.Style({
      fill: new ol.style.Fill({
        color: [255, 255, 255, 0.6]
      }),
      stroke: new ol.style.Stroke({
        color: '#ffcc33',
        width: 2
      }),
      image: new ol.style.Circle({
        radius: 5,
        fill: new ol.style.Fill({
          color: '#ffcc33'
        })
      })
    }),
    2: new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: [255, 0, 0, 0.4],
        width: 2
      }),
      fill: new ol.style.Fill({
        color: [255, 0, 0, 0.2]
      }),
      image: new ol.style.Circle({
        radius: 5,
        fill: new ol.style.Fill({
          color: '#ff0000'
        })
      }),
      zIndex: 1
    }),
    3: new ol.style.Style({
      fill: new ol.style.Fill({
        color: [255, 255, 255, 0.4]
      }),
      stroke: new ol.style.Stroke({
        color: '#0658e5',
        width: 2
      }),
      image: new ol.style.Circle({
        radius: 5,
        fill: new ol.style.Fill({
          color: '#0658e5'
        })
      })
    })
  }
}
