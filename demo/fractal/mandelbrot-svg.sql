-- ---------------------------------
-- Mandelbrot set, as SVG
-- ---------------------------------

-- psql -A -t -o mandelbrot.svg  < mandelbrot-svg.sql

WITH RECURSIVE
x(i) AS (
    VALUES(0)
UNION ALL
    SELECT i + 1 FROM x WHERE i < 401
),
Z(Ix, Iy, Cx, Cy, X, Y, I) AS (
    SELECT Ix, Iy, X::FLOAT, Y::FLOAT, X::FLOAT, Y::FLOAT, 0
    FROM
        (SELECT -2.2 + 0.0074 * i, i FROM x) AS xgen(x,ix)
    CROSS JOIN
        (SELECT -1.5 + 0.0074 * i, i FROM x) AS ygen(y,iy)
    UNION ALL
    SELECT Ix, Iy, Cx, Cy, X * X - Y * Y + Cx AS X, Y * X * 2 + Cy, I + 1
    FROM Z
    WHERE X * X + Y * Y < 16.0
    AND I < 27
),
Zt (Ix, Iy, I) AS (
    SELECT Ix, Iy, MAX(I) AS I
    FROM Z
    GROUP BY Iy, Ix
    ORDER BY Iy, Ix
),
plot(Ix, Iy, I, b, g) AS (
    SELECT Ix, Iy, I,
    CASE
        WHEN I < 18 THEN (255 * I / 18.0 )::integer
        WHEN I < 27 THEN 255
        ELSE 0 END AS b,
    CASE
        WHEN I < 18 THEN 0
        WHEN I < 27 THEN (255 * (I - 18) / (27 - 18 ))::integer
        ELSE 0 END AS g
    FROM Zt
    ORDER BY Iy, Ix
)
SELECT '<svg viewBox="0 0 400 400" style="stroke-width:0" xmlns="http://www.w3.org/2000/svg">'
    || E'\n'
    || string_agg(
        '<rect style="fill:rgb(' || g || ',' || g || ',' || b || ');"  '
          || ' x="' || Ix || '" y="' || Iy
          || '" width="1" height="1" />', E'\n' )
    || '</svg>' || E'\n' AS svg
  FROM plot;
