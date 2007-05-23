require 'rubygame/gl/shared'

class GLSprite
	attr_accessor :pos, :depth, :scale, :angle
	attr_accessor :parents

	def initialize(&block)
		@t = 0
		@pos = Ftor.new(0,0)
		@depth = 0
		@scale = 1
		@angle = 0
		instance_eval(&block) if block_given?
	end

	def with_transformation(&block)
		glMatrixMode( GL_MODELVIEW )
		glLoadIdentity()
		pushpop_matrix do
			glTranslate(@pos.x, @pos.y, @depth)
			glRotate(@angle, 0, 0, 1)
			case @scale
			when Ftor
				glScale(@scale.x, @scale.y, 1)
			when Numeric
				glScale(@scale,   @scale,   1)
			end
			block.call()
		end
	end

	def draw()
	end

	def update( time )
	end
end

class GLGroup < GLSprite
	attr_accessor :children

	def initialize(&block)
		@children = []
		super
	end

	def draw()
		@children.each { |child| child.draw }
	end

	def update( time )
		@children.each { |child| child.update(time) }
	end

	def add_children(*children)
		@children |= children
		sort_children()
	end

	def sort_children()
		@children.sort!{ |a,b| a.depth <=> b.depth }
	end

end

class GLImageSprite < GLSprite
	attr_accessor :surface, :size, :tex_id, :has_alpha
	def initialize
		@size = Ftor.new(1,1)
		@has_alpha = false
		super
	end

	def setup_texture()
		@size = Ftor.new(*@surface.size)
		@tex_id = glGenTextures(1)[0]
		glBindTexture(GL_TEXTURE_2D, @tex_id)
		if @has_alpha
			channels, format = 4, GL_RGBA
		else
			channels, format = 3, GL_RGB
		end
		
		glTexImage2D(GL_TEXTURE_2D, 0, channels, @surface.w, @surface.h,
									 0, format, GL_UNSIGNED_BYTE, @surface.pixels)
		glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	end

	def draw()
		with_transformation do
			w, h = @size.x.div(2.0), @size.y.div(2.0)
			glBindTexture(GL_TEXTURE_2D, @tex_id)
			glbegin(GL_TRIANGLE_FAN) do
				glTexCoord([0.5,0.5])
				glVertex([0,0])
				glTexCoord([0,1]);
				glVertex([-w, -h]);
				glTexCoord([1,1]);
				glVertex([w,-h]);
				glTexCoord([1,0]);
				glVertex([w, h]);
				glTexCoord([0,0]);
				glVertex([-w, h]);
				glTexCoord([0,1]);
				glVertex([-w, -h]);
			end
		end
	end
end
