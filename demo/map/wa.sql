------------------------------------------------------------------
-- Demo of using SVG to display a simplified WA polygon

-- Author: Martin Davis  2024

-- psql -A -t -o wa.svg  < wa.sql
------------------------------------------------------------------

WITH wa(abbrev, geom) AS (VALUES
  ('WA', 'POLYGON ((-122.6 48.4, -122.5 48.5, -122.5 48.8, -122.7 48.8, -122.8 49, -117 49, -117 46.4, -116.9 46, -119 46, -119.1 45.9, -119.6 45.9, -120.4 45.7, -120.6 45.7, -121.2 45.6, -121.3 45.7, -121.8 45.7, -122.2 45.5, -122.8 45.6, -122.8 45.9, -122.9 46.1, -123.2 46.2, -123.3 46.1, -123.5 46.3, -124.1 46.3, -124.1 46.6, -124 46.6, -123.8 46.7, -124.1 46.7, -124.1 46.9, -123.8 47, -124.1 47, -124.2 46.9, -124.2 47.3, -124.3 47.3, -124.4 47.6, -124.6 47.9, -124.7 48.2, -124.7 48.4, -124 48.2, -123.4 48.1, -123.1 48.1, -122.8 48.1, -122.7 47.9, -122.9 47.8, -122.9 47.6, -122.8 47.7, -122.5 47.9, -122.5 47.8, -122.6 47.7, -122.5 47.5, -122.6 47.3, -122.5 47.3, -122.3 47.3, -122.4 47.8, -122.2 48, -122.5 48.3, -122.6 48.4))'::geometry)
),
shape AS (SELECT geom, 
    svgShape( geom,
            title => 'Washington State',
            style => svgStyleProp(  fill => '#99b7ff',
                                    stroke => '#255580',
                                    strokewidth => '.1'  )) AS svg 
        FROM wa
    UNION ALL (SELECT NULL,
        svgText(ST_Centroid(geom), abbrev, 
                style => svgStyleProp( fill=> '#27863a', font=> 'bold 2px serif',
                      css=> ARRAY[ 'text-anchor', 'middle' ] ))
        FROM wa
    )
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 2))
  ) AS svg FROM shape;