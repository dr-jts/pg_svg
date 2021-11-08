------------------------------------------------------------------
-- Demo of using SVG functions to display PostGIS Delaunay Triangulation
-- Author: Martin Davis  2019

-- psql -At -o delaunay.svg  < delaunay-svg.sql
------------------------------------------------------------------

WITH data AS (
  SELECT 'MULTIPOINT ((50 50), (50 120), (100 100), (130 70), (130 150), (70 160), (160 110), (70 80))'::geometry geom
),
shapes AS (
  SELECT svgShape( ST_DelaunayTriangles( geom ),
            title => 'Delaunay Triangulation',
            style => svgStyle('fill', '#a0a0ff',
                        'stroke', '#0000ff',
                        'stroke-width', 1::text,
                        'stroke-linejoin', 'round' ) )
    AS svg FROM data
  UNION ALL
  SELECT svgShape( geom, radius => 2,
            title => 'Site',
            style => svgStyle( 'fill', '#ff0000'  ) )
    AS svg FROM data
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( (SELECT ST_Extent(geom) from data), 20) )
  ) AS svg FROM shapes;
