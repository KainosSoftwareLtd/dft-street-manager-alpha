// server.js
const express        = require('express');
const bodyParser     = require('body-parser');
const pg            = require('pg');
const db             = require('./config/db')

const app            = express();

const port = 8000;

const config = {
    user: db.user,
    password: db.password,
    host: db.host,
    database: db.database,
    port: db.port
}

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.use(bodyParser.urlencoded({ extended: true}));

var pgPool = new pg.Pool(config);

require('./app/routes')(app, pgPool);


app.listen(port, () => {
    console.log('We are live on ' + port);
});


