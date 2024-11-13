-----------------------------------
-- Flowsnake (Gosper) curve, as SVG
-- Parameter: iter - # of iterations

-- See https://en.wikipedia.org/wiki/Gosper_curve
-- L-system rules
-- Initial: A
-- Angle: 60
-- A and B mean move forward, + and - mean turn CCW and CW by angle
-- Rules: A -> A-B--B+A++AA+B-
--        B -> +A-BB--B-A++A+B

-- psql -A -t -o flowsnake-curve.svg  < flowsnake-curve.sql
-----------------------------------

WITH RECURSIVE
lsystem( iter, state ) AS (
  SELECT 0 AS iter, 'FA' AS state
  UNION ALL
  SELECT iter + 1 AS iter,
    replace(replace(replace(state, 'A', 'A-z--z+A++AA+z-'), 'B', '+A-BB--B-A++A+B'), 'z', 'B') AS state
  FROM lsystem WHERE iter < 4      -- Parameter: iter
),
path( moves ) AS (
  SELECT replace(replace(state, 'A', 'F'), 'B', 'F')
  FROM (SELECT state FROM lsystem ORDER BY iter DESC LIMIT 1) st
),
pts( moves, index, dir, xp, yp, x, y, dx, dy, len ) AS (
  SELECT moves AS moves, 1 AS index, ' ' AS dir, 
              0.0::double precision AS xp, 0.0::double precision AS yp, 
              0.0::double precision AS x, 0.0::double precision AS y, 
              1.0::double precision AS dx, 0.0::double precision AS dy, 
              0.0::double precision AS len
    FROM path
  UNION ALL
  SELECT moves, index+1 AS index, substr(moves, index, 1) AS dir,
      x AS xp, y AS yp,
      x + len*dx AS x,
      y + len*dy AS y,
      CASE substr(moves, index, 1) WHEN '-' THEN dx * cos(radians(-60)) - dy * sin(radians(-60)) 
                                   WHEN '+' THEN dx * cos(radians(60))  - dy * sin(radians(60)) 
                                   ELSE dx END AS dx,
      CASE substr(moves, index, 1) WHEN '-' THEN dx * sin(radians(-60)) + dy * cos(radians(-60)) 
                                   WHEN '+' THEN dx * sin(radians(60))  + dy * cos(radians(60)) 
                                   ELSE dy END AS dy,
      CASE substr(moves, index, 1) WHEN 'F' THEN 1 ELSE 0 END AS len
    FROM pts WHERE index <= length(moves)
),
seg AS (
  SELECT row_number() over() as id, ST_MakeLine( ST_Point(xp, yp), ST_Point(x, y)) geom
  FROM pts WHERE xp <> x OR yp <> y
),
svg AS ( SELECT geom, svgShape( geom,
        style => svgStyle('stroke', svgHSL( 100*(id/ 1024.0 ), 80, 50))
      ) AS svg
    FROM seg
)
SELECT svgDoc( array_agg( svg ),
          viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5 )),
          style => svgStyle('stroke-width', '0.3', 'stroke-linecap', 'round' ) )
  FROM svg;
