--======================================
-- PostGIS SVg functions
-- Martin Davis  2019
--======================================

-- psql < svg-lib.sql

----------------------------------------
-- Function: svgDoc
----------------------------------------
CREATE OR REPLACE FUNCTION svgDoc(
  content text[],
  viewbox text DEFAULT '0 0 100 100',
  width integer DEFAULT -1,
  height integer DEFAULT -1,
  style text DEFAULT ''
)
RETURNS text AS
$$
DECLARE
  viewBoxAttr text;
  styleAttr text;
  widthAttr text;
  heightAttr text;
  svg text;
  xSize real;
  ySize real;
BEGIN
  viewBoxAttr := 'viewBox="' || viewbox || '" ';

  styleAttr := '';
  IF style <> '' THEN
    styleAttr := ' style="' || style || '" ';
  END IF;

  widthAttr := '';
  IF width >= 0 THEN
    widthAttr := ' width="' || width || '" ';
  END IF;

  heightAttr := '';
  IF height >= 0 THEN
    heightAttr := ' height="' || height || '" ';
  END IF;

  svg := '<svg ' || widthAttr || heightAttr
    || viewBoxAttr
    || styleAttr || 'xmlns="http://www.w3.org/2000/svg">' || E'\n';

  FOR i IN 1..array_length( content, 1) LOOP
    svg := svg || content[i] || E'\n';
  END LOOP;

  svg := svg || '</svg>';
  RETURN svg;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

----------------------------------------
-- Function: svgViewbox
-- Determines the SVG viewbox attribute value
-- from a geometry giving the extent of a set of geometries.
-- Parameters:
-- extent : extent geometry
----------------------------------------
CREATE OR REPLACE FUNCTION svgViewbox(
  extent geometry
)
RETURNS text AS
$$
DECLARE
  w float8;
  h float8;
  vbData text;
BEGIN
  w = ST_XMax(extent) - ST_XMin(extent);
  h = ST_YMax(extent) - ST_YMin(extent);
  vbData := ST_XMin(extent) || ' ' || -ST_YMax(extent) || ' ' || w || ' ' || h;
  RETURN vbData;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgShape
----------------------------------------
CREATE OR REPLACE FUNCTION svgShape(
  geom geometry,
  class text DEFAULT '',
  id text DEFAULT '',
  style text DEFAULT '',
  attr text DEFAULT '',
  title text DEFAULT '',
  radius float DEFAULT 1
)
RETURNS text AS
$$
DECLARE
  svg_geom text;
  svg_pts text;
  fillrule text;
  classAttr text;
  idAttr text;
  styleAttr text;
  attrs text;
  pathAttrs text;
  radiusAttr text;
  tag text;
  geom_dump geometry[];
  isGrp boolean;
  gcomp geometry;
  outstr text;
BEGIN

 attrs := _svgAttr( class, id, style, attr);
 geom_dump := ARRAY( SELECT (ST_Dump( geom )).geom );

 isGrp := array_length( geom_dump,1 ) > 1;
 IF isGrp THEN
   outstr := '<g ' || attrs || '>' || E'\n';
   pathAttrs := '';
 ELSE
   outstr := '';
   pathAttrs := attrs;
 END IF;

 FOR i IN 1..array_length( geom_dump,1 ) LOOP
   gcomp := geom_dump[i];
   svg_pts := ST_AsSVG( gcomp );
   tag := 'path';
   radiusAttr := '';
   -- points already have attribute names
   IF ST_Dimension(geom) > 0 THEN
     svg_pts := ' d="' || svg_pts || '" ';
   ELSE
     tag := 'circle';
     radiusAttr := ' r="' || radius || '" ';
   END IF;

   CASE ST_Dimension(geom)
   WHEN 1 THEN fillrule := ' fill="none" ';
   WHEN 2 THEN fillrule := ' fill-rule="evenodd" ';
   ELSE fillrule := '';
   END CASE;

   IF i > 1 THEN
     outstr := outstr || E'\n';
   END IF;

   svg_geom := '<' || tag || ' ' || pathAttrs || fillrule
     || radiusAttr
     || ' ' || svg_pts;
   outstr := outstr || svg_geom;

   IF title <> '' AND NOT isGrp THEN
     outstr := outstr || '><title>' || title || '</title>';
     outstr := outstr || '</' || tag || '>';
   ELSE
     outstr := outstr || ' />';
   END IF;
 END LOOP;

 IF isGrp THEN
   outstr := outstr || E'\n';
   IF title <> '' THEN
     outstr := outstr || '<title>' || title || '</title>';
   END IF;
   outstr := outstr || '</g>';
 END IF;

 RETURN outstr;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgPolygon
----------------------------------------
CREATE OR REPLACE FUNCTION svgPolygon(
  pts float8[],
  class text DEFAULT '',
  id text DEFAULT '',
  style text DEFAULT '',
  attr text DEFAULT '',
  title text DEFAULT ''
)
RETURNS text AS
$$
DECLARE
  svg_poly text;
  svg_pts text;
  classAttr text;
  idAttr text;
  styleAttr text;
  attrs text;
  sep text;
BEGIN

  svg_pts := '';
  FOR i IN 1..array_length( pts, 1 ) LOOP
    sep := CASE i % 2 WHEN 0 THEN ' ' ELSE ',' END;
    svg_pts := svg_pts || pts[i] || sep;
  END LOOP;

  svg_poly := '<polygon '
    || _svgAttr( class, id, style, attr)
    || ' points="' || svg_pts || '" />';

  RETURN svg_poly;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: _svgAttr
----------------------------------------
CREATE OR REPLACE FUNCTION _svgAttr(
  class text DEFAULT '',
  id text DEFAULT '',
  style text DEFAULT '',
  attr text DEFAULT ''
)
RETURNS text AS
$$
DECLARE
  classAttr text;
  idAttr text;
  styleAttr text;
  attrs text;
BEGIN
  classAttr := '';
  IF class <> '' THEN
    classAttr := ' class="' || class || '"';
  END IF;

  idAttr := '';
  IF id <> '' THEN
    idAttr := ' id="' || id || '"';
  END IF;

  styleAttr := '';
  IF style <> '' THEN
    styleAttr := ' style="' || style || '"';
  END IF;

  attrs := classAttr || idAttr || styleAttr || attr;

  RETURN attrs;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgStyle
-- Encodes CSS name:values from list of parameters
----------------------------------------
CREATE OR REPLACE FUNCTION svgStyle(
  VARIADIC arr text[]
)
RETURNS TEXT AS
$$
DECLARE
  strokeStr text;
  strokeWidthStr text;
  style text;
BEGIN
  style := '';
  FOR i IN 1..array_length( arr, 1)/2 LOOP
    style := style || arr[2*i-1] || ':' || arr[2*i] || '; ';
  END LOOP;
  RETURN style;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgStyleProp
-- Encodes named parameters as CSS name-values
----------------------------------------
CREATE OR REPLACE FUNCTION svgStyleProp(
  stroke text DEFAULT '',
  stroke_width real DEFAULT -1
)
RETURNS text AS
$$
DECLARE
  strokeStr text;
  strokeWidthStr text;
  style text;
BEGIN

  strokeStr := '';
  IF stroke <> '' THEN
    strokeStr :=  (' stroke:' || stroke || ';');
  END IF;

  strokeWidthStr := '';
  IF stroke_width >= 0 THEN
    strokeWidthStr :=  (' stroke-width:' || stroke_width || ';');
  END IF;

  style := strokeStr || strokeWidthStr;
  RETURN style;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;


----------------------------------------
-- Function: svgHSL
-- Encodes HSL function call
-- Parameters:
-- hue : value from 0 to 360
-- saturation : percentage value (default 100)
-- lightness : percentage (default 50)
----------------------------------------
CREATE OR REPLACE FUNCTION svgHSL(
  hue float8,
  saturation float8 DEFAULT 100,
  lightness float8 DEFAULT 50
)
RETURNS text AS
$$
BEGIN
  RETURN 'hsl(' || hue || ',' || saturation || '%,' || lightness || '%)';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgRandInt
-- Returns a random integer in a range
-- Parameters:
-- lo : low value in range (inclusive)
-- hi : highest value in range (inclusive)
----------------------------------------
CREATE OR REPLACE FUNCTION svgRandInt(
  lo integer,
  hi integer
)
RETURNS integer AS
$$
BEGIN
  RETURN floor(random() * (hi - lo + 1) ) + lo;
END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;

----------------------------------------
-- Function: svgRandPick
-- Returns a random value from an array of ints
-- Parameters:
-- pick[] : array of values
----------------------------------------
CREATE OR REPLACE FUNCTION svgRandPick(
  VARIADIC pick integer[]
)
RETURNS integer AS
$$
DECLARE
  i integer;
BEGIN
  i := floor(random() * array_length( pick, 1) ) + 1;
  RETURN pick[i];
END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;
