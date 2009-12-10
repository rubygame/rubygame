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

class Rubygame::Color::Palette

	# Create a new Palette with the given name => color pairs.
	def initialize( colors = {} )
		@includes = []
		
		@colors = {}
		colors.each_pair do |name, color|
			@colors[sanitize_name(name)] = color
		end
	end

	# Retrieve a color by name from this palette.
	# 
	# The name can be a Symbol or String. See #sanitize_name.
	# 
	# If the color cannot be found in this palette, search
	# each of the #included palettes (recursively, depth-first,
	# to a maximum depth of 5 levels).
	# 
	# If the color is not found in this palette or any included
	# palettes, raise IndexError.
	# 
	def []( name )
		c = lookup( sanitize_name( name ) )
		raise IndexError, "unknown color #{name}" unless c
		return c
	end
	
	# Store a color by name in this palette. See #sanitize_name
	def []=( name, color )
    # Uncache colors with this name, to avoid using obsolete value.
    Rubygame::Color.remove_from_cache( name )

		name = sanitize_name( name )
		@colors[name] = color
	end
	
	# Include another palette in this one. If a color cannot be
	# found in this palette, the included palette(s) will be searched.
	# See also #uninclude.
	# 
	# Has no effect if the palette is already included.
	def include( palette )
		@includes += [palette] unless @includes.include? palette
	end
	
	# Remove the other palette from this one, so that it won't be
	# searched for missing colors anymore. Has no effect if the
	# other palette hasn't been #included.
	def uninclude( palette )
		@includes -= [palette]
	end
	
	protected

	# Recursive color lookup
	def lookup( name, max_depth=5 ) # :nodoc:
		return nil if max_depth < 0

		color = @colors[name]

		unless color
			@includes.each { |palette|
				c = palette.lookup(name, max_depth-1)
				color = c if c
			}
		end

		return color
	end
	
	private

	# Takes either a Symbol or a String, and converts it to a
	# lowercase Symbol with spaces converted to underscores.
	# 
	# E.g. "Alice Blue" and :ALICE_BLUE both become :alice_blue.
	# 
	def sanitize_name( name )
		name.to_s.gsub(' ','_').downcase.intern
	end

end
