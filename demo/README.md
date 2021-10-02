# Demos for pg_svg

## Geom

SQL queries to create visualizations of geometric constructions

## Fractal

SQL queries to generate fractals

* Dragon Curve - `psql -A -t -o dragon-curve.wkt  < fractal/dragon-curve.sql`
* Hilbert Curve - `psql -A -t -o hilbert-curve.svg  < fractal/hilbert-curve-svg.sql`
* Mandelbrot Set - `psql -A -t -o mandelbrot-rle.svg  < fractal/mandelbrot-rle-svg.sql`
* Sierpinski Carpet - `psql -A -t -o sierpinski-carpet.svg  < fractal/sierpinski-carpet.sql`

## Tiling

SQL queries to generate planar tilings

* Penrose 3 tiling from L tile - `psql -A -t -o penrose3L.svg  < tiling/penrose3L-svg.sql`
* Penrose 3 tiling from S tiles - `psql -A -t -o penrose3S.svg  < tiling/penrose3S-svg.sql`
* Truchet tiling (SVG arcs) - `psql -A -t -o truchet-arc.svg  < tiling/truchet-arc-svg.sql`
* Truchet tiling (WKT curves to polygons) - `psql -A -t -o truchet-curve-poly.svg  < tiling/truchet-curve-poly-svg.sql`
* Truchet tiling (WKT curves to lines) - `psql -A -t -o truchet-curve-line.svg  < tiling/truchet-curve-line-svg.sql`
