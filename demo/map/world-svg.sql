------------------------------------------------------------------
-- Demo of using SVG functions to display
-- map of World countries and geodetic grid
-- in Robinson projection

-- Author: Martin Davis  2021

-- Requires:
--    Table ne.admin_0_countries - US states geometry in WGS84

-- psql -A -t -o world.svg  < world-svg.sql
------------------------------------------------------------------

WITH world AS ( SELECT name, abbrev, continent,
        ST_Transform( ST_SnapToGrid(geom, .1), 54030) AS geom,
        CASE continent  WHEN 'Africa'         THEN 30
                        WHEN 'Asia'           THEN 300
                        WHEN 'Europe'         THEN 190
                        WHEN 'Oceania'        THEN 60
                        WHEN 'North America'  THEN 160
                        WHEN 'South America'  THEN 0
                        ELSE -1 END AS hue,
        floor(random() * 25) AS dH, floor(random() * 30) AS dS
    FROM ne.admin_0_countries
  ),
grid AS (
  SELECT ST_Transform(ST_SetSRID(
            ST_MakeBox2D(ST_Point(lon.x, lat.y),ST_Point(lon.x+10, lat.y+10)),
                        4326), 54030) AS geom
  FROM        generate_series(-180, 170, 10)  lon(x)
  CROSS JOIN  generate_series(-90, 80, 10)    lat(y)
  ),
shapes AS (
  SELECT geom, svgShape( geom,
      style => svgStyle('stroke', '#ffffff', 'stroke-width', '30000',
                        'fill', '#e0e0ff' ) )
    svg FROM grid
  UNION ALL SELECT geom, svgShape( geom, title => name,
      style => svgStyle('stroke', '#444444', 'stroke-width', '10000',
                        'fill', CASE hue WHEN -1 THEN '#ffffff'
                                                 ELSE svgHSL(hue + dH, 60 + dS, 80) END))
    svg FROM world
  )
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 500000))
  ) AS svg FROM shapes;
