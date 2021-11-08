------------------------------------------------------------------
-- Demo of using SVG functions to display Convex and Concave Hulls
-- Author: Martin Davis  2019

-- psql -At -o hulls.svg  < hulls-svg.sql
------------------------------------------------------------------

WITH data AS (
  SELECT 'MULTIPOINT ((178 80), (174 133), (66 151), (162 163), (205 139), (147 143), (29 157), (85 160), (79 129), (117 158), (110 158), (84 186), (134 57), (177 167), (178 107), (190 112), (58 65), (67 129), (68 103), (176 183), (51 103), (90 80), (48 136), (148 76))'::geometry geom
),
shapes AS (
  SELECT svgShape( ST_ConvexHull( geom ),
    title => 'Convex Hull',
    style => svgStyle('stroke', '#0088cc', 'stroke-width', '1', 'fill', '#88ccff' ) )
    svg FROM data
  UNION ALL SELECT svgShape( ST_ConcaveHull( geom, 0.99 ),
    title => 'Concave Hull',
    style => svgStyle('stroke', '#0000ff', 'stroke-width', '1', 'fill', '#a0a0ff' ) )
    svg FROM data
  UNION ALL SELECT svgShape( ST_Buffer((mic).center, (mic).radius),
    title => 'Maximum Inscribed Circle',
    style => svgStyle('stroke', '#6600aa', 'stroke-width', '1', 'fill', '#dd90ff' ) )
    svg FROM (SELECT ST_MaximumInscribedCircle( geom ) AS mic FROM data) AS t
  UNION ALL SELECT svgShape( geom, radius => 2,
    style => svgStyle( 'fill', '#ff0000'  ) )
    svg FROM data
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( (SELECT ST_Extent(geom) from data), 20 ))
  ) AS svg FROM shapes;
