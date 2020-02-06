# SVG Functions

A collection of PostgreSQL functions which allow easily creating SVG graphics.
The main goal of the API is to allow converting PostGIS geometries into styled SVG documents.
But the functions are written to be modular enough to allow using them
for simple geometry generation without PostGIS.

## Installation

```
psql < ../svg-lib.sql
```

## Functions

### svgDoc

Creates an SVG doc element from an array of content elements.

* `content` - an array of strings output as the content of the `<svg>` element
* `viewbox` - (opt) value of SVG viewBox attribute ( x y width height )
* `width` (opt) - width of view
* `height` (opt) - height of view
* `style` (opt) - specifies CSS styling at the document level (see `svgStyle` function)

### svgViewbox

Returns an SVG `viewBox` attribute value determined from the envelope of a geometry.
The PostGIS `ST_Extent` aggregate function can be use to determine the overall
envelope of the geometries being encoded.

* `extent` - (opt) a `geometry` providing the envelope to encode.

### svgShape

Encodes a PostGIS geometry as an SVG shape.

*  `geom` - geometry to encode
*  `class` - (opt) class attribute
*  `id` - (opt) id attribute
*  `style` - (opt) style attribute value
*  `attr` - (opt) additional attributes
*  `title` - (opt) title


### svgPolygon

Encodes an array of ordinates as an SVG polygon.

### svgStyle

Encodes an array of name,value pairs as a string of SVG CSS `name: value;` properties

* `param ...` - list of name/value pairs

Common styling CSS properties are given below,
or see full list [here](https://www.w3.org/TR/SVG/propidx.html).

* `fill` - fill color
* `fill-opacity` - opacity of fill; value in [ 0,1 ]
* `stroke` - line color
* `stroke-dasharray` - dashed line specifier, e.g. `2,4,1,4`
* `stroke-dashoffset` - offset of dashes
* `stroke-width` - line width
* `fill-opacity` - opacity of stroke; value in [ 0,1 ]

CSS colour specifiers include:

* `#RGGBB`,
* `colorname`
* `hsl(h,sl)` - can use the `svgHSL` function for this

### svgHSL

Encodes H,S,L values a CSS HSL function

### svgRandInt

Returns a random integer from a range [lo, hi] (inclusive)

### svgRandPick

Returns a random item from an array of integers
