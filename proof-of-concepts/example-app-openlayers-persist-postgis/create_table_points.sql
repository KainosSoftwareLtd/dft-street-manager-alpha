CREATE TABLE points
(
  point_id bigserial NOT NULL,
  location geometry,
  CONSTRAINT points_pkey PRIMARY KEY (point_id)
)