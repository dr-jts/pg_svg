--======================================
-- PostGIS SVg functions
-- Martin Davis  2019

-- INSTALLATION
--    psql < pg-svg-lib.sql
--======================================

----------------------------------------
-- Function: svgDoc
----------------------------------------
CREATE OR REPLACE FUNCTION svgDoc(
  content text[],
  viewbox text DEFAULT '0 0 100 100',
  def text DEFAULT '',
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
  viewBoxAttr := ' viewBox="' || viewbox || '" ';

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

  svg := '<svg xmlns="http://www.w3.org/2000/svg"'
    || widthAttr || heightAttr
    || viewBoxAttr || styleAttr  || E'> \n';

  IF def <> '' THEN
    svg := svg || '<defs>' || E'\n';
    svg := svg || def || E'\n';
    svg := svg || '</defs>' || E'\n';
  END IF;

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
  geom_elem geometry[];
  isGrp boolean;
  gelem geometry;
  outstr text;
BEGIN

 attrs := _svgAttr( class, id, style, attr);
 geom_elem := ARRAY( SELECT (ST_Dump( geom )).geom );

IF cardinality( geom_elem ) = 0 THEN
  RETURN '';
END IF;

 isGrp := array_length( geom_elem,1 ) > 1;
 IF isGrp THEN
   outstr := '<g ' || attrs || '>' || E'\n';
   pathAttrs := '';
 ELSE
   outstr := '';
   pathAttrs := attrs;
 END IF;

 FOR i IN 1..array_length( geom_elem, 1 ) LOOP
   gelem := geom_elem[i];
   svg_pts := ST_AsSVG( gelem );
   tag := 'path';
   radiusAttr := '';
   -- points already have attribute names
   IF ST_Dimension( gelem ) > 0 THEN
     svg_pts := ' d="' || svg_pts || '" ';
   ELSE
     tag := 'circle';
     radiusAttr := ' r="' || radius || '" ';
   END IF;

   CASE ST_Dimension( gelem )
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
-- Parameters:
-- pts : array of X Y numbers.  Closing point is not needed
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

  IF title <> '' THEN
    svg_poly := '<g>' || svg_poly;
    svg_poly := svg_poly || '<title>' || title || '</title></g>';
  END IF;

  RETURN svg_poly;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgRect
-- Parameters:
--
----------------------------------------
CREATE OR REPLACE FUNCTION svgRect(
  x float8,
  y float8,
  width float8,
  height float8,
  class text DEFAULT '',
  id text DEFAULT '',
  style text DEFAULT '',
  attr text DEFAULT '',
  title text DEFAULT ''
)
RETURNS text AS
$$
DECLARE
  svg text;
BEGIN
  svg := '<rect '
    || _svgAttr( class, id, style, attr)
    || ' x="' || x || '" y="' || y
    || '" width="' || width || '" height="' || height
    || '" />';

  IF title <> '' THEN
    svg := '<g>' || svg;
    svg := svg || '<title>' || title || '</title></g>';
  END IF;

  RETURN svg;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgText
----------------------------------------
CREATE OR REPLACE FUNCTION svgText(
  loc geometry,
--TODO: add dx, dy offsets
  content text,
  class text DEFAULT '',
  id text DEFAULT '',
  style text DEFAULT '',
  attr text DEFAULT ''
)
RETURNS text AS
$$
DECLARE
  x float8;
  y float8;
BEGIN
-- TODO: generalize for all geom types (centroid?)
  x := ST_XMin(loc);
  y := -ST_YMin(loc);
  RETURN '<text'
    || ' x="' || x || '" y="' || y || '" '
    || _svgAttr( class, id, style, attr)
    || '>' || content || '</text>';
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
  strokewidth text DEFAULT '',
  fill text DEFAULT '',
  fillopacity text DEFAULT '',
  css text[] DEFAULT ARRAY[]::text[]
)
RETURNS text AS
$$
DECLARE
  style text;
BEGIN

  style := '';
  IF stroke <> '' THEN
    style := ' stroke: ' || stroke || ';';
  END IF;
  IF strokewidth <> '' THEN
    style :=  style || ' stroke-width: ' || strokewidth || ';';
  END IF;
  IF fill <> '' THEN
    style :=  style || ' fill: ' || fill || ';';
  END IF;
  IF fillopacity <> '' THEN
    style :=  style || ' fill-opacity: ' || fillopacity || ';';
  END IF;

  FOR i IN 1..array_length( css, 1)/2 LOOP
    style := style || ' ' || css[2*i-1] || ': ' || css[2*i] || ';';
  END LOOP;

  RETURN style;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgLinearGradient
----------------------------------------
CREATE OR REPLACE FUNCTION svgLinearGradient(
  id text,
  color1 text,
  color2 text
)
RETURNS text AS
$$
BEGIN
  RETURN '<linearGradient id="' || id || '" x1="0%" y1="0%" x2="100%" y2="0%">'
    || '<stop offset="0%" style="stop-color:' || color1 || ';stop-opacity:1" />'
    || '<stop offset="100%" style="stop-color:' || color2 || ';stop-opacity:1" />'
    || '</linearGradient>';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

----------------------------------------
-- Function: svgHSL
-- Encodes HSL function call
-- Parameters:
-- hue : value from 0 to 360
-- saturation : percentage value in 0..100 (default 100)
-- lightness : percentage value in 0..100 (default 50)
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
-- Function: svgRGB
-- Encodes RGB function call
-- Parameters:
-- red :   red value in 0..255
-- green : green value in 0..255
-- blue :  blue value in 0..255
----------------------------------------
CREATE OR REPLACE FUNCTION svgRGB(
  red integer,
  green integer,
  blue integer
)
RETURNS text AS
$$
BEGIN
  RETURN 'rgb(' || red || ',' || green || ',' || blue || ')';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION svgRGBf(
  red float8,
  green float8,
  blue float8
)
RETURNS text AS
$$
BEGIN
  RETURN svgRGB( 
    svgClamp(255 * red,   0, 255)::int,
    svgClamp(255 * green, 0, 255)::int, 
    svgClamp(255 * blue,  0, 255)::int);
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

----------------------------------------
-- Function: svgHSL
-- Encodes HSL function call
-- Parameters:
-- hue : value from 0 to 360
-- saturation : percentage value in 0..100 (default 100)
-- lightness : percentage value in 0..100 (default 50)
----------------------------------------
CREATE OR REPLACE FUNCTION svgClamp(
  val float8,
  min float8,
  max float8
)
RETURNS float8 AS
$$
BEGIN
  RETURN CASE WHEN val < min THEN min
    WHEN val > max THEN max
    ELSE val
  END CASE;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;
