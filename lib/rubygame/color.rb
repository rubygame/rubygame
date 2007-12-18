require 'rubygame/color_models/base'
require 'rubygame/color_models/rgb'
require 'rubygame/color_models/hsv'
require 'rubygame/color_models/hsl'

require 'rubygame/color_tables/x11'
require 'rubygame/color_tables/css'

module Rubygame
	module Color
		
		# Look up a color from the color table.
		# 
		# The name is made uppercase and spaces become uppercase,
		# to convert it to a module constant.
		# 
		# Example:
		# 
		#     # All do the same thing
		#     Color::ALICE_BLUE
		#     Color[ :alice_blue  ]
		#     Color[ "alice blue" ]
		# 
		def self.[]( name )
			self.const_get( name.to_s.gsub(' ','_').upcase.intern )
		rescue NameError
			raise NameError, "unknown color name `#{name}'"
		end

		# Set a color in the color table.
		# 
		# The name is made uppercase and spaces become uppercase,
		# to convert it to a module constant.
		# 
		# Example:
		# 
		#     # All do the same thing
		#     Color::GRUE      = ColorRGB.new( [ 0.0, 1.0, 0.0 ] )
		#     Color[ :grue  ]  = ColorRGB.new( [ 0.0, 1.0, 0.0 ] )
		#     Color[ "grue" ]  = ColorRGB.new( [ 0.0, 1.0, 0.0 ] )
		# 
		def self.[]=( name, color )
			self.const_set( name.to_s.gsub(' ','_').upcase.intern, color )
		end
		
		# call-seq:
		#   import( hash )
		#   import( module )
		# 
		# Include the colors defined in the Hash or Module in the
		# Color namespace.
		# 
		def self.import( hashmod )
			case hashmod
			when Hash
				hashmod.each_pair do | name, color |
					self[name] = color
				end
			when Module
				include hashmod
			else
				raise ArgumentError,
				      "wrong type (got #{hashmod.class}, wanted Hash or Module)"
			end
		end
			
	end
end

