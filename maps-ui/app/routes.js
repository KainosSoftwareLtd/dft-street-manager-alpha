const express = require('express')
const request = require('request')
const router = express.Router()
const access = require('./access.js')

// Route index page
router.get('/', function (req, res) {
  res.render('index')
})


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

  res.render('tech-proto/confirm-permit-application.html')
})

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


// Add your routes here - above the module.exports line

module.exports = router
