------------------------------------------------------------------
-- Demo of using SVG functions to display Convex and Concave Hulls
-- Author: Martin Davis  2019

-- psql -At -o hulls.svg  < hulls-svg.sql
------------------------------------------------------------------

WITH input AS (
  SELECT 'MULTIPOINT ((178 80), (174 133), (42 129), (66 151), (162 163), (127 138), (205 139), (160 88), (147 143), (29 157), (85 160), (146 66), (79 129), (139 59), (117 158), (110 158), (84 186), (134 57), (157 72), (177 167), (178 107), (156 137), (190 112), (58 65), (67 129), (152 69), (68 103), (176 183), (41 135), (51 103))'::geometry geom
),
convex AS (
  SELECT ST_ConvexHull( geom ) AS geom FROM input
),
concave AS (
  SELECT ST_ConcaveHull( geom, 0.99 ) AS geom FROM input
),
shapes AS (
  SELECT geom, svgShape( geom,
    title => 'Convex Hull',
    style => svgStyle('stroke', '#0088cc', 'stroke-width', 1::text,
        'stroke-linejoin', 'round',
        'fill', '#88ccff' ) )
    svg FROM convex
  UNION ALL
  SELECT geom, svgShape( geom,
    title => 'Concave Hull',
    style => svgStyle('stroke', '#0000ff', 'stroke-width', 1::text,
        'stroke-opacity', 0.5::text, 'stroke-linejoin', 'round',
        'fill', '#a0a0ff' ) )
    svg FROM concave
  UNION ALL
  SELECT geom, svgShape( geom, radius => 2,
    style => svgStyle( 'fill', '#ff0000'  ) )
    svg FROM input
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 20 ))
  ) AS svg FROM shapes;
