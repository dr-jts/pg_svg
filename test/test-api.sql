------------------------------------------------------------------
-- Test pg_svg API
-- Author: Martin Davis  2024

-- psql -A -t -o test-api.svg  < test/test-api.sql
------------------------------------------------------------------

WITH shapes(svg) AS (VALUES
   ( svgRect(0, 50, 20, 40,
        rx => 5, ry => 2,
        style => svgStyleProp(stroke => svgRGB(200, 0, 100),
                            strokewidth => '10',
                            fill => svgHSL(125, 80, 40),
                            fillopacity => '0.5'
                        )
   ) )
  ,( svgEllipse(50, 100, 20, 40, 
        style => svgStyle('stroke', '#0000ff', 'fill', '#00ffff') 
    ) )
)
SELECT svgDoc( array_agg( svg ),
    viewbox => '0 0 400 400'
  ) AS svg FROM shapes;
