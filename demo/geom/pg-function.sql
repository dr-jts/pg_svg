------------------------------------------------------------------
-- Demo of using SVG to display PostGIS functions
-- Author: Martin Davis  2021

-- psql -At -o pg-function.html  < pg-function.sql
------------------------------------------------------------------

WITH data(geom) AS (
  SELECT 'MULTIPOLYGON (((13.7 -16.8, 15.1 -16.2, 16 -15.4, 17.1 -13, 17.4 -9.6, 17.4 41.9, 17.1 45.2, 16.4 47.1, 15 48, 12.7 48.3, 11.6 48.2, 10.1 48, 10.1 49.8, 15.2 51.4, 26 55.1, 26.4 54.9, 26.5 54.3, 26.5 47.1, 29.8 50.2, 32.7 52.3, 35.2 53.6, 37.6 54.6, 40.1 55.1, 42.7 55.3, 46.2 54.9, 49.6 53.8, 52.6 51.8, 55.4 49, 57.7 45.6, 59.4 41.6, 60.4 37, 60.7 31.8, 60.3 26.5, 59.1 21.5, 57.1 16.8, 54.3 12.3, 50.9 8.5, 49.1 7, 47.1 5.8, 45 4.8, 42.9 4.1, 40.6 3.7, 38.2 3.6, 35.4 3.8, 33 4.3, 29.7 5.9, 26.7 8.4, 26.7 -9.1, 27.1 -13.5, 27.7 -14.9, 28.4 -15.7, 31.3 -16.8, 36.2 -17.4, 36.2 -19.3, 9.6 -19.3, 9.6 -17.5, 13.7 -16.8), (28.4 11.3, 29.5 10.1, 30.8 9.1, 33.8 7.7, 37.4 7.3, 40.1 7.6, 42.7 8.7, 45.1 10.5, 47.3 13, 49 16.2, 50.3 19.9, 51.1 24.2, 51.4 29.1, 51.1 33.7, 50.3 37.7, 49 41.1, 47.1 43.9, 44.9 46, 42.5 47.5, 39.9 48.4, 37.2 48.7, 35.3 48.6, 33.4 48.1, 31.6 47.4, 30 46.3, 28.5 45.1, 27.5 43.9, 26.9 42.7, 26.7 41.5, 26.7 14.5, 28.4 11.3)), ((67.3 34.7, 68.6 39.4, 70.7 43.7, 73.6 47.6, 77.3 50.8, 81.4 53.1, 86 54.5, 91.1 55, 96.2 54.5, 100.8 53.2, 105 51, 108.7 48, 111.8 44.2, 113.9 39.9, 115.2 34.9, 115.7 29.4, 115.3 24.3, 114 19.4, 111.9 15, 108.9 10.9, 105.3 7.4, 103.3 6.1, 101.2 4.9, 96.5 3.5, 91.4 3, 86.5 3.4, 81.9 4.9, 77.8 7.2, 74 10.5, 70.9 14.6, 68.6 19.1, 67.3 24.1, 66.9 29.5, 67.3 34.7), (87.6 51.6, 85.6 51, 83.9 50.2, 82.3 48.9, 79.9 46.1, 78.2 42.3, 77.2 37.6, 76.9 32.1, 77.2 27.4, 78 22.9, 79.3 18.5, 81.2 14.3, 83.6 10.7, 86.4 8.1, 87.9 7.2, 89.6 6.5, 93.2 6, 96 6.4, 98.5 7.4, 100.7 9.1, 102.5 11.6, 103.9 14.5, 104.9 17.9, 105.5 21.8, 105.7 26, 105.4 30.6, 104.7 35.1, 103.4 39.4, 101.6 43.5, 99.3 47.1, 96.5 49.7, 95 50.6, 93.3 51.2, 89.6 51.7, 87.6 51.6)), ((126.5 21.5, 127.9 16.1, 129.8 12.1, 131.9 9.5, 134.4 7.6, 137.4 6.5, 140.8 6.1, 142.7 6.3, 144.4 6.7, 145.9 7.4, 147.1 8.4, 148.2 9.6, 148.9 10.9, 149.3 12.4, 149.5 14.1, 149.1 16.3, 148.1 18.5, 146.3 20.5, 143.4 22.6, 137.4 26, 131.7 29.5, 129.5 31.3, 127.7 33.1, 126.3 35, 125.4 37, 124.8 39.2, 124.6 41.6, 124.8 44.5, 125.7 47.1, 127 49.4, 128.9 51.5, 131.2 53.2, 133.7 54.4, 136.5 55.1, 139.7 55.3, 142.6 55.1, 145.9 54.3, 149.7 53.2, 151.1 53.5, 151.9 54.3, 153.2 54.3, 153.5 39.3, 151.9 39.3, 150.6 44, 149 47.4, 147.1 49.8, 144.9 51.5, 142.3 52.5, 139.4 52.8, 137.6 52.7, 136 52.2, 134.7 51.5, 133.5 50.5, 132.5 49.3, 131.9 48, 131.5 46.6, 131.3 45.1, 131.8 42.7, 133.2 40.4, 135.5 38.3, 138.7 36.3, 145.8 32.5, 150.8 29.2, 152.8 27.5, 154.4 25.7, 155.6 23.9, 156.5 22, 157.1 20, 157.2 18, 157 15, 156.1 12.2, 154.6 9.8, 152.5 7.6, 149.9 5.9, 147 4.6, 143.7 3.9, 140.1 3.6, 136.6 3.9, 132.8 4.7, 128 5.8, 126.8 5.3, 126.1 4.2, 124.7 4.2, 124.7 21.5, 126.5 21.5)), ((189.8 50.2, 178.9 50.2, 178.7 19.3, 178.9 15.8, 179.4 13.2, 180.2 11.5, 181.3 10.4, 182.8 9.7, 184.5 9.5, 186.3 9.7, 187.8 10.4, 191.1 13.3, 192.5 12.1, 191.3 10.5, 188.4 7.3, 185.4 5.2, 182.3 4, 179.4 3.6, 176.5 4, 174.1 5, 172.2 6.8, 170.8 9.3, 169.9 12.9, 169.6 17.7, 169.6 50.2, 163.7 50.2, 163.3 50.6, 163.2 51, 163.4 51.8, 165 53.2, 168.1 56, 170.3 58.1, 178 68.2, 178.8 68.1, 179 67.3, 179 54.1, 189.8 54.1, 189.8 50.2)), ((239.6 78.2, 245.8 76.8, 252.9 75.1, 254.9 75.3, 256.3 76, 257.2 77.1, 257.9 78.6, 260.4 78.6, 261.2 55.5, 258.7 55.5, 255.3 62.5, 253.5 65.2, 251.7 67.4, 248.2 70.4, 244.3 72.6, 239.8 73.8, 234.8 74.3, 229.7 73.8, 224.9 72.3, 220.4 69.8, 216.2 66.2, 214.4 64.1, 212.7 61.6, 211.4 58.8, 210.2 55.6, 209.3 52.2, 208.7 48.4, 208.2 39.8, 208.7 32.7, 209.3 29.4, 210.2 26.3, 211.3 23.5, 212.7 20.8, 214.3 18.4, 216.2 16.1, 218.3 14.1, 220.4 12.4, 222.7 10.9, 225.1 9.7, 227.7 8.8, 230.3 8.1, 233.1 7.7, 236 7.6, 240.6 8, 245.7 9.1, 248.9 10.3, 250.6 11.4, 251.3 12.5, 251.6 14.1, 251.6 31.7, 251.5 34.5, 251.1 36.8, 250.6 38.5, 249.8 39.6, 248.6 40.3, 246.9 40.8, 241.9 41.5, 241.9 43.5, 269.9 43.5, 269.9 41.5, 266.5 41, 264.5 40.2, 263.5 39.1, 262.8 37.5, 262.4 35.5, 262.2 33.1, 262.2 11.5, 261.6 10.4, 259.9 9.2, 256.9 7.8, 252.8 6.3, 248.1 4.9, 243.5 3.9, 239 3.3, 234.6 3.1, 230.6 3.2, 226.8 3.7, 223.2 4.4, 219.7 5.4, 216.4 6.7, 213.3 8.4, 210.3 10.3, 207.4 12.5, 204.6 15.2, 202.1 18.1, 200 21.2, 198.3 24.6, 196.9 28.2, 196 32, 195.4 36, 195.2 40.3, 195.4 44, 195.8 47.7, 196.6 51.1, 197.7 54.5, 199 57.7, 200.7 60.8, 202.7 63.7, 204.9 66.5, 207.7 69.4, 210.7 71.8, 213.9 73.9, 217.4 75.6, 221 76.9, 224.9 77.9, 229 78.4, 233.3 78.6, 239.6 78.2)), ((279 7.4, 280.9 7.9, 282.2 8.6, 283 9.7, 283.7 11.4, 284 13.7, 284.2 16.5, 284.2 65.4, 284 68.2, 283.7 70.4, 283 72.1, 282.2 73.2, 280.9 74, 279 74.6, 273.5 75.3, 273.5 77.3, 306 77.3, 306 75.3, 300.5 74.6, 298.6 74, 297.3 73.2, 296.4 72.1, 295.8 70.4, 295.4 68.2, 295.3 65.4, 295.3 16.5, 295.4 13.7, 295.8 11.4, 296.4 9.7, 297.3 8.6, 298.6 7.9, 300.5 7.4, 306 6.6, 306 4.6, 273.5 4.6, 273.5 6.6, 279 7.4)), ((318.1 20.1, 319.8 17.3, 321.6 14.9, 325.1 11.6, 328.9 9.2, 333.2 7.7, 337.8 7.3, 340.4 7.5, 342.7 8.1, 344.9 9.1, 346.9 10.6, 348.6 12.4, 349.8 14.6, 350.5 17.1, 350.8 19.9, 350.5 22.5, 349.8 24.9, 348.6 27.1, 346.9 29.2, 343 32.4, 336.3 36.8, 326.9 42.6, 323.1 45.3, 320.1 48, 318.1 50.7, 316.6 53.5, 315.8 56.4, 315.5 59.5, 315.8 63.5, 316.9 67.1, 318.6 70.4, 321 73.4, 324 75.8, 327.4 77.5, 331.3 78.5, 335.6 78.9, 339.8 78.4, 344.7 77, 350.7 75.2, 352.4 75.4, 353.5 76.1, 354.2 77.3, 354.7 78.9, 357 78.9, 359.4 55.5, 356.8 55.5, 355.2 60.4, 353.3 64.5, 350.9 67.8, 348.2 70.2, 345.2 72.1, 342.3 73.4, 339.4 74.2, 336.4 74.4, 334.3 74.3, 332.2 73.8, 330.3 72.9, 328.6 71.8, 327.1 70.3, 326.1 68.6, 325.4 66.6, 325.2 64.4, 325.4 62.4, 325.9 60.5, 326.7 58.7, 327.8 57.2, 331.1 54, 335.8 50.8, 345.5 44.8, 349.7 42.1, 353.2 39.5, 356 37, 358.2 34.6, 359.8 32.1, 361 29.4, 361.6 26.5, 361.9 23.4, 361.5 19.3, 360.2 15.5, 358.2 12.1, 355.4 9, 351.9 6.4, 347.9 4.6, 343.5 3.6, 338.7 3.2, 333.5 3.7, 328.1 5.1, 321.7 7.1, 320.1 6.8, 319.1 5.9, 318.2 3.4, 315.8 3.4, 312.5 26.7, 315 26.7, 318.1 20.1)))'::geometry
),
dataSize AS ( SELECT geom, ST_YMax(geom) - ST_YMIn(geom) AS height, ST_XMax(geom) - ST_XMIn(geom) AS width FROM data
),
dataMask(geom, mask) AS (
  SELECT geom, ST_Buffer(ST_Scale(
                            ST_Boundary(ST_Buffer(ST_Centroid(geom), height/3)),
                            ST_Point((width + 50) / height , 1), ST_Centroid(geom)), 10) AS mask
  FROM dataSize
),
funUnary(name, geom, result) AS (
  SELECT 'ST_Centroid', geom, ST_Centroid(geom) FROM data
  UNION ALL
  SELECT 'ST_PointOnSurface', geom, ST_PointOnSurface(geom) FROM data
  UNION ALL
  SELECT 'ST_Boundary', geom, ST_Boundary(geom) FROM data
  UNION ALL
  SELECT 'ST_Buffer', geom, ST_Buffer(geom, 10) FROM data
  UNION ALL
  SELECT 'ST_Buffer (negative)', geom, ST_Buffer(geom, -3) FROM data
  UNION ALL
  SELECT 'ST_OffsetCurve', geom, ST_OffsetCurve(ST_Boundary(geom), 5) FROM data
  UNION ALL
  SELECT 'ST_ConvexHull', geom, ST_ConvexHull(geom) FROM data
  UNION ALL
  SELECT 'ST_ConcaveHull', geom, ST_ConcaveHull(geom, 0.9) FROM data
  UNION ALL
  SELECT 'ST_Envelope', geom, ST_Envelope(geom) FROM data
  UNION ALL
  SELECT 'ST_OrientedEnvelope', geom, ST_OrientedEnvelope(geom) FROM data
  UNION ALL
  SELECT 'ST_MinimumBoundingCircle', geom, ST_MinimumBoundingCircle(geom) FROM data
  UNION ALL
  SELECT 'ST_VoronoiPolygons', geom, ST_ClipByBox2D(ST_VoronoiPolygons(geom), ST_Expand(geom, 20)) FROM data
  UNION ALL
  SELECT 'ST_DelaunayTriangles', geom, ST_DelaunayTriangles(geom) FROM data
  UNION ALL
  SELECT 'ST_ReducePrecision', geom, ST_ReducePrecision(geom, 8) FROM data
  UNION ALL
  SELECT 'ST_SimplifyPreserveTopology', geom, ST_SimplifyPreserveTopology(geom, 5) FROM data
  UNION ALL
  SELECT 'ST_SimplifyVW', geom, ST_SimplifyVW(geom, 20) FROM data
  UNION ALL
  SELECT 'ST_ChaikinSmoothing', geom, ST_ChaikinSmoothing(geom, 5) FROM data
  UNION ALL
  SELECT 'ST_GeneratePoints', geom, ST_GeneratePoints(geom, 500) FROM data
  UNION ALL
  SELECT 'ST_Rotate', geom, ST_Rotate(geom, 0.3, ST_Centroid(geom)) FROM data
  UNION ALL
  SELECT 'ST_Scale', geom, ST_Scale(geom, 'POINT(0.5 0.5)', ST_Centroid(geom)) FROM data
  UNION ALL
  SELECT 'ST_Translate', geom, ST_Translate(geom, 20, 20) FROM data
  UNION ALL
  SELECT 'ST_Subdivide', MAX(geom)::geometry, ST_Collect(result)
      FROM (SELECT geom, ST_Subdivide(geom, 20) AS result FROM data) AS s
),
funBinary(name, geom, mask, result) AS (
  SELECT 'ST_Intersection', geom, mask, ST_Intersection(geom, mask) FROM dataMask
  UNION ALL
  SELECT 'ST_Union', geom, mask, ST_Union(geom, mask) FROM dataMask
  UNION ALL
  SELECT 'ST_Difference', geom, mask, ST_Difference(geom, mask) FROM dataMask
  UNION ALL
  SELECT 'ST_SymDifference', geom, mask, ST_SymDifference(geom, mask) FROM dataMask
),
svgUnary AS (
  SELECT name, svgShape( result, radius => 1,
            style => svgStyle('fill', '#ffffc0',
                        'stroke', '#000000',
                        'stroke-width', '0.5%' ) )
        || svgShape( geom,
            style => svgStyle('fill', '#a0a0ff', 'fill-opacity', '33%',
                        'stroke', '#0606ff',
                        'stroke-width', '0.3%' ) )
    AS svg,
    ST_Envelope(ST_Collect( ARRAY[geom, result]) ) AS env
    FROM funUnary
),
svgBinary AS (
  SELECT name,
        svgShape( geom,
            style => svgStyle('fill', '#a0a0ff', 'fill-opacity', '30%',
                        'stroke', '#a0a0ff',
                        'stroke-width', '0.3%' ) )
        || svgShape( mask,
            style => svgStyle('fill', '#ffc0c0', 'fill-opacity', '30%',
                        'stroke', '#ff8080',
                        'stroke-width', '0.2%' ) )
        || svgShape( result, radius => 1,
            style => svgStyle('fill', '#ffffc0',
                        'stroke', '#000000',
                        'stroke-width', '0.5%' ) )
    AS svg,
    ST_Envelope(ST_Collect( ARRAY[geom, mask, result]) ) AS env
    FROM funBinary
),
doc AS (SELECT name, svgDoc( ARRAY[ svg ],
    width => '600',
    viewbox => svgViewbox( ST_Expand( env, 5) )
  ) AS svg FROM (SELECT * FROM svgUnary UNION ALL SELECT * FROM svgBinary) t
)
SELECT '<html><body><table>' || E'\n'
      || string_agg( '<tr><td><h2>' || name || '</h2></td><td>'
      || svg || '</td></tr>', E'\n' )
      || '</table></body></html>' || E'\n'
      FROM doc;
