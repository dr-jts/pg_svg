-- ---------------------------------
-- Hilbert curve, as SVG
--
-- Parameter: iteration
-- iteration dependent values in SVG:
--   id divisor hsl function

-- psql -A -t -o hilbert-curve.svg  < hilbert-curve-svg.sql
-- ---------------------------------

WITH RECURSIVE
-- recursively generate L-system output string
lsystem AS (
  SELECT 'A' AS state, 0 AS iteration
  UNION ALL
  SELECT replace(replace(replace(state, 'A', '-CF+AFA+FC-'), 'B', '+AF-BFB-FA+'), 'C', 'B'),
          iteration + 1 AS iteration
  FROM lsystem WHERE iteration < 5  -- Iteration parameter
),
-- clean and optimize drawing commands
path(moves) AS ( SELECT replace(replace(replace(replace(state, 'A', ''), 'B', ''), '+-', ''), '-+', '')
  FROM (SELECT state FROM lsystem ORDER BY iteration DESC LIMIT 1) st
),
-- iterate over draw commands to create segments
pts(moves, index, dir, xp, yp, x, y, dx, dy, len) AS (
  SELECT moves, 1, ' ',  0, 0, 0, 0, 1, 0, 0 FROM path
  UNION ALL
  SELECT moves, index+1 AS index, substr(moves, index, 1) AS dir,
      x AS xp, y AS yp,
      x + dx*len AS x, y + dy*len AS y,
      CASE substr(moves, index, 1) WHEN '-' THEN -dy WHEN '+' THEN  dy ELSE dx END AS dx,
      CASE substr(moves, index, 1) WHEN '-' THEN  dx WHEN '+' THEN -dx ELSE dy END AS dy,
      CASE substr(moves, index, 1) WHEN 'F' THEN 1 ELSE 0 END AS len
    FROM pts WHERE index <= length(moves)
),
seg AS (
  SELECT row_number() over() as id, ST_MakeLine( ST_Point(xp, yp), ST_Point(x, y)) geom
  FROM pts WHERE xp <> x OR yp <> y
),
svg AS ( SELECT geom, svgShape( geom,
        style => svgStyle('stroke', svgHSL( 300*(id/ 1024.0 ), 100, 50))
      ) AS svg
    FROM seg
)
SELECT svgDoc( array_agg( svg ),
          viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5 )),
          style => svgStyle('stroke-width', '0.5', 'stroke-linecap', 'round' )
    ) AS svg
  FROM svg;
