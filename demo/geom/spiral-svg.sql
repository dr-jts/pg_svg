------------------------------------------------------------------
-- Demo of using PostGIS and SVG functions to display a spiral
-- Author: Martin Davis  2021

-- psql -At -o spiral.svg  < spiral-svg.sql
------------------------------------------------------------------

WITH spiralStep AS (
  SELECT  i,
          80 AS circleSegs,     -- Parameter: quantization of arc
          1000 AS centerX,      -- Parameter: center X
          1000 as centerY,      -- Parameter: center Y
          100 as radius         -- Parameter: radius
  FROM generate_series( 0, 5    -- Parameter: # rings = 5
                           * 80) t(i)   -- circleSegs value
),
spiral AS (SELECT ST_MakeLine( ARRAY_AGG(
    ST_Point( centerX + (radius / circleSegs) * i * cos( i * (2 * pi() / circleSegs) ),
              centerY + (radius / circleSegs) * i * sin( i * (2 * pi() / circleSegs) ) )
  )) AS geom
  FROM spiralStep
),
shapes AS (
  SELECT geom, svgShape( geom,
            style => svgStyle(  'stroke', '#0000ff',
                                'stroke-width', 20::text ) )
    AS svg FROM spiral
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 100) )
  ) AS svg FROM shapes;
