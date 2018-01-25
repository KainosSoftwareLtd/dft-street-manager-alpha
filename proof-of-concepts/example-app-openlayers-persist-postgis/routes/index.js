var express = require('express')
var router = express.Router()
const { Client } = require('pg')

var getClient = function () {
  return new Client({
    user: process.env.PG_USER || 'docker',
    host: process.env.PG_HOST || 'localhost',
    database: process.env.PG_DATABASE || 'gis',
    password: process.env.PG_PASSWORD || 'docker',
    port: process.env.PG_PORT || 5432
  })
}

/* GET home page. */
router.get('/', function (req, res, next) {
  var client = getClient()
  client.connect()
  client.query('SELECT *, ST_X(location) AS X1, ST_Y(location) AS Y1 FROM points', (err, result) => {
    if (err) {
      console.log(err.stack)
    }
    client.end()
    res.render('index', { title: 'OpenLayers', message: JSON.stringify(result.rows) })
  //   res.render('index', { title: 'OpenLayers', message: '' })
  })
})

router.post('/', function (req, res, next) {
  console.log(JSON.stringify(req.body))
  if (req.body.lat && req.body.lon) {
    // pg does not like inserting params into inline strings
    const text = `INSERT INTO points(point_id, location) VALUES(DEFAULT, ST_GeomFromText('SRID=3857;POINT(${req.body.lat} ${req.body.lon})')) RETURNING *`
    const values = []
    console.log(text)
    var client = getClient()
    client.connect()
    client.query(text, values, (err, result) => {
      if (err) {
        console.log(err.stack)
      }
      client.end()
      res.redirect('/')
    })
  } else {
    res.redirect('/')
  }
})

module.exports = router
