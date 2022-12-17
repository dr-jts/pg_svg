-- ---------------------------------
-- Lissajous curve, as SVG

-- psql -A -t -o lissajous-curve-34.svg  < lissajous-curve-34-svg.sql
-- ---------------------------------

WITH angs AS (
  SELECT  3 AS NX,
          4 AS NY,
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
        style => svgStyle('stroke',
                    svgHSL( 250, -- 240 + 30 * sin(4 * ang - pi()/2),
                      80 + 20 * sin(6 * ang),
                      -- 100,
                      60 + 20 * sin(ang - pi()/6)
                    ))
      ) AS svg
    FROM seg
)
SELECT svgDoc( array_agg( svg ),
          viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 0.5 )),
          style => svgStyle('stroke-width', '0.12', 'stroke-linecap', 'round', 'background-color', '#000000' )
    ) AS svg
  FROM svg;
