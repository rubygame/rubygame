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
		GL::MatrixMode( GL::MODELVIEW )
		GL::LoadIdentity()
		pushpop_matrix do
			GL::Translate(@pos.x, @pos.y, @depth)
			GL::Rotate(@angle, 0, 0, 1)
			case @scale
			when Ftor
				GL::Scale(@scale.x, @scale.y, 1)
			when Numeric
				GL::Scale(@scale,   @scale,   1)
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
		@tex_id = GL::GenTextures(1)[0]
		GL::BindTexture(GL::TEXTURE_2D, @tex_id)
		if @has_alpha
			channels, format = 4, GL::RGBA
		else
			channels, format = 3, GL::RGB
		end
		
		GL::TexImage2D(GL::TEXTURE_2D, 0, channels, @surface.w, @surface.h,
									 0, format, GL::UNSIGNED_BYTE, @surface.pixels)
		GL::TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MIN_FILTER,GL::NEAREST);
		GL::TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MAG_FILTER,GL::LINEAR);
	end

	def draw()
		with_transformation do
			w, h = @size.x.div(2.0), @size.y.div(2.0)
			GL::BindTexture(GL::TEXTURE_2D, @tex_id)
			glbegin(GL::TRIANGLE_FAN) do
				GL::TexCoord([0.5,0.5])
				GL::Vertex([0,0])
				GL::TexCoord([0,1]);
				GL::Vertex([-w, -h]);
				GL::TexCoord([1,1]);
				GL::Vertex([w,-h]);
				GL::TexCoord([1,0]);
				GL::Vertex([w, h]);
				GL::TexCoord([0,0]);
				GL::Vertex([-w, h]);
				GL::TexCoord([0,1]);
				GL::Vertex([-w, -h]);
			end
		end
	end
end
