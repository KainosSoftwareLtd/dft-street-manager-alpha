CREATE TABLE works (
  p_id INTEGER PRIMARY KEY,
  work_reference_number VARCHAR,
  promoter_name VARCHAR,
  start_date DATE,
  end_date DATE,
  works_category VARCHAR
);

SELECT AddGeometryColumn('works','the_geom','3857','POINT',2);
