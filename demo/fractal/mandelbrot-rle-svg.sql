--================================================
-- Mandelbrot set, as SVG, with Run-Length Encoding

-- psql -A -t -o mandelbrot-rle.svg  < mandelbrot-rle-svg.sql
--================================================

WITH RECURSIVE
x(i) AS ( SELECT i FROM generate_series(0, 400) AS t(i) ),
z(ix, iy, cx, cy, x, y, iter) AS (
    SELECT ix, iy, x::FLOAT, y::FLOAT, x::FLOAT, y::FLOAT, 0
      FROM        (SELECT -2.2 + 0.0074 * i, i FROM x) AS xgen(x, ix)
      CROSS JOIN  (SELECT -1.5 + 0.0074 * i, i FROM x) AS ygen(y, iy)
    UNION ALL
    SELECT ix, iy, cx, cy,
        x*x - y*y + cx AS x,
        y*x*2 + cy AS y, iter + 1
    FROM z
    WHERE x*x + y*y < 16.0
    AND iter < 27
    ),
itermax (ix, iy, iter) AS (
    SELECT ix, iy, MAX(iter) AS iter
    FROM z GROUP BY iy, ix
    ),
runstart AS (
    SELECT iy, ix, iter,
    CASE WHEN iter = LAG(iter) OVER (PARTITION BY iy ORDER By ix)
        THEN 0 ELSE 1 END AS runstart
    FROM itermax
    ),
runid AS (
    SELECT iy, ix, iter,
        SUM(runstart) OVER (PARTITION BY iy ORDER By ix) AS run
    FROM runstart
    ),
rungroup AS (
    SELECT iy, MIN(ix) ix, MAX(ix) ixend, MIN(iter) iter
    FROM runid
    GROUP BY iy, run
    ),
plot(iy, ix, ixend, iter, b, g) AS (
    SELECT iy, ix, ixend, iter,
    CASE    WHEN iter < 18 THEN (255 * iter / 18.0 )::integer
            WHEN iter < 27 THEN 255
            ELSE 0 END AS b,
    CASE    WHEN iter < 18 THEN 0
            WHEN iter < 27 THEN (255 * (iter - 18) / (27 - 18 ))::integer
            ELSE 0 END AS g
    FROM rungroup ORDER BY iy, ix
),
svg AS ( SELECT svgRect( ix, iy, ixend-ix+1, 1,
        style => svgStyle('fill', svgRGB(g, g, b) )
      ) AS svg
    FROM plot
)
SELECT svgDoc( array_agg( svg ),
          viewbox => '0 0 400 400',
          style => svgStyle('stroke-width', '0') )
  FROM svg;
