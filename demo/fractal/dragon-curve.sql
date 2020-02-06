-- ---------------------------------
-- Dragon curve, as WKT
-- Parameter: iter - # of iterations
-- ---------------------------------

-- psql -A -t -o dragon-curve.wkt  < dragon-curve.sql

WITH RECURSIVE
lsystem( iter, state ) AS (
  SELECT 0 AS iter, 'FX' AS state
  UNION ALL
  SELECT iter + 1 AS iter,
    replace(replace(replace(state, 'X', 'X+zF+'), 'Y', '-FX-Y'), 'z', 'Y') AS state
  FROM lsystem WHERE iter < 10
),
path( moves ) AS (
  SELECT replace(replace(state, 'A', ''), 'B', '') AS moves
  FROM (SELECT state FROM lsystem ORDER BY iter DESC LIMIT 1) st
),
pts( moves, index, dir, x, y, dx, dy, len ) AS (
  SELECT moves AS moves, 1 AS index, ' ' AS dir, 0 AS x, 0 AS y, 1 AS dx, 0 AS dy, 0 AS len  from path
  UNION ALL
  SELECT moves, index+1 AS index, substr(moves, index, 1) AS dir,
      x + len*dx AS x,
      y + len*dy AS y,
      CASE substr(moves, index, 1) WHEN '-' THEN -dy WHEN '+' THEN  dy ELSE dx END AS dx,
      CASE substr(moves, index, 1) WHEN '-' THEN  dx WHEN '+' THEN -dx ELSE dy END AS dy,
      CASE substr(moves, index, 1) WHEN 'F' THEN 1 ELSE 0 END AS len
    FROM pts WHERE index <= length(moves)
),
dragon( line )  AS (
  SELECT ST_RemoveRepeatedPoints( ST_MakeLine( ST_MakePoint( x, y ) ORDER BY index ) ) AS line FROM pts
)
SELECT ST_AsText(line) from dragon;
