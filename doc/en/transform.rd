=begin
== Rubygame::Transform
--- Transform.rotozoom( surface, angle, zoom, smooth )
    Return a rotated and/or zoomed version of the given surface. 
    Note that rotating a Surface anything other than a multiple of 90 degrees 
    will cause the new surface to be larger than the original (since all 
    Surfaces are rectangular).
        * ((|angle|)): counter-clockwise degrees to rotate.
        * ((|zoom|)): scaling factor.
        * ((|smooth|)): whether to anti-alias the new surface. If true, the new 
          surface will be 32bit RGBA.

--- Transform.rotozoom_size( size, angle, zoom )
    Pretends to transform a surface of the given size, by the given amounts, 
    and returns the size of the surface that would result.
    This should be faster than actually rotozooming a surface and then getting 
    the size of that surface.
    	* ((|size|)): size of the original surface.
    	* ((|angle|)): the angle to pretend to rotate by.
    	* ((|zoom|)): the factor to pretend to scale by.

--- Transform.zoom( surface, zoom, smooth )
    Return a zoomed version of the given surface. 
        * ((|zoom|)): the scale factors for the x and y axes, in the form
          (({[x,y]})). If only one zoom factor is specified, it is applied to
          both axes.
        * ((|smooth|)): whether to anti-alias the new surface. If true, the new 
          surface will be 32bit RGBA.

--- Transform.zoom_size( size, zoom )
    Pretends to transform a surface of the given size, by the given amounts, 
    and returns the size of the surface that would result.
    This should be faster than actually zooming a surface and then getting 
    the size of that surface.
    	* ((|size|)): size of the original surface.
    	* ((|zoom|)): the factor to pretend to scale by.
    
=end
