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



%w{  base rgb hsv hsl  }.each do |f|
  require( File.join( File.dirname(__FILE__), "color", "models", f ) )
end

%w{  palette x11 css  }.each do |f|
  require( File.join( File.dirname(__FILE__), "color", "palettes", f ) )
end



module Rubygame

	# The Color module contains classes related to colors.
	# 
	# Available color representations:
	# 
	# ColorRGB::  color class with red, green, and blue components.
	# ColorHSV::  color class with hue, saturation, and value components.
	# ColorHSL::  color class with hue, saturation, and luminosity components.
	# 
	# The Palette class allows you to conveniently store and access a
	# collection of many different colors, with inheritance from
	# included Palettes.
	# 
	# The available predefined palettes are:
	# 
	# X11::    palette with the default X11 colors
	# CSS::    palette used with HTML and CSS, very similar to X11
	# GLOBAL:: special palette used for automatic lookup (see below)
	# 
	# The GLOBAL palette is special; it is used for automatic color lookup
	# in functions like Surface#draw_circle and TTF#render.It includes the
	# CSS palette by default; you can include other palettes or define new
	# custom colors in GLOBAL to make them available for automatic lookup.
	# 
	# For convenience, you can access the GLOBAL palette through the
	# #[] and #[]= methods:
	# 
	#     include Rubygame
	#     player_color = Color[:red]
	#     Color[:favorite] = Color[:azure]
	# 
	module Color

		(GLOBAL = Palette.new()).include(CSS) # :nodoc:
		
		# Retrieve a color from the GLOBAL palette.
		# See Palette#[]
		def self.[]( name )
			GLOBAL[name]
		end
		
		# Store a color in the GLOBAL palette.
		# See Palette#[]=
		def self.[]=( name, color )
			GLOBAL[name] = color
		end
		

    # For use by Rubygame methods only:

    # Convert a color name (string or symbol), Color instance, or Array
    # to a color array.
    def self.convert_color( color ) # :nodoc:
      color = 
        if color.kind_of?(Symbol) or color.kind_of?(String)
          Rubygame::Color[color].to_sdl_rgba_ary
        elsif color.respond_to? :to_sdl_rgba_ary
          color.to_sdl_rgba_ary
        elsif color.respond_to? :to_ary
          color.to_ary
        else
          raise TypeError, "unsupported type #{color.class} for color"
        end

      unless color.size.between?(3,4) and color.all?{|n| n.kind_of? Numeric}
        raise TypeError, "invalid color: #{color.inspect}"
      end

      return color
    end

    def self.make_sdl_rgba( color ) # :nodoc:
      @rgba_cache ||= {}
      @rgba_cache[color] ||=
        begin
          r,g,b,a = convert_color(color).collect!{ |c| c.to_i }[0,4]
          a ||= 255
          [r,g,b,a].freeze
        end
    end

	end
end

