#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2007  John Croisant
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



module Rubygame
	module Color

		# :enddoc:
		
		# The CSS module contains all the colors in the CSS/HTML palette
		# by symbol name, e.g. :alice_blue, :dark_olive_green, etc.
		# 
		# NOTE: The CSS palette is identical to the X11 palette except for
		# four colors: gray, green, maroon, and purple. 
		# 
		# Differences between CSS and X11 derived from
		# http://en.wikipedia.org/wiki/X11_color_names
		# as accessed on 2007-12-17
		# 
		CSS = Palette.new({
			:gray =>                     ColorRGB.new( [0.50196, 0.50196, 0.50196] ),
			:green =>                    ColorRGB.new( [0.00000, 0.50196, 0.00000] ),
			:maroon =>                   ColorRGB.new( [0.50196, 0.00000, 0.00000] ),
			:purple =>                   ColorRGB.new( [0.50196, 0.00000, 0.50196] )
		})
		
		CSS.include X11
		
	end
end
