=begin
== Rubygame::Surface
--- Surface.new( size, depth, flags )
    Create a new instance of the Surface class, with the given dimensions, 
    depth, and flags. A display window must be set using ((<Display.set_mode>))
    before creating a Surface.
        * ((|size|)): an Array, (({[w,h]})), with the width and height of the
          new Surface, in pixels
        * ((|depth|)): the color depth (bits per pixel) of the new Surface. 
          This argument may be omitted or (({nil})), in which case the best 
          available depth will be used. Common values include 8, 16, 24, and 
          32. Large color depths allow more subtle color differences, but are 
          slower and use more memory than small depths.
        * ((|flags|)): a bitwise OR'd ( | ) list of the following flags. This 
          argument may be omitted or (({nil})), in which case the Surface will 
          be a normal, software surface (this is not necessarily a bad thing).
            * ((<SWSURFACE|Constants>)): (default) request a software surface.
            * ((<HWSURFACE|Constants>)): request a hardware-accelerated 
              surface (using a graphics card), if available.
            * ((<SRCCOLORKEY|Constants>)): request a colorkeyed surface. 
              ((<Surface#set_colorkey>)) will also enable colorkey. See
              ((<Surface#set_colorkey>)) for a description of colorkeys
            * ((<SRCALPHA|Constants>)): request an alpha channel. 
              ((<Surface#set_alpha>)) will also enable alpha. See 
              ((<Surface#alpha>)) for a description of alpha.

--- Surface#w
--- Surface#width
    Return the width of the Surface, in pixels.

--- Surface#h
--- Surface#height
    Return the height of the Surface, in pixels.

--- Surface#size
    Return an Array, (({[w,h]})), containing the width and height of the 
    Surface.

--- Surface#depth
    Return the color depth (bits per pixel) of the Surface. See 
    ((<Surface.new>)) for a description of color depth.

--- Surface#flags
    Return a bitwise OR'd ( | ) list of the Surface flags. See 
    ((<Surface.new>)) for a list/description of flags.

--- Surface#masks
    Return an Array, (({[r,g,b,a]})), containing the Surface's color masks. A 
    color mask is an integer that you can use to isolate one color value from a
    large integer color value using bitwise AND ( & ). Mainly useful for 
    debugging and curious people, if useful at all. 

--- Surface#alpha
    Return the alpha (opacity) of the Surface. An alpha of 0 means the Surface 
    is totally transparent, while 255 means the Surface is totally opaque.

--- Surface#set_alpha( alpha, flags )
    Set the Surface's alpha. See ((<Surface#alpha>)) for a description of alpha.
        * (({alpha})): the new alpha value. 0 is transparent, 255 is opaque.
        * (({flags})): If no flags are given, flag 
          ((<SRC_ALPHA|Constants>)) is assumed (this is usually what 
          you want anyway).

--- Surface#get_colorkey
    Get the Surface's current colorkey. If the Surface has no colorkey, 
    (({nil})) is returned; otherwise an Array, (({[r,g,b]})), of the red, 
    green, and blue values of the colorkey is returned. See 
    ((<Surface#set_colorkey>)) for a description of colorkeys.

--- Surface#set_colorkey( colorkey, flags )
    Sets the Surface's colorkey to the given color. Setting the colorkey of a 
    Surface has the effect of making a particular color appear totally 
    transparent during future blits. This is especially useful when you are 
    blitting surfaces loaded from images with a solid background (commonly-used
    background colors for this purpose are blue, (({[0,0,255]})), and purple, 
    (({[255,0,255]}))).
        * ((|colorkey|)): the color to use as the colorkey, (({[r,g,b]})). If
          (({nil})) is passed for the color, the colorkey is unset.
        * ((|flags|)): a bitwise OR'd list of ((<SRCCOLORKEY|Constants>)) and
          ((<RLEACCEL|Constants>)); you almost always want the former; the 
          latter causes the Surface to use RLE acceleration for faster 
          blitting. If 0, the colorkey will be unset.

--- Surface#blit( dest_surface, dest, src_rect )
    Performs a fast blit (copy of image data) of the surface onto the 
    destination surface
        * ((|dest_surface|)): the Surface to copy onto.
        * ((|dest|)): either an Array, (({[x,y]})), or a rectstyle. The x and
          y values (indices 0 and 1) are used as the coordinates for the top-
          left corner of the blit.
        * ((|src_rect|)): At optional rectstyle to specify the part of the 
          source surface to copy. If this is omitted, the entire source surface
          is copied.
    ((*NOTE*)): in future versions, this function may return a Rect 
    representing the affected area of ((|dest_surface|)). That is, a Rect, 
    (({[dest_x, dest_y, src_w, src_h]})).

--- Surface#fill( color, rectstyle )
    Fill the area given by the Rect, with the given color. 
        * ((|color|)): The color to fill with. (({[r,g,b]})) or 
          (({[r,g,b,a]})). 
        * ((|rectstyle|)): An optional rectstyle to specify what part of the 
          surface to fill. If it is omitted, the whole Surface is filled.

--- Surface#get_at( coordinate )
    Return the color of the pixel at the given coordinates. For reference, the 
    top-leftmost pixel is (({[0,0]})), the coordinates increase down and to the
    right. Raises (({IndexError})) if the requested coordinates are outside the
    surface.
        * ((|coordinate|)): The x and y coordinates (({[x,y]})) of the pixel 
          to get the color of. For convenience, the coordinate can also be 
          given as two separate arguments.
=end
