-- ---------------------------------
-- Sierpinski carpet, as GEoJSON
-- Parameter: level
-- ---------------------------------

WITH RECURSIVE
centres( level, x, y, size ) AS (
  SELECT 1 AS level, 0.5 as x, 0.5 as y, 1.0/3.0 AS size
  UNION ALL
  SELECT level, x + dx * size, y + dy * size, size/3.0
    FROM (
      SELECT level + 1 AS level, x, y, dx, dy, 1.0/(3.0 ^ level) AS size
      FROM generate_series(-1, 1) AS xoff(dx)
        CROSS JOIN generate_series(-1, 1) AS yoff(dy)
        CROSS JOIN centres
      WHERE NOT ( dx = 0 AND dy = 0) AND level < 3
    ) dd
),
holes( hole ) AS (
  SELECT ST_MakeEnvelope(x - size/2, y - size/2, x + size/2, y + size/2) AS hole
  FROM centres
),
sierpinski_carpet( geom ) AS (
  SELECT ST_MakePolygon( ST_ExteriorRing(ST_MakeEnvelope(0,0,1,1)),
    array_agg( ST_ExteriorRing(hole)) ) AS geom
  FROM holes
)
SELECT ST_AsGeoJSON( ST_Translate( ST_Scale(geom, 10, 10 ), 0, 23), 2 ) FROM sierpinski_carpet;
