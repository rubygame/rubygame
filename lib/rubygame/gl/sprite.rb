require 'rubygame/gl/shared'
require 'rubygame/gl/polygon'

class GLSprite
	attr_accessor :depth
	attr_accessor :parents

	def initialize(&block)
		@t = 0
		@transform = Transform2.new()
		@depth = 0
		instance_eval(&block) if block_given?
	end

	def angle; @transform.angle; end
	def angle=( new_angle ); @transform.angle = new_angle; end
	
	def pos; @transform.shift; end
	def pos=( new_pos ); @transform.shift = new_pos; end
	
	def scale; @transform.scale; end
	def scale=( new_scale ); @transform.scale = new_scale; end
	
	def draw()
	end

	def update( time )
	end
end

class GLImageSprite < GLSprite
	attr_accessor :surface, :size, :tex_id, :has_alpha
	attr_accessor :shape
	def initialize
		@size = Vector2[1,1]
		@has_alpha = false
		super
 		@shape = Polygon::UNIT_SQUARE.transform(:scale => @size)
		@base_shape = @shape
	end

	def setup_texture()
		@size = @surface.size
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
	
	def collides_with?( other )
		self.shape.collide( other.shape )
	end

	def draw( matrix=Matrix3.identity )
		shape = @shape.transform( matrix )

		glBindTexture(GL_TEXTURE_2D, @tex_id)
		glbegin(GL_TRIANGLE_FAN) do

			verts = [[shape.center, [0.5,0.5]],
			         [shape[0],     [0,1]],
			         [shape[1],     [1,1]],
			         [shape[2],     [1,0]],
			         [shape[3],     [0,0]],
 			         [shape[0],     [0,1]]]

			verts.each do |pair|
				vert = pair[0].to_ary + [@depth]
				tex = pair[1]
				glTexCoord( tex )
				glVertex( vert )
			end

		end
	end

	def update(*args)
		super
		@shape = @base_shape.transform( @transform )
	end
end
