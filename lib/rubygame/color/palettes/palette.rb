
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
