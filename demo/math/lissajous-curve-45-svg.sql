-- ---------------------------------
-- Lissajous curve, as SVG

-- psql -A -t -o lissajous-curve-45.svg  < lissajous-curve-45-svg.sql
-- ---------------------------------

WITH angs AS (
  SELECT  4 AS a,
          5 As b,
          0.0 as phase,
          0.02 AS step,
          generate_series(0.0, 2*pi()::numeric, 0.02) AS ang
),
seg AS (
  SELECT ang, ST_MakeLine(
      ST_Point( sin(a * ang),        sin(b * ang          + phase)),
      ST_Point( sin(a * (ang + step)), sin(b * (ang + step) + phase))
  ) AS geom
  FROM angs
),
svg AS ( SELECT geom, svgShape( geom,
        style => svgStyle('stroke', svgHSL( 360 * sin(ang/4), 100, 60))
      ) AS svg
    FROM seg
)
SELECT svgDoc( array_agg( svg ),
          viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 0.5 )),
          style => svgStyle('stroke-width', '0.12', 'stroke-linecap', 'round', 'background-color', '#000000' )
    ) AS svg
  FROM svg;
