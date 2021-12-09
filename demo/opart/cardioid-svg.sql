------------------------------------------------------------------
-- Demo of using SVG functions to display Cardioid from tangent
--	line sigments 
-- Author: Bruce Rindahl

-- psql -At -o cardioid.svg  < cardioid-svg.sql
------------------------------------------------------------------

 WITH parameters AS (
         SELECT 100.0 AS num_points,
            100.0 AS radius
        ), rows AS (
         SELECT generate_series(0::numeric, parameters.num_points - 1::numeric) AS id
           FROM parameters
        ), coordinates AS (
         SELECT rows.id,
            cos((rows.id / parameters.num_points)::double precision * pi() * 2::double precision) * parameters.radius::double precision AS x,
            sin((rows.id / parameters.num_points)::double precision * pi() * 2::double precision) * parameters.radius::double precision AS y
           FROM rows,
            parameters
        ), points AS (
         SELECT coordinates.id,
            st_makepoint(coordinates.x, coordinates.y) AS geom
           FROM coordinates
        ), cardioid as (
			-- Cardioid lines
		 SELECT st_makeline(pts2.geom, pts1.geom) AS geom
		   FROM parameters,
		    ( SELECT points.id,
		            points.geom
		           FROM points) pts1,
		    ( SELECT points.id,
		            points.geom
		           FROM points) pts2
			  WHERE pts1.id = mod(pts2.id * 2::numeric, parameters.num_points)
		UNION ALL  -- Outside circle segments
		 SELECT st_makeline(pts2.geom, pts1.geom) AS geom
		   FROM parameters,
		    ( SELECT points.id,
		            points.geom
		           FROM points) pts1,
		    ( SELECT points.id,
		            points.geom
		           FROM points) pts2
		  WHERE pts1.id = mod(pts2.id + 1::numeric, parameters.num_points)
		),
		shapes AS (
		  SELECT svgShape( (SELECT st_collect(geom) as geom from cardioid),
		            title => 'Cardioid',
		            style => svgStyle('fill', 'none',
	                     'stroke', 'black',
                        'stroke-width', 0.1::text ) )
		    AS svg 
		)
SELECT svgDoc( array_agg( svg ),
    viewbox => svgViewbox( ST_Expand( (SELECT ST_Extent(geom) from cardioid), 20) )
  ) AS svg FROM shapes;