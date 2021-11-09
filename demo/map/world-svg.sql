------------------------------------------------------------------
-- Demo of using SVG functions to display
-- map of World countries and geodetic grid
-- in Robinson projection

-- Author: Martin Davis  2021

-- Requires:
--    Table ne.admin_0_countries - US states geometry in WGS84

-- psql -A -t -o world.svg  < world-svg.sql
------------------------------------------------------------------

WITH world AS (
  SELECT name, abbrev, continent, ST_Transform(geom, 54030) AS geom FROM ne.admin_0_countries
  ),
grid AS (
  SELECT ST_MakeBox2D(ST_Point(lon.x, lat.y),ST_Point(lon.x+10, lat.y+10)) AS geom
  FROM        generate_series(-180, 170, 10)  lon(x)
  CROSS JOIN  generate_series(-90, 80, 10)    lat(y)
  ),
gridProj AS (SELECT ST_Transform(ST_SetSRID(geom, 4326), 54030) AS geom FROM grid),
shapes AS (
  SELECT geom, svgShape( geom,
      style => svgStyle(  'stroke', '#ffffff', 'stroke-width', '30000',
                        'fill', '#e0e0ff' ) )
    svg FROM gridProj
  UNION ALL SELECT geom, svgShape( geom,
      title => name,
      style => svgStyle(  'stroke', '#444444', 'stroke-width', '10000',
                        'fill', CASE continent
                        WHEN 'Africa'         THEN svgHSL( 30, 70, 80)
                        WHEN 'Asia'           THEN svgHSL( 60, 70, 80)
                        WHEN 'Europe'         THEN svgHSL( 90, 70, 80)
                        WHEN 'Oceania'        THEN svgHSL(200, 70, 80)
                        WHEN 'North America'  THEN svgHSL(150, 70, 80)
                        WHEN 'South America'  THEN svgHSL(310, 70, 90)
                        ELSE '#ffffff'
                        END))
    svg FROM world
  )
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 500000))
  ) AS svg FROM shapes;
