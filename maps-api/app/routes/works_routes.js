module.exports = function (app, pgPool) {
    app.post('/works', (req, res) => {
        console.log(req.body);
        pgPool.connect()
            .then(client => {

                var pid = 0
                return client.query('select max(p_id) from works')
                    .then(result => {
                        pid = result.rows[0].max + 1
                        console.log(pid)

                        var startDate  = req.body.startdateday + '/' + req.body.startdatemonth + '/' + req.body.startdateyear;
                        var endDate  = req.body.enddateday + '/' + req.body.enddatemonth + '/' + req.body.enddateyear;

                        const query = {
                            text: 'INSERT INTO works(p_id, work_reference_number, promoter_name, start_date, end_date, works_category, the_geom)' +
                            'VALUES($1, $2, $3, $4, $5, $6, ST_SetSRID(ST_GeomFromGeoJSON($7), 3857));',
                            values: [pid, req.body.workreferencenumber, req.body.promotername, startDate, endDate, req.body.workcategorygroup, req.body.coords]
                        }

                        return client.query(query)
                            .then(result =>{
                                res.status(200).send('Done')
                            })
                            .catch(e => {
                                console.log(e.stack)
                                res.status(500).send('Error')
                            })
                    })
                    .catch(e => {
                        console.log(e.stack)
                        res.status(500).send('Error')
                    })
                    .then(() => client.release())

            })
    })

    app.get('/allworks', (req,res) => {
        var queryText;
        if(Array.isArray(req.query.workcategory)){
            console.log("it's an array")
            queryText = "SELECT jsonb_build_object('type','FeatureCollection','features', jsonb_agg(feature))FROM (SELECT jsonb_build_object('type', 'Feature','id', p_id,'geometry', ST_AsGeoJSON(the_geom)::jsonb,'properties', to_jsonb(row) - 'p_id' - 'the_geom'  ) AS feature  FROM (SELECT * FROM works where works_category = ANY($1)) row) features;"
        } else {
            console.log("it's not an array")
            queryText = "SELECT jsonb_build_object('type','FeatureCollection','features', jsonb_agg(feature))FROM (SELECT jsonb_build_object('type', 'Feature','id', p_id,'geometry', ST_AsGeoJSON(the_geom)::jsonb,'properties', to_jsonb(row) - 'p_id' - 'the_geom'  ) AS feature  FROM (SELECT * FROM works where works_category = $1) row) features;"
        }
        const query = {
            text: queryText,
            values: [req.query.workcategory ]
        };

        console.log(query);
        // promise - checkout a client
        pgPool.connect()
            .then(client => {
            return client.query(query)
                .then(result => {
                    console.log(result.rows[0].jsonb_build_object)
                    res.send(result.rows[0].jsonb_build_object)
                })
                .catch(e => {
                    console.log(e.stack)
                })
                .then(() => client.release())
            })
    })
};