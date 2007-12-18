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

	def initialize( colors = {} )
		@colors = colors
		@parents = []
	end
	
	def include( table )
		@parents += [table]
		@parents.uniq!
	end
	
	def uninclude( table )
		@parents -= [table]
	end

	# Retrieve a color by name, searching self and parents.
	# 
	# If the color is not found, raises IndexError.
	# 
	def []( name )
		name = name.to_s.gsub(' ','_').downcase.intern
		c = lookup(name)
		raise IndexError, "unknown color #{name}" unless c
		return c
	end
	
	def []=( name, color )
		@colors[name] = color
	end
	
	protected

	# Recursive color lookup
	def lookup( name, max_depth=5 )
		return nil if max_depth < 0

		c = @colors[name]

		unless c
			@parents.each { |p|
				if p.lookup(name, max_depth-1)
					c = p.lookup(name, max_depth-1)
				end
			}
		end

		return c
	end

end
