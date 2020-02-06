--================================================
-- Penrose P3 Tiling created by inflation, initialized by 5 S triangles

-- Initial state is 5 S triangles in a fan in the positive Y halfplane
-- and centred at the origin.
-- The small interior angle of the S triangle is 38 degrees = PI/5

-- The number of output tiles is determined by the depth of recursion,
-- which is specified by the LEVEL value.
--================================================

-- psql -A -t -o penrose3-2.svg  < penrose3-2-svg.sql

WITH RECURSIVE
init(type, ax,ay, bx,by, cx,cy) AS (VALUES
		( 'S',
			100::float8, 0::float8,
			0::float8, 0::float8,
			100 * cos( pi() / 5 ), 100 * sin( pi() / 5 )
		),
		( 'S',
			100 * cos( 2 * pi() / 5 ), 100 * sin( 2 * pi() / 5 ),
			0::float8, 0::float8,
			100 * cos( pi() / 5 ), 100 * sin( pi() / 5 )
		),
		( 'S',
			100 * cos( 2 * pi() / 5 ), 100 * sin( 2 * pi() / 5 ),
			0::float8, 0::float8,
			100 * cos( 3 * pi() / 5 ), 100 * sin( 3 * pi() / 5 )
		),
		( 'S',
			100 * cos( 4 * pi() / 5 ), 100 * sin( 4 * pi() / 5 ),
			0::float8, 0::float8,
			100 * cos( 3 * pi() / 5 ), 100 * sin( 3 * pi() / 5 )
		),
		( 'S',
			100 * cos( 4 * pi() / 5 ), 100 * sin( 4 * pi() / 5 ),
			0::float8, 0::float8,
			-100::float8, 0::float8
		)
),
tri(i, type,  ax,ay, bx,by, cx,cy, psi, psi2) AS (
	SELECT 0, *,
		-- psi = 1/phi. phi is the Golden Ratio (sqrt(5) + 1)/2
		(sqrt(5)-1)/2 AS psi,
		-- psi^2 = 1 - psi
		1 - (sqrt(5)-1)/2 AS psi2
		FROM init
	UNION ALL
	SELECT i+1, trimap.subtype AS type,
		CASE split
		WHEN 1 THEN ax*psi2 + cx*psi
		WHEN 2 THEN ax*psi2 + bx*psi
		WHEN 3 THEN cx
		WHEN 4 THEN ax*psi + bx*psi2
		WHEN 5 THEN cx END AS ax,
		CASE split
		WHEN 1 THEN ay*psi2 + cy*psi
		WHEN 2 THEN ay*psi2 + by*psi
		WHEN 3 THEN cy
		WHEN 4 THEN ay*psi + by*psi2
		WHEN 5 THEN cy END AS ay,

		CASE split
		WHEN 1 THEN ax*psi2 + bx*psi
		WHEN 2 THEN ax*psi2 + cx*psi
		WHEN 3 THEN ax*psi2 + cx*psi
		WHEN 4 THEN cx
		WHEN 5 THEN ax*psi + bx*psi2 END AS bx,
		CASE split
		WHEN 1 THEN ay*psi2 + by*psi
		WHEN 2 THEN ay*psi2 + cy*psi
		WHEN 3 THEN ay*psi2 + cy*psi
		WHEN 4 THEN cy
		WHEN 5 THEN ay*psi + by*psi2 END AS by,

		CASE split
		WHEN 1 THEN ax
		WHEN 2 THEN bx
		WHEN 3 THEN bx
		WHEN 4 THEN ax
		WHEN 5 THEN bx END AS cx,
		CASE split
		WHEN 1 THEN ay
		WHEN 2 THEN by
		WHEN 3 THEN by
		WHEN 4 THEN ay
		WHEN 5 THEN by END AS cy,

		psi, psi2
	FROM tri INNER JOIN (VALUES ( 'L', 1, 'L' ),
		( 'L', 2, 'S' ),
		( 'L', 3, 'L' ),
		( 'S', 4, 'S'),
		( 'S', 5, 'L') ) AS trimap(type, split, subtype)
		ON tri.type = trimap.type
	WHERE i <= 4 ),  -- LEVEL
toptri AS (
	SELECT * FROM tri WHERE i = 4  -- LEVEL
),
conjugate AS (
	SELECT type,ax,ay,bx,by,cx,cy FROM toptri
	UNION ALL
	SELECT type,ax,-ay,bx,-by,cx,-cy FROM toptri
),
rhombs AS (
	SELECT type,ax,ay,bx,by,cx,cy,
		ax + (cx-ax)/2 AS midx,
		ay + (cy-ay)/2 AS midy
	FROM conjugate
),
tiling AS (
	SELECT DISTINCT ON (midx, midy) type,ax,ay,bx,by,cx,cy,
		midx - (bx - midx) AS dx,
		midy - (by - midy) AS dy,
		CASE type WHEN 'L' THEN 'steelblue' WHEN 'S' THEN 'lightskyblue' END AS clr
	FROM rhombs
)
SELECT svgDoc( array_agg(
		svgPolygon(	ARRAY[ ax, ay, bx, by, cx, cy, dx, dy],
			style => svgStyle( 'stroke', 'white', 'stroke-width', '1',
				'fill', clr )
		) ),
  		'-110 -120 220 240'
  	) AS svg
  FROM tiling;
