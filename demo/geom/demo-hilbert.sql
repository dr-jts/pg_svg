-- ---------------------------------
-- Hilbert curve, as SVG
--
-- Parameter: iteration
-- iteration dependent values in SVG:
--   id divisor hsl function
-- ---------------------------------

WITH RECURSIVE lsystem AS (
  SELECT 'A' AS state, 0 AS iteration
  UNION ALL
  SELECT replace(replace(replace(state, 'A', '-CF+AFA+FC-'), 'B', '+AF-BFB-FA+'), 'C', 'B'), iteration+1 AS iteration
  FROM lsystem WHERE iteration < 5
),
path AS (
  SELECT replace(replace(state, 'A', ''), 'B', '') AS moves
  FROM (SELECT state FROM lsystem ORDER BY iteration DESC LIMIT 1) st
),
pts AS (
  SELECT moves AS moves, 1 AS index, ' ' AS dir,
      0 AS xp, 0 AS yp, 0 AS x, 0 AS y, 1 AS dx, 0 AS dy, 0 AS len
    FROM path
  UNION ALL
  SELECT moves, index+1 AS index, substr(moves, index, 1) AS dir,
      x AS xp, y AS yp,
      x + len*dx AS x, y + len*dy AS y,
      CASE substr(moves, index, 1) WHEN '-' THEN -dy WHEN '+' THEN  dy ELSE dx END AS dx,
      CASE substr(moves, index, 1) WHEN '-' THEN  dx WHEN '+' THEN -dx ELSE dy END AS dy,
      CASE substr(moves, index, 1) WHEN 'F' THEN 1 ELSE 0 END AS len
    FROM pts WHERE index <= length(moves)
),
hilbert AS (
  SELECT row_number() over() as id, ST_MakeLine( ST_MakePoint(xp, yp), ST_MakePoint(x, y)) geom
  FROM pts WHERE xp <> x OR yp <> y
),
svg AS (
    SELECT geom, svgShape( geom,
        style => svgStyle('stroke', svgHSL( 300*(id/ 1024.0 ), 100, 50))
      ) AS svg
    FROM hilbert
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5 )),
    style => svgStyle('stroke-width', 0.5::text,
        'stroke-linecap', 'round' ) ) AS svg
  FROM svg;
