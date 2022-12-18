-- ---------------------------------
-- Lissajous Knot, as SVG

-- psql -A -t -o lissajous-knot-34.svg  < lissajous-knot-34-svg.sql
-- ---------------------------------

WITH angs AS (
  SELECT  3 AS NX,
          4 AS NY,
          17 AS NZ,
          0.5 * pi() AS PHASEX,
          0.0 AS PHASEY,
          0.3 AS PHASEZ,
          0.01 AS STEP,
          generate_series(0.0, 2*pi()::numeric, 0.01) AS ang
),
seg AS (
  SELECT ang, sin(NZ * ang + PHASEZ) AS z,
    ST_MakeLine(
      ST_Point( sin(NX *  ang         + PHASEX), sin(NY *  ang         + PHASEY)),
      ST_Point( sin(NX * (ang + STEP) + PHASEX), sin(NY * (ang + STEP) + PHASEY))
  ) AS geom
  FROM angs
  ORDER BY z
),
svg AS ( SELECT geom, svgShape( geom,
        style => svgStyle('stroke',
                    svgHSL( 240 + 40 * sin(ang),
                      100,
                      45 + 20 * z
                    ))
      ) AS svg
    FROM seg
)
SELECT svgDoc( array_agg( svg ),
          viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 0.5 )),
          style => svgStyle('stroke-width', '0.12', 'stroke-linecap', 'round' )
    ) AS svg
  FROM svg;
