# API

## Document Structure Functions

### svgDoc

Creates an SVG `svg` document element from an array of content elements.

* `content` - an array of `text` values output as the content of the `<svg>` element
* `viewbox` - *[optional]* value of SVG viewBox attribute ( `x y width height` )
  * see [`svgViewbox`](#svgViewbox)
* `width` - *[optional]* width of view
* `height` - *[optional]* height of view
* `style` - *[optional]* specifies CSS styling at the document level 
  * see [`svgStyle`](#svgStyle)
* `def` - *[optional]* specifies a definition
  * see [`svgLinearGradient`](#svgLinearGradient)

### svgViewbox

Returns an SVG `viewBox` attribute value determined from the envelope of a geometry.

* `extent` - a `geometry` providing the envelope to encode.

The PostGIS `ST_Extent` aggregate function can be use to determine the overall
envelope of the geometries being encoded.

### svgGroup

Creates an SVG `g` group element from an array of content elements.

* `content` - an array of `text` values output as the content of the `<g>` element
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value
  * see [`svgStyle`](#svgStyle)
* `attr` - *[optional]* additional attributes

## Shape Functions

### svgShape

Encodes a PostGIS geometry as an SVG shape.

* `geom` - geometry to encode
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value
  * see [`svgStyle`](#svgStyle)
* `attr` - *[optional]* additional attributes
* `title` - *[optional]* title

### svgPolygon

Encodes an array of XY ordinates as an SVG `polygon`.

* `pts` - array of X Y ordinates
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value 
  * see [`svgStyle`](#svgStyle)
* `attr` - *[optional]* additional attributes
* `title` - *[optional]* title

### svgRect

Encodes an array of XY ordinates as an SVG `polygon`.

* `x` - X location of bottom-left corner
* `y` - Y location of bottom-left corner
* `width` - rectangle width
* `height` - rectangle height
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value 
  * see [`svgStyle`](#svgStyle)
* `attr` - *[optional]* additional attributes
* `title` - *[optional]* title

### svgEllipse

Creates an SVG `ellipse` with centre `x, y` and radii `rx` and `ry`

* `x` - X location of bottom-left corner
* `y` - Y location of bottom-left corner
* `width` - rectangle width
* `height` - rectangle height
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value 
  * see [`svgStyle`](#svgStyle)
* `attr` - *[optional]* additional attributes
* `title` - *[optional]* title

### svgText

Encodes text starting at position `loc` as an SVG `text` element.

* `loc` - Point geometry giving location of text
* `content` - text value
* `class` - *[optional]* class attribute
* `id` - *[optional]* id attribute
* `style` - *[optional]* style attribute value
* `attr` - *[optional]* additional attributes
* `title` - *[optional]* title

Relevant style CSS properties include:

* `text-anchor` - value of `start | middle | end | inherit`
* `font` - full font specifier.  E.g. `10px Verdana,Helvetica,Arial,sans-serif`
* `font-style` - value of `normal | italic | oblique`
* `font-weight` - value of `normal | bold | bolder | lighter | <number>`

## Styling Functions

### svgStyle

Encodes an array of name,value pairs as a string of SVG CSS `name: value;` properties

* `param ...` - list of name/value pairs

Common styling CSS properties are given below.
For full list see [W3C SVG spec](https://www.w3.org/TR/SVG/propidx.html).

* `fill` - fill color
* `fill-opacity` - opacity of fill; value in [ 0,1 ]
* `stroke` - line color
* `stroke-dasharray` - dashed line specifier, e.g. `2,4,1,4`
* `stroke-dashoffset` - offset of dashes
* `stroke-width` - line width
* `fill-opacity` - opacity of stroke; value in [ 0,1 ]

CSS color specifiers include:

* `#RRGGBB`
* `colorname`
* `hsl(h,s,l)` - can use the `svgHSL` function to create this
* `url(#id)` - reference to a gradient definition

### svgRGB

Encodes Red,Bliue,Green values as a CSS HSL function `rgb(R,G,B)`.

* `red` - a value in 0..255
* `green` - a value in 0..255
* `blue` - a value in 0..255

### svgHSL

Encodes Hue,Saturation,Lightness values as a CSS HSL function `hsl(H,S,L)`.

* `hue` - a hue value in degrees (from 0 through 360, with 0 = red, 120 = green, and 240 = blue)
* `saturation` - *[optional]* a percentage, default 100
* `lightness` - *[optional]* a percentage, default 50

### svgLinearGradient

Returns an SVG `linearGradient` definition element.
The element is provided as a `def` to `svgDoc`.
A CSS `fill` property value can refer to the gradient using the specifier `url(#id)`

* `id` - the gradient id
* `color1` - the start color of the gradient
* `color2` - the end color of the gradient

## Utility Functions

### svgRandInt

Returns a random integer from the range [lo, hi] (inclusive)

### svgRandPick

Returns a random item from an array of integers

### svgClamp

Returns a random item from an array of integers