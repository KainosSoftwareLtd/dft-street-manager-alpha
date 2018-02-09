const worksRoutes = require('./works_routes');

module.exports = function(app, db) {
    worksRoutes(app, db);

};