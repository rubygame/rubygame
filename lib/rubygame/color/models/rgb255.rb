#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2010  John Croisant
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

    # Represents color in the RGB (Red, Green, Blue) color space,
    # with each color component as an integer from 0 to 255.
    # 
    # See also ColorRGB, where components are floats from 0.0 to 1.0.
    # 
    class ColorRGB255
      include ColorBase

      attr_reader :r, :g, :b, :a

      # call-seq:
      #   new( [r,g,b,a] )  ->  ColorRGB
      #   new( [r,g,b] )  ->  ColorRGB
      #   new( color )  ->  ColorRGB
      # 
      # Create a new instance from an Array or an existing color
      # (of any type). If the alpha (opacity) component is omitted
      # from the array, full opacity will be used.
      # 
      # All color components range from 0 to 255.
      # 
      def initialize( color )
        if color.kind_of?(Array) and color.size >= 3
          @r, @g, @b, @a = color.collect { |i| i.round }
          @a = 255 unless @a
        elsif color.instance_of?(self.class)
          @r, @g, @b, @a = color.to_ary
        elsif color.respond_to?(:to_rgba_ary)
          @r, @g, @b, @a = color.to_sdl_rgba_ary
        else
          raise ArgumentError, "Invalid color: #{color.inspect}"
        end
      end

      # Creates a new instance from an RGBA array of floats ranging
      # from 0.0 to 1.0.
      def self.new_from_rgba( rgba )
        new( rgba.collect { |i| (i * 255).round } )
      end

      # Creates a new instance from an RGBA array of integers
      # ranging from 0 to 255.
      def self.new_from_sdl_rgba( rgba )
        new( rgba )
      end

      # Creates a new instance from a string containing an HTML/CSS
      # color string, i.e. "#RGB", "#RGBA", "#RRGGBB", or "#RRGGBBAA".
      # The leading "#" is optional.
      # 
      # Example:
      # 
      #   include Rubygame::Color
      # 
      #   # 4 ways of specifying the same color:
      #   
      #   # "#RGB"
      #   ColorRGB255.hex("#248")
      #   # => #<ColorRGB255 [34, 68, 136, 255]>
      #   
      #   # "#RGBA"
      #   ColorRGB255.hex("#248f")
      #   # => #<ColorRGB255 [34, 68, 136, 255]>
      #   
      #   # "#RRGGBB"
      #   ColorRGB255.hex("#224488")
      #   # => #<ColorRGB255 [34, 68, 136, 255]>
      #   
      #   # "#RRGGBBAA"
      #   ColorRGB255.hex("#224488ff")
      #   # => #<ColorRGB255 [34, 68, 136, 255]>
      #   
      def self.hex( color_str )
        case color_str
        when /^#?([0-9a-f]{8}$)/i
          r = $1[0,2].hex
          g = $1[2,2].hex
          b = $1[4,2].hex
          a = $1[6,2].hex
          new( [r, g, b, a] )
        when /^#?([0-9a-f]{6}$)/i
          r = $1[0,2].hex
          g = $1[2,2].hex
          b = $1[4,2].hex
          a = 255
          new( [r, g, b, a] )
        when /^#?([0-9a-f]{4})$/i
          # As with HTML/CSS, each hexdigit is repeated.
          # So, "#1234" means "#11223344" (i.e. [17, 34, 51, 68]).
          r = ($1[0,1]*2).hex
          g = ($1[1,1]*2).hex
          b = ($1[2,1]*2).hex
          a = ($1[3,1]*2).hex
          new( [r, g, b, a] )
        when /^#?([0-9a-f]{3})$/i
          # As with HTML/CSS, each hexdigit is repeated.
          # So, "#123" means "#112233" (i.e. [17, 34, 51]).
          r = ($1[0,1]*2).hex
          g = ($1[1,1]*2).hex
          b = ($1[2,1]*2).hex
          a = 255
          new( [r, g, b, a] )
        else
          raise "Invalid hex color string #{color_str.inspect}."
        end
      end

      # Returns the color as an RGBA array of integers ranging from 0
      # to 255, as SDL wants.
      def to_sdl_rgba_ary
        [@r, @g, @b, @a]
      end

			# Returns the color as an RGBA array of floats ranging from 0.0
			# to 1.0.
      def to_rgba_ary
        [@r/255.0, @g/255.0, @b/255.0, @a/255.0]
      end

			# Same as #to_sdl_rgba_ary
      def to_ary
        [@r, @g, @b, @a]
      end

    end
  end
end
