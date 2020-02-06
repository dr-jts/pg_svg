--========================================
-- Truchet tiling with Arcs merged into lines
--========================================
-- psql -A -t -o truchet-arc-line.svg  < truchet-arc-line-svg.sql

WITH
grid( type, s, x, y ) AS (
    SELECT CASE WHEN random() < 0.5 THEN 1 ELSE 2 END AS type,
        10 AS s, 10 * x, 10 * y
    FROM generate_series(0, 20) AS t(x)
    CROSS JOIN generate_series(0, 20) as s(y)
),
pts AS (
    SELECT * FROM (VALUES
        ( 1, -- lower left
            5, 0,   5 * 1/sqrt(2), 5 * 1/sqrt(2),   0,5
         ),
        ( 1, -- upper right
            5, 10,  10 - 5 * 1/sqrt(2), 10 - 5 * 1/sqrt(2),  10,5
        ),
        ( 2, -- upper left
            0, 5,   5 * 1/sqrt(2), 10 - 5 * 1/sqrt(2),   5,10
         ),
        ( 2, -- lower right
            5, 0,  10 - 5 * 1/sqrt(2), 5 * 1/sqrt(2),  10,5
        )
        ) AS t( type,  sx, sy,   mx, my,   ex, ey )
),
wkt( wkt )  AS (
    SELECT
        format( 'CIRCULARSTRING( %s %s, %s %s, %s %s )',
            x+sx,y+sy,    x+mx,y+my,    x+ex,y+ey )
        AS wkt
      FROM grid JOIN pts ON grid.type = pts.type
),
curve( geom ) AS (
    SELECT ST_CurveToLine( wkt::geometry ) geom FROM wkt
),
data( geom ) AS (
    SELECT (ST_Dump ( ST_LineMerge( ST_Collect(geom)  ) ) ).geom FROM curve
),
shapes AS (
  SELECT geom, svgShape( geom,
        title => 'Truchet tiling',
        style => svgStyle( 'stroke',
            svgHSL( svgRandInt(270, 361),
                    svgRandInt(70, 100),
                    svgRandInt(40, 80) ),
            'stroke-width', '3' )
    ) svg FROM data
)
SELECT svgDoc( array_agg( svg ),
  viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 5 ))
  ) AS svg FROM shapes;
