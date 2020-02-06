-- ---------------------------------
-- Hilbert curve, as SVG
--
-- Parameter: iter
-- iter dependent values in SVG:
--   viewBox
--   id divisor hsl function
-- ---------------------------------

-- psql -A -t -o hilbert-curve.svg  < hilbert-curve-svg.sql

WITH RECURSIVE
lsystem AS ( iter, state )
  SELECT 0 AS iter, 'A' AS state
  UNION ALL
  SELECT iter + 1 AS iter,
    replace(replace(replace(state, 'A', '-CF+AFA+FC-'), 'B', '+AF-BFB-FA+'), 'C', 'B')
  FROM lsystem WHERE iter < 4
),
path( moves ) AS (
  SELECT replace(replace(state, 'A', ''), 'B', '') AS moves
  FROM (SELECT state FROM lsystem ORDER BY iter DESC LIMIT 1) st
),
pts( moves, index, dir, xp, yp, x, y, dx, dy, len ) AS (
  SELECT moves AS moves, 1 AS index, ' ' AS dir,
        0 AS xp, 0 AS yp, 0 AS x, 0 AS y, 1 AS dx, 0 AS dy, 0 AS len
    FROM path
  UNION ALL
  SELECT moves, index+1 AS index, substr(moves, index, 1) AS dir,
      x AS xp,  y AS yp,
      x + len*dx AS x,  y + len*dy AS y,
      CASE substr(moves, index, 1) WHEN '-' THEN -dy WHEN '+' THEN  dy ELSE dx END AS dx,
      CASE substr(moves, index, 1) WHEN '-' THEN  dx WHEN '+' THEN -dx ELSE dy END AS dy,
      CASE substr(moves, index, 1) WHEN 'F' THEN 1 ELSE 0 END AS len
    FROM pts WHERE index <= length(moves)
),
hilbert( index, geom ) AS (
  SELECT row_number() over() AS index,
    ST_MakeLine( ST_MakePoint(xp, yp), ST_MakePoint(x, y)) AS geom
  FROM pts WHERE xp <> x OR yp <> y
)
SELECT '<svg viewBox="-2 -17 19 19" style="stroke-width:0.4; stroke-linecap:round;" xmlns="http://www.w3.org/2000/svg">' || E'\n'
    || string_agg(
        '<path style="stroke:hsl(' || (360 * ( index / 256.0))::integer || ',100%,50%);" fill="none" '
        || ' d="' || ST_AsSVG( geom ) || '" />', E'\n' )
    || E'\n' || '</svg>' || E'\n' AS svg
  FROM hilbert;
