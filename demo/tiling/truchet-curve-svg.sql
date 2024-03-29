--===========================================================
-- Truchet tiling with CIRCULARSTRINGs merged into lines
-- Author: Martin Davis  2021

-- psql -A -t -o truchet-curve.svg  < truchet-curve-svg.sql
--===========================================================

WITH grid( type, x, y ) AS (
    SELECT CASE WHEN random() < 0.5 THEN 1 ELSE 2 END AS type,
            10 * x, 10 * y
    FROM generate_series(0, 20) AS t(x)
    CROSS JOIN generate_series(0, 20) as s(y)
),
pts AS ( SELECT * FROM (VALUES
    ( 1, 5, 0,   5 * 1/sqrt(2), 5 * 1/sqrt(2),   0,5 ),             -- lower left
    ( 1, 5, 10,  10 - 5 * 1/sqrt(2), 10 - 5 * 1/sqrt(2),  10,5 ),   -- upper right
    ( 2, 0, 5,   5 * 1/sqrt(2), 10 - 5 * 1/sqrt(2),   5,10 ),       -- upper left
    ( 2, 5, 0,  10 - 5 * 1/sqrt(2), 5 * 1/sqrt(2),  10,5 )          -- lower right
        ) AS t( type, sx, sy, mx, my, ex, ey )
),
wkt( wkt ) AS ( SELECT format( 'CIRCULARSTRING( %s %s, %s %s, %s %s )',
                                x+sx,y+sy,    x+mx,y+my,    x+ex,y+ey )
      FROM grid JOIN pts ON grid.type = pts.type
),
curve( geom ) AS (
    SELECT ST_CurveToLine( wkt::geometry ) geom FROM wkt
),
lines( geom ) AS (
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
    ) svg FROM lines
)
SELECT svgDoc( array_agg( svg ),
  viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 10 ))
  ) AS svg FROM shapes;
