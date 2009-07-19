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



class Rubygame::SurfaceFFI


  def _draw_line(pt1, pt2, color, smooth) # :nodoc:
    x1, y1 = pt1.to_a.collect{|n| n.round}
    x2, y2 = pt2.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame.make_sdl_rgba( color )

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
    _draw_line( point1, point2, color, false )
    return self
  end


  # Like #draw_line, but the line will be anti-aliased.
  #
  def draw_line_a( point1, point2, color )
    _draw_line( point1, point2, color, true )
    return self
  end



  def _draw_box(pt1, pt2, color, solid) # :nodoc:
    x1, y1 = pt1.to_a.collect{|n| n.round}
    x2, y2 = pt2.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame.make_sdl_rgba( color )

    if solid
      SDL::Gfx.boxRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
    else
      SDL::Gfx.rectangleRGBA(@struct, x1, y1, x2, y2, r,g,b,a)
    end
  end

  private :_draw_box


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
    _draw_box( point1, point2, color, false )
    return self
  end


  # Like #draw_box, but the shape is solid, instead of an outline.
  # (You may find using #fill to be more convenient and perhaps faster
  # than this method.)
  #
  def draw_box_s( point1, point2, color )
    _draw_box( point1, point2, color, true )
    return self
  end



  def _draw_circle(center, radius, color, smooth, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radius = radius.to_i

    r,g,b,a = Rubygame.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledCircleRGBA(@struct, x, y, radius, r,g,b,a)
    elsif smooth
      SDL::Gfx.aacircleRGBA(@struct, x, y, radius, r,g,b,a)
    else
      SDL::Gfx.circleRGBA(@struct, x, y, radius, r,g,b,a)
    end
  end

  private :_draw_circle


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
    _draw_circle( center, radius, color, false, false )
    return self
  end


  # Like #draw_circle, but the outline is anti-aliased.
  #
  def draw_circle_a( center, radius, color )
    _draw_circle( center, radius, color, true, false )
    return self
  end


  # Like #draw_circle, but the shape is solid, instead of an outline.
  #
  def draw_circle_s( center, radius, color )
    _draw_circle( center, radius, color, false, true )
    return self
  end



  def _draw_ellipse(center, radii, color, smooth, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radx, rady = radii.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledEllipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    elsif smooth
      SDL::Gfx.aaellipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    else
      SDL::Gfx.ellipseRGBA(@struct, x, y, radx, rady, r,g,b,a)
    end
  end

  private :_draw_ellipse


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
    _draw_ellipse( center, radii, color, false, false )
    return self
  end


  # Like #draw_ellipse, but the ellipse border is anti-aliased.
  #
  def draw_ellipse_a( center, radii, color )
    _draw_ellipse( center, radii, color, true, false )
    return self
  end


  # Like #draw_ellipse, but the shape is solid, instead of an outline.
  #
  def draw_ellipse_s( center, radii, color )
    _draw_ellipse( center, radii, color, false, true )
    return self
  end



  def _draw_arc(center, radius, angles, color, solid) # :nodoc:
    x, y = center.to_a.collect{|n| n.round}
    radius = radius.round
    ang1, ang2 = angles.to_a.collect{|n| n.round}

    r,g,b,a = Rubygame.make_sdl_rgba( color )

    if solid
      SDL::Gfx.filledPieRGBA(@struct, x, y, radius, ang1, ang2, r,g,b,a)
    else
      SDL::Gfx.pieRGBA(@struct, x, y, radius, ang1, ang2, r,g,b,a)
    end
  end

  private :_draw_arc


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
    _draw_arc( center, radius, angles, color, false )
    return self
  end


  # Like #draw_arc, but the shape is solid, instead of an outline.
  #
  def draw_arc_s( center, radius, angles, color )
    _draw_arc( center, radius, angles, color, true )
    return self
  end



end
