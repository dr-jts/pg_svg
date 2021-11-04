------------------------------------------------------------------
-- Demo of using SVG functions to display
-- map of High Points in each of the United States

-- Author: Martin Davis  2021

-- Requires:
--    Table ne.us_state - US states geometry in WGS84
------------------------------------------------------------------
-- psql -A -t -o us-highpt.svg  < us-highpt.sql

WITH
lower48 AS (SELECT name, geom FROM ne.us_state
                WHERE ST_YMax(geom) < 50
                  AND ST_YMin(geom) > 23 )
,high_pt(name, state, hgt_m, hgt_ft, lon, lat) AS (VALUES
-- ('Mount McKinley',      'AK', 6198, 20320,  -151.007222,63.069444)
 ('Mount Whitney',       'CA', 4421, 14505,  -118.292,36.578583)
,('Mount Elbert',        'CO', 4401, 14440,  -106.445358,39.11775)
,('Mount Rainier',       'WA', 4395, 14410,  -121.759889,46.853306)
,('Gannett Peak',        'WY', 4210, 13804,  -109.653333,43.184444)
--,('Mauna Kea',           'HI', 4208, 13796,  -155.468333,19.821028)
,('Kings Peak',          'UT', 4126, 13528,  -110.372778,40.776111)
,('Wheeler Peak',        'NM', 4014, 13161,  -105.416953,36.556697)
,('Boundary Peak',       'NV', 4007, 13140,  -118.3513,37.846097)
,('Granite Peak',        'MT', 3904, 12799,  -109.807222,45.163333)
,('Borah Peak',          'ID', 3862, 12662,  -113.7811,44.137389)
,('Humphreys Peak',      'AZ', 3850, 12633,  -111.677944,35.346342)
,('Mount Hood',          'ON', 3428, 11239,  -121.695919,45.373514)
,('Guadalupe Peak',      'TX', 2668,  8749,  -104.86,31.891111)
,('Harney Peak',         'SD', 2209,  7242,  -103.531089,43.865953)
,('Mount Mitchell',      'NC', 2039,  6684,  -82.265278,35.764722)
,('Clingsman Dome',      'TN', 2026,  6643,  -83.498611,35.562778)
,('Mount Washington',    'NH', 1918,  6288,  -71.303483,44.270828)
,('Mount Rogers',        'VA', 1747,  5729,  -81.544722,36.659722)
,('Panorama Point',      'NE', 1654,  5424,  -104.0305,41.0072)
,('Mount Marcy',         'NY', 1630,  5344,  -73.923889,44.1125)
,('Mount Katahdin',      'ME', 1606,  5267,  -68.921275,45.904356)
,('Black Mesa',          'OK', 1517,  4973,  -102.997368,36.93185)
,('Spruce Knob',         'WV', 1483,  4861,  -79.532778,38.699722)
,('Brasstown Bald',      'GA', 1459,  4784,  -83.810833,34.874167)
,('Mount Mansfield',     'VT', 1340,  4393,  -72.814167,44.543611)
,('Black Mountain',      'KT', 1263,  4145,  -82.893889,36.914167)
,('Mount Sunflower',     'KS', 1232,  4039,  -102.036667,39.021944)
,('Sassafras Mountain',  'SC', 1086,  3560,  -82.777222,35.064722)
,('White Butte',         'ND', 1069,  3506,  -103.301944,46.386667)
,('Mount Greylock',      'MA', 1064,  3487,  -73.166667,42.6375)
,('Backbone Mountain',   'MD', 1025,  3360,  -79.485833,39.237222)
,('Mount Davis',         'PA',  980,  3213,  -79.176667,39.785833)
,('Magazine Mountain',   'AK',  840,  2753,  -93.644722,35.167222)
,('Cheaha Mountain',     'AL',  733,  2405,  -85.809167,33.485556)
,('Mount Frissell',      'CT',  726,  2380,  -73.48,42.051111)
,('Eagle Mountain',      'MN',  702,  2301,  -90.56,47.8975)
,('Mount Arvon',         'MI',  604,  1979,  -88.155833,46.755556)
,('Timms Hill',          'WI',  595,  1951,  -90.195,45.451111)
,('High Point',          'NJ',  550,  1803,  -74.661667,41.320833)
,('Taum Sauk Mountain',  'MO',  540,  1772,  -90.727778,37.570278)
,('Hawkeye Point',       'IA',  509,  1670,  -95.708611,43.46)
,('Campbell Hill',       'OH',  472,  1549,  -83.713889,40.369722)
,('Hoosier Hill',        'IN',  383,  1257,  -84.850833,40.000278)
,('Charles Mound',       'IL',  377,  1235,  -90.2401,42.5042)
,('Jerimoth Hill',       'RI',  248,   812,  -71.778611,41.849444)
,('Woodall Mountain',    'MS',  246,   806,  -88.241667,34.787778)
,('Driskill Mountain',   'LA',  163,   535,  -92.896639,32.424811)
,('Ebright Azimuth',     'DE',  137,   448,  -75.518973,39.836033)
,('Fort Reno',           'DC',  125,   410,  -77.07686,38.95267)
,('Britton Hill',        'FL',  105,   345,  -86.281944,30.988333)
)
,highpt_geom AS (SELECT name, hgt_ft, ST_Point(lon, lat) AS geom,
    CASE WHEN hgt_ft > 14000 THEN '#ffffff'
         WHEN hgt_ft > 7000 THEN '#aaaaaa'
         WHEN hgt_ft > 5000  THEN '#ffff44'
         WHEN hgt_ft > 2000  THEN '#ff8800'
         WHEN hgt_ft > 1000  THEN '#888800'
                             ELSE '#88ff00'
    END AS clr
    FROM high_pt)
,shapes AS (
  SELECT geom, svgShape( geom,
    title => name,
    style => svgStyle(  'stroke', '#0000ff',
                        'stroke-width', 0.1::text,
                        'fill', 'url(#state)',
                        'stroke-linejoin', 'round' ) )
    svg FROM lower48
  UNION ALL
  SELECT geom, svgShape( geom, radius => .4,
    title => name || ' - ' || hgt_ft || ' ft',
    style => svgStyle(  'stroke', '#000000',
                        'stroke-width', 0.1::text,
                        'fill', clr  ) )
    svg FROM highpt_geom
)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( ST_Extent(geom), 2)),
    def => svgLinearGradient('state', '#8080ff', '#c0c0ff')
  ) AS svg FROM shapes;
