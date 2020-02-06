------------------------------------------------------------------
-- Demo of using SVG functions to display PostGIS Delaunay Triangulation
-- Author: Martin Davis  2019
------------------------------------------------------------------
-- psql -A -t -o delaunay.svg  < demo-delaunay.sql

WITH input AS (
  SELECT 'MULTIPOINT ((50 50), (50 120), (100 100), (130 70), (130 150), (70 160), (160 110), (70 80))'::geometry geom
),
result AS (
  SELECT ST_DelaunayTriangles( geom ) AS geom FROM input
),
shapes AS (
  SELECT geom, svgShape( geom,
    title => 'Delaunay Triangulation',
    style => svgStyle('stroke', '#0000ff',
        'stroke-width', 1::text,
        'fill', '#a0a0ff',
        'stroke-linejoin', 'round' ) )
    svg FROM result
  UNION ALL
  SELECT geom, svgShape( geom, radius=>2,
    title => 'Site',
    style => svgStyle( 'fill', '#ff0000'  ) )
    svg FROM input
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5) )
  ) AS svg FROM shapes;
