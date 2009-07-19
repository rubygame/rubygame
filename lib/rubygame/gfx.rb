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


end
