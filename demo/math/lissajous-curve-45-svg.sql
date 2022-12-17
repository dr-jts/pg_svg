-- ---------------------------------
-- Lissajous curve, as SVG

-- psql -A -t -o lissajous-curve-45.svg  < lissajous-curve-45-svg.sql
-- ---------------------------------

WITH angs AS (
  SELECT  4 AS NX,
          5 AS NY,
          0.0 AS PHASE,
          0.02 AS STEP,
          generate_series(0.0, 2*pi()::numeric, 0.02) AS ang
),
seg AS (
  SELECT ang, ST_MakeLine(
      ST_Point( sin(NX * ang),          sin(NY * ang          + PHASE)),
      ST_Point( sin(NX * (ang + STEP)), sin(NY * (ang + STEP) + PHASE))
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
