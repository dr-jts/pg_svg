-- ---------------------------------
-- Lissajous curve, as SVG
--
-- Parameter: iteration
-- iteration dependent values in SVG:
--   id divisor hsl function

-- psql -A -t -o lissajous-curve-34.svg  < lissajous-curve-34-svg.sql
-- ---------------------------------

WITH angs AS (
  SELECT  3 AS a,
          4 As b,
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
        style => svgStyle('stroke',
                    svgHSL( 250, -- 240 + 30 * sin(4 * ang - pi()/2),
                      60 + 20 * sin(2 * ang - pi()/6),
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
