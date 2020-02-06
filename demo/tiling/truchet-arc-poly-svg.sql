--========================================
-- Truchet tiling with Arcs, polygonized
--========================================
-- psql -A -t -o truchet-arc-poly.svg  < truchet-arc-poly-svg.sql

WITH
grid( type, s, x, y ) AS (
    SELECT CASE
        WHEN (i = 0 AND j = 0) OR (i = 19 AND j = 19) THEN 1
        WHEN (i = 0 AND j = 19) OR (i = 19 AND j = 0) THEN 2
        ELSE svgRandInt( 1, 2) END AS type,
        10 AS s, 10 * i, 10 * j
    FROM generate_series(0, 19) AS t(i)
    CROSS JOIN generate_series(0, 19) AS s(j)
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
arcs (sx, sy,   mx, my,   ex, ey) AS (
    SELECT x+sx,y+sy,    x+mx,y+my,    x+ex,y+ey  from grid JOIN pts ON grid.type = pts.type
),
ordEdge AS (
    SELECT * FROM generate_series(0, 19,
        1   --- EDGE_STEP
        ) AS t(i)
),
arcsEdge (sx, sy,   mx, my,   ex, ey) AS (
    SELECT 10*i + 5, 0,   10*i + 10, -5,   10*i + 15,0   FROM ordEdge
    UNION
    SELECT 0, 10*i + 5,   -5, 10*i + 10,   0, 10*i + 15  FROM ordEdge
    UNION
    SELECT 10*i + 5, 200,   10*i + 10, 205,   10*i + 15,200  FROM ordEdge
    UNION
    SELECT 200, 10*i + 5,   205, 10*i + 10,   200, 10*i + 15  FROM ordEdge
),
arcsAll AS (
    SELECT * FROM arcs
    UNION SELECT * FROM arcsEdge
),
wkt( wkt )  AS (
    SELECT
        format( 'CIRCULARSTRING( %s %s, %s %s, %s %s )',
            sx,sy,    mx,my,    ex,ey )
        AS wkt
      FROM arcsAll
),
curve( geom ) AS (
    SELECT ST_CurveToLine( wkt::geometry ) geom FROM wkt
),
data( geom ) AS (
    SELECT (ST_Dump (
        -- EDGE_STEP =  BuildArea : 2;  Polygonize : 1
--        ST_BuildArea( ST_Collect( geom ) )
        ST_Polygonize( geom )
         ) ).geom FROM curve
),
shapes AS (
  SELECT geom, svgShape( geom,
        title => 'Truchet tiling',
        style => svgStyle( 'fill',
            svgHSL( svgRandPick( svgRandInt(160, 200), svgRandInt(270, 300) ),
                    svgRandInt(70, 100),
                    svgRandInt(20, 60) )
             ,'stroke', '#ffffff', 'stroke-width', '1.5'
            )
    ) svg FROM data
)
SELECT svgDoc( array_agg( svg ),
            svgViewbox( ST_Expand( ST_Extent(geom), 5 ))
  ) AS svg FROM shapes;
