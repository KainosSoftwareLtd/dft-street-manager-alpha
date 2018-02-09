const express = require('express')
const request = require('request')
const router = express.Router()

// Route index page
router.get('/', function (req, res) {
  res.render('index')
})


router.post('/tech-proto/confirm-permit-application', function (req, res) {

  var options = {
    url: 'http://localhost:8000/works',
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

  res.render('tech-proto/confirm-permit-application.html')
})


// Add your routes here - above the module.exports line

module.exports = router
