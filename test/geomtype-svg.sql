------------------------------------------------------------------
-- Demo of using SVG functions to display PostGIS geometry types
-- Author: Martin Davis  2021

-- psql -A -t -o geomtype.svg  < geomtype-svg.sql
------------------------------------------------------------------

WITH data(geom) AS (VALUES
   ( 'POINT EMPTY'::geometry )
  ,( 'POINT (10 210)'::geometry )
  ,( 'MULTIPOINT ((110 210), (110 220), (120 210))'::geometry )
  ,( 'LINESTRING EMPTY'::geometry )
  ,( 'LINESTRING (20 180, 80 180, 20 110, 80 120, 40 160)'::geometry )
  ,( 'MULTILINESTRING EMPTY'::geometry )
  ,( 'MULTILINESTRING ((110 190, 150 190, 110 140, 150 110), (180 180, 140 150, 180 120, 190 150))'::geometry )
  ,( 'POLYGON EMPTY'::geometry )
  ,( 'POLYGON ((10 90, 90 90, 70 50, 90 10, 30 10, 10 90))'::geometry )
  ,( 'POLYGON ((110 90, 190 90, 170 50, 190 10, 130 10, 110 90), (130 70, 160 80, 150 40, 130 70))'::geometry )
  ,( 'MULTIPOLYGON EMPTY'::geometry )
  ,( 'MULTIPOLYGON ( ((210 90, 250 90, 230 50, 210 90)), ((210 40, 260 10, 270 40, 210 40)), ((260 90, 290 90, 290 50, 250 50, 270 70, 260 90)))'::geometry )
  ,( 'GEOMETRYCOLLECTION EMPTY'::geometry )
  ,( 'GEOMETRYCOLLECTION (POLYGON ((310 170, 350 190, 340 140, 310 170)), LINESTRING (360 180, 390 170, 360 140, 390 110), POINT (310 130), POINT (320 110), POINT (340 130))'::geometry )
),
geomstyle(geom, style) AS (
    SELECT geom, CASE ST_Dimension(geom)
    WHEN 0 THEN svgStyle(
        'fill', '#0000ff'
         )
    WHEN 1 THEN svgStyle(
        'stroke', '#0000ff',
        'stroke-width', 1::text,
        'stroke-linejoin', 'round'
         )
    WHEN 2 THEN svgStyle(
        'stroke', '#0000ff',
        'stroke-width', 1::text,
        'stroke-linejoin', 'round',
        'fill', '#c0c0ff'
         )
    END AS style
    FROM data
),
shapes AS (
  SELECT geom, svgShape( geom,
    radius => 2,
    title => GeometryType( geom ),
    style => style )
    svg FROM geomstyle
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5) )
  ) AS svg FROM shapes;
