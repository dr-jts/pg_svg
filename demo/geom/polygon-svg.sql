------------------------------------------------------------------
-- Demo of using SVG functions to display PostGIS polygon
-- Author: Martin Davis  2021

-- psql -At -o polygon.svg  < polygon-svg.sql
------------------------------------------------------------------

WITH data AS (
  SELECT 'POLYGON ((20 20, 30 80, 80 90, 60 50, 90 20, 20 20))'::geometry AS geom
),
shapes AS (
  SELECT geom, svgShape( geom,
            style => svgStyle('fill', '#a0a0ff',
                        'stroke', '#0000ff',
                        'stroke-width', 1::text,
                        'stroke-linejoin', 'round' ) )
    AS svg FROM data
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 20) )
  ) AS svg FROM shapes;
