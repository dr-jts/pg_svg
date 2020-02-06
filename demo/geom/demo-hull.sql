------------------------------------------------------------------
-- Demo of using SVG functions to display Convex and Concave Hulls
-- Author: Martin Davis  2019
------------------------------------------------------------------

WITH input AS (
  SELECT 'MULTIPOINT ((158 60), (105 64), (109 196), (87 172), (75 76), (100 111), (99 33), (150 78), (95 91), (81 209), (78 153), (172 92), (109 159), (179 99), (80 121), (80 128), (52 154), (181 104), (166 81), (71 61), (131 60), (101 82), (126 48), (173 180), (109 171), (169 86), (135 170), (55 62), (103 197), (135 187))'::geometry geom
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
    style => svgStyle('stroke', '#0088cc',
        'stroke-width', 1::text,
        'fill', '#88ccff',
        'stroke-linejoin', 'round' ) )
    svg FROM convex
  UNION ALL
  SELECT geom, svgShape( geom,
    title => 'Concave Hull',
    style => svgStyle('stroke', '#0000ff',
        'stroke-width', 1::text,
        'stroke-opacity', 0.5::text,
        'fill', '#a0a0ff',
        'stroke-linejoin', 'round' ) )
    svg FROM concave
  UNION ALL
  SELECT geom, svgShape( geom, radius=>2,
    style => svgStyle( 'fill', '#ff0000'  ) )
    svg FROM input
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5 ))
  ) AS svg FROM shapes;
