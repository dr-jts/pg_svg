--========================================
-- Truchet tiling with SVG Arc tiles
--========================================
-- psql -A -t -o truchet-arc.svg  < truchet-arc-svg.sql

WITH
grid(x, y, type) AS (
    SELECT 10 * x, 10 * y,
        CASE WHEN random() > 0.5 THEN 1 ELSE -1 END AS type
    FROM generate_series(0, 20) AS t(x)
    CROSS JOIN generate_series(0, 20) as s(y)
),
truchet( svg )  AS (
    SELECT '<path d="' || CASE type WHEN 1 THEN
            'M ' || (x + 5) || ' ' || y
            || ' A 5 5 -45 0 1 ' || x || ' ' || (y + 5)
            || 'M ' || (x + 10) || ' ' || (y + 5)
            || ' A 5 5 -45 0 0 ' || x + 5 || ' ' || (y + 10)
        ELSE
            'M ' || x ||' ' || y + 5
            || ' A 5 5 -45 0 1 ' || x + 5 || ' ' || y + 10
            || 'M ' || x + 5 || ' ' || y
            || ' A 5 5 -45 0 0 ' || x + 10 || ' ' || y + 5
        END
        || '" />'
      FROM grid
)
SELECT svgDoc( array_agg( svg ),
  viewbox => '-5 -5 220 220',
  style => svgStyle('stroke-width', '3', 'stroke','royalblue')
  ) AS svg FROM truchet;
