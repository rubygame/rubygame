require 'rubygame/gl/shared'
require 'rubygame/gl/polygon'

class GLSprite
	attr_accessor :pos, :depth, :scale, :angle
	attr_accessor :parents

	def initialize(&block)
		@t = 0
		@pos = Vector2[0,0]
		@depth = 0
		@scale = Vector2[1,1]
		@angle = 0
		instance_eval(&block) if block_given?
	end

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
 		@shape = Polygon::UNIT_SQUARE.scale(*@size[0..1])
		@base_shape = @shape
	end

	def setup_texture()
		@size = Vector2[*@surface.size]
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
		@shape = @base_shape.scale(*(@scale.to_ary[0,2])).rotate!(@angle).translate!(*(@pos.to_ary[0,2]))
	end
end
