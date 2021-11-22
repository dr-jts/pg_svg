-- ---------------------------------
-- Op-Art: Rectangles with Grooves
--
-- psql -A -t -o groovy-cube.svg  < groovy-cube.sql
-- ---------------------------------

WITH
pos AS (SELECT s*x*x*x AS x
  FROM generate_series(0.4, 2, 0.1) AS t(x)
  CROSS JOIN (VALUES (-1), (1)) AS sign(s)
  ORDER BY x
),
ipos AS (SELECT ROW_NUMBER() OVER () AS i, X
  FROM pos
),
side AS (SELECT i, x1, x2
  FROM (SELECT i, x AS x2, LAG(x, 1) OVER () AS x1
        FROM ipos) t
  WHERE x1 IS NOT NULL
),
box AS (SELECT a.i, b.i AS j, a.x1, b.x1 AS y1, a.x2, b.x2 AS y2
  FROM side a CROSS JOIN side b
  WHERE (a.i + b.i) % 2 = 0
)
--SELECT * from box;
SELECT svgDoc(  array_agg(
		                  svgPolygon( ARRAY[ x1, y1, x1, y2, x2, y2, x2, y1]) ),
                style => svgStyle( 'fill', '#000000' ),
  		          viewbox => '-10 -10 20 20'
  	) AS svg
  FROM box;
