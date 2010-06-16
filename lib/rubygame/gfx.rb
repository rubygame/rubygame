#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2009  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++



require "ruby-sdl-ffi/gfx"

# SDL_gfx has no function to get the version number.
Rubygame::VERSIONS[:sdl_gfx] = [0, 0, 0]


class Rubygame::Surface


  def _draw_line(pt1, pt2, color, smooth) # :nodoc:
    x1, y1 = pt1.to_a.collect{|n| n.round}
    x2, y2 = pt2.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if( y1 == y2 )
      SDL::Gfx.hlineRGBA(@struct, x1, x2, y1, r,g,b,a)
    elsif( x1 == x2 )
      SDL::Gfx.vlineRGBA(@struct, x1, y1, y2, r,g,b,a)
    else
      if smooth
        SDL::Gfx.aalineRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
      else
        SDL::Gfx.lineRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
      end
    end
  end

  private :_draw_line


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_line)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Draw a line segment between two points on the Surface.
  # See also #draw_line_a
  #
  # This method takes these arguments:
  # point1::  the coordinates of one end of the line, [x1,y1].
  # point2::  the coordinates of the other end of the line, [x2,y2].
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_line( point1, point2, color )
    raise "can't modify frozen object" if frozen?
    _draw_line( point1, point2, color, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_line_a)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Like #draw_line, but the line will be anti-aliased.
  #
  def draw_line_a( point1, point2, color )
    raise "can't modify frozen object" if frozen?
    _draw_line( point1, point2, color, true )
    return self
  end



  def _draw_box(pt1, pt2, color, solid) # :nodoc:
    x1, y1 = pt1.to_a.collect{|n| n.round}
    x2, y2 = pt2.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if solid
      SDL::Gfx.boxRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
    else
      SDL::Gfx.rectangleRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
    end
  end

  private :_draw_box


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_box)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Draw a non-solid box (rectangle) on the Surface, given the
  # coordinates of its top-left corner and bottom-right corner. See
  # also #draw_box_s
  #
  # This method takes these arguments:
  # point1::  the coordinates of top-left corner, [x1,y1].
  # point2::  the coordinates of bottom-right corner, [x2,y2].
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_box( point1, point2, color )
    raise "can't modify frozen object" if frozen?
    _draw_box( point1, point2, color, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_box_s)" to see
  # if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_box, but the shape is solid, instead of an outline.
  # (You may find using #fill to be more convenient and perhaps faster
  # than this method.)
  #
  def draw_box_s( point1, point2, color )
    raise "can't modify frozen object" if frozen?
    _draw_box( point1, point2, color, true )
    return self
  end



  def _draw_circle(center, radius, color, smooth, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radius = radius.to_i

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledCircleRGBA(@struct, x, y, radius, r,g,b,a)
    elsif smooth
      SDL::Gfx.aacircleRGBA(@struct, x, y, radius, r,g,b,a)
    else
      SDL::Gfx.circleRGBA(@struct, x, y, radius, r,g,b,a)
    end
  end

  private :_draw_circle


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_circle)" to see
  # if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Draw a non-solid circle on the Surface, given the coordinates of its
  # center and its radius. See also #draw_circle_a and #draw_circle_s
  #
  # This method takes these arguments:
  # center::  the coordinates of circle's center, [x,y].
  # radius::  the radius (pixels) of the circle.
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_circle( center, radius, color )
    raise "can't modify frozen object" if frozen?
    _draw_circle( center, radius, color, false, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_circle_a)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Like #draw_circle, but the outline is anti-aliased.
  #
  def draw_circle_a( center, radius, color )
    raise "can't modify frozen object" if frozen?
    _draw_circle( center, radius, color, true, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_circle_s)" to
  # see if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_circle, but the shape is solid, instead of an outline.
  #
  def draw_circle_s( center, radius, color )
    raise "can't modify frozen object" if frozen?
    _draw_circle( center, radius, color, false, true )
    return self
  end



  def _draw_ellipse(center, radii, color, smooth, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radx, rady = radii.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledEllipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    elsif smooth
      SDL::Gfx.aaellipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    else
      SDL::Gfx.ellipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    end
  end

  private :_draw_ellipse


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_ellipse)" to see
  # if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Draw a non-solid ellipse (oval) on the Surface, given the 
  # coordinates of its center and its horizontal and vertical radii.
  # See also #draw_ellipse_a and #draw_ellipse_s
  #
  # This method takes these arguments:
  # center::  the coordinates of ellipse's center, [x,y].
  # radii::   the x and y radii (pixels), [rx,ry].
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_ellipse( center, radii, color )
    raise "can't modify frozen object" if frozen?
    _draw_ellipse( center, radii, color, false, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_ellipse_a)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Like #draw_ellipse, but the ellipse border is anti-aliased.
  #
  def draw_ellipse_a( center, radii, color )
    raise "can't modify frozen object" if frozen?
    _draw_ellipse( center, radii, color, true, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_ellipse_s)" to
  # see if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_ellipse, but the shape is solid, instead of an outline.
  #
  def draw_ellipse_s( center, radii, color )
    raise "can't modify frozen object" if frozen?
    _draw_ellipse( center, radii, color, false, true )
    return self
  end



  def _draw_arc(center, radius, angles, color, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radius = radius.round
    ang1, ang2 = angles.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledPieRGBA(@struct, x, y, radius, ang1, ang2, r,g,b,a)
    else
      SDL::Gfx.pieRGBA(@struct, x, y, radius, ang1, ang2, r,g,b,a)
    end
  end

  private :_draw_arc


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_arc)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Draw a non-solid arc (part of a circle), given the coordinates of
  # its center, radius, and starting/ending angles.
  # See also #draw_arc_s
  #
  # This method takes these arguments:
  # center::  the coordinates of circle's center, [x,y].
  # radius::  the radius (pixels) of the circle.
  # angles::  the start and end angles (in degrees) of the arc, [start,end].
  #           Angles are given *CLOCKWISE* from the positive x
  #           (remember that the positive Y direction is down, rather than up).
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_arc( center, radius, angles, color )
    raise "can't modify frozen object" if frozen?
    _draw_arc( center, radius, angles, color, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_arc_s)" to see
  # if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_arc, but the shape is solid, instead of an outline.
  #
  def draw_arc_s( center, radius, angles, color )
    raise "can't modify frozen object" if frozen?
    _draw_arc( center, radius, angles, color, true )
    return self
  end



  def _draw_polygon(points, color, smooth, solid) # :nodoc:

    len = points.length
    xpts = FFI::Buffer.new(:int16, len)
    ypts = FFI::Buffer.new(:int16, len)

    points.each_with_index { |point, i|
      xpts[i].put_int16( 0, point[0].round )
      ypts[i].put_int16( 0, point[1].round )
    }

    r,g,b,a = Rubygame::Color.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledPolygonRGBA(@struct, xpts, ypts, len, r,g,b,a)
    elsif smooth
      SDL::Gfx.aapolygonRGBA(@struct, xpts, ypts, len, r,g,b,a)
    else
      SDL::Gfx.polygonRGBA(@struct, xpts, ypts, len, r,g,b,a)
    end
  end

  private :_draw_polygon


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_polygon)" to see
  # if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Draw a non-solid polygon, given the coordinates of its vertices, in the
  # order that they are connected. This is essentially a series of connected
  # dots. See also #draw_polygon_a and #draw_polygon_s.
  #
  # This method takes these arguments:
  # points::  an Array containing the coordinate pairs for each vertex of the
  #           polygon, in the order that they are connected, e.g.
  #           [ [x1,y1], [x2,y2], ..., [xn,yn] ].
  # color::   the color of the shape. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  #
  def draw_polygon( points, color )
    raise "can't modify frozen object" if frozen?
    _draw_polygon( points, color, false, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_polygon_a)" to
  # see if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_polygon, but the lines are anti-aliased.
  #
  def draw_polygon_a( points, color )
    raise "can't modify frozen object" if frozen?
    _draw_polygon( points, color, true, false )
    return self
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:draw_polygon_s)" to
  # see if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Like #draw_polygon, but the shape is solid, instead of an outline.
  #
  def draw_polygon_s( points, color )
    raise "can't modify frozen object" if frozen?
    _draw_polygon( points, color, false, true )
    return self
  end


  if defined? SDL::Gfx.bezierRGBA

  # *IMPORTANT*: this method only exists if SDL_gfx is available! Your
  # code should check "surface.respond_to?(:draw_curve)" to see if you
  # can use this method, or be prepared to rescue from NameError.
  #
  # Draws a Bézier curve with the given control points, color and
  # quality.
  #
  # This method takes these arguments:
  # points::  an Array containing the coordinates for each control
  #           point of the curve, in the order that they are connected.
  #           [ [x0, y0], [x1, y1], ... [xn, yn] ]
  # color::   the color of the curve. [r,g,b] or [r,g,b,a] (0-255),
  #           color name, or Rubygame::Color.
  # quality:: rendering quality (smoothness) of the curve. Smaller
  #           values are faster to draw, but look more "polygonal".
  #           (Default: 5; Minimum: 2)
  #
  def draw_curve( points, color, quality = 5 )
    raise "can't modify frozen object" if frozen?
    if quality < 2
      raise ArgumentError, "quality must be 2 or greater (got #{quality})"
    end

    len = points.length
    xpts = FFI::Buffer.new(:int16, len)
    ypts = FFI::Buffer.new(:int16, len)
    
    points.each_with_index do |p, i|
      xpts[i].put_int16( 0, p[0].round )
      ypts[i].put_int16( 0, p[1].round )
    end
    
    r,g,b,a = Rubygame::Color.make_sdl_rgba(color)
    SDL::Gfx.bezierRGBA(@struct, xpts, ypts, len,
                        quality.to_i, r, g, b, a)

    return self
  end

  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:rotozoom)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Return a rotated and/or zoomed version of the given surface. Note
  # that rotating a Surface anything other than a multiple of 90
  # degrees will cause the new surface to be larger than the original
  # to accomodate the corners (which would otherwise extend beyond the
  # surface).
  #
  # May raise Rubygame::SDLError if the rotozoom fails.
  # 
  # angle::   degrees to rotate counter-clockwise (negative for
  #           clockwise).
  # zoom::    scaling factor(s). A number (to scale X and Y by the same
  #           factor) or an array of 2 numbers (to scale X and Y by 
  #           different factors). Negative numbers flip the image.
  #           NOTE: Due to a quirk in SDL_gfx, if angle is not 0, the
  #           image is zoomed by the X factor on both X and Y, and the
  #           Y factor is only used for flipping (if it's negative).
  # smooth::  whether to anti-alias the new surface.
  #           By the way, if true, the new surface will be 32bit RGBA.
  # 
  def rotozoom( angle, zoom, smooth=false )
    smooth = smooth ? 1 : 0

    surf = case zoom
           when Array
             zx, zy = zoom.collect { |n| n.to_f }
             SDL::Gfx.rotozoomSurfaceXY(@struct, angle, zx, zy, smooth)
           when Numeric
             zoom = zoom.to_f
             SDL::Gfx.rotozoomSurface(@struct, angle, zoom, smooth)
           else
             raise ArgumentError, "Invalid zoom factor: #{zoom.inspect}"
           end

    if( surf.pointer.null? )
      raise( Rubygame::SDLError,
             "Rotozoom failed: " + SDL.GetError() )
    end

    return self.class.new(surf)
  end


  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:rotozoom_size)" to
  # see if you can use this method, or be prepared to rescue from
  # NameError.
  #
  # Return the dimensions of the surface that would be returned if
  # #rotozoom were called on a Surface of the given size, with
  # the same angle and zoom factors.
  #
  # This method takes these arguments:
  # size::  an Array with the hypothetical Surface width and height (pixels)
  # angle:: degrees to rotate counter-clockwise (negative for clockwise).
  # zoom::  scaling factor(s). A number (to scale X and Y by the same
  #         factor) or an array of 2 numbers (to scale X and Y by 
  #         different factors). NOTE: Due to a quirk in SDL_gfx, if
  #         angle is not 0, the image is zoomed by the X factor on
  #         both X and Y, and the Y factor is only used for flipping
  #         (if it's negative).
  #
  def self.rotozoom_size( size, angle, zoom )
    w, h = size

    case zoom
    when Array
      zx, zy = zoom.collect { |n| n.to_f }
      SDL::Gfx.rotozoomSurfaceSizeXY(w, h, angle, zx, zy)
    when Numeric
      zoom = zoom.to_f
      SDL::Gfx.rotozoomSurfaceSize(w, h, angle, zoom)
    else
      raise ArgumentError, "Invalid zoom factor: #{zoom.inspect}"
    end
  end



  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:zoom)" to see if you
  # can use this method, or be prepared to rescue from NameError.
  #
  # Return a zoomed version of the Surface.
  #
  # This method takes these arguments:
  # zoom::    a Numeric factor to scale by in both x and y directions,
  #           or an Array with separate x and y scale factors.
  # smooth::  whether to anti-alias the new surface.
  #           By the way, if true, the new surface will be 32bit RGBA.
  #
  def zoom( zoom, smooth=false )
    smooth = smooth ? 1 : 0

    surf = case zoom
           when Array
             zx, zy = zoom.collect { |n| n.to_f }
             SDL::Gfx.zoomSurface(@struct, zx, zy, smooth)
           when Numeric
             zoom = zoom.to_f
             SDL::Gfx.zoomSurface(@struct, zoom, zoom, smooth)
           else
             raise ArgumentError, "Invalid zoom factor: #{zoom.inspect}"
           end

    if( surf.pointer.null? )
      raise( Rubygame::SDLError, "Zoom failed: " + SDL.GetError() )
    end

    return self.class.new(surf)
  end



  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:zoom_size)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Return the dimensions of the surface that would be returned if
  # #zoom were called on a Surface of the given size, with the same
  # zoom factors.
  #
  # This method takes these arguments:
  # size::  an Array with the hypothetical Surface width and height (pixels)
  # zoom::  scaling factor(s). A number (to scale X and Y by the same
  #         factor) or an array of 2 numbers (to scale X and Y by 
  #         different factors).
  #
  def self.zoom_size( size, zoom )
    w, h = size

    case zoom
    when Array
      zx, zy = zoom.collect { |n| n.to_f }
      SDL::Gfx.zoomSurfaceSize(w, h, zx, zy)
    when Numeric
      zoom = zoom.to_f
      SDL::Gfx.zoomSurfaceSize(w, h, zoom, zoom)
    else
      raise ArgumentError, "Invalid zoom factor: #{zoom.inspect}"
    end
  end



  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:zoom_to)" to see if
  # you can use this method, or be prepared to rescue from NameError.
  #
  # Return a version of the Surface zoomed to a new size.
  #
  # This method takes these arguments:
  # width::   the desired width. If nil, the width will stay the same.
  # height::  the desired height. If nil, the height will stay the same.
  # smooth::  whether to anti-alias the new surface. This option can be
  #           omitted, in which case the surface will not be anti-aliased.
  #           If true, the new surface will be 32bit RGBA.
  #
  def zoom_to( width, height, smooth=false )
    zoomx = case width
            when nil;      1.0
            when Numeric;  width.to_f / @struct.w
            end
             
    zoomy = case height
            when nil;      1.0
            when Numeric;  height.to_f / @struct.h
            end

    return self.zoom( [zoomx, zoomy], smooth )
  end



  # *IMPORTANT*: this method only exists if SDL_gfx is available!
  # Your code should check "surface.respond_to?(:flip)" to see if you
  # can use this method, or be prepared to rescue from NameError.
  #
  # Returns a copy of the Surface flipped horizontally (if +horz+ is
  # true), vertically (if +vert+ is true), or both (if both are true).
  #
  def flip( horz, vert )
    self.zoom( [ (horz ? -1.0 : 1.0), (vert ? -1.0 : 1.0)], false )
  end


end
