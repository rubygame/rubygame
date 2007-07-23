require 'rubygame/gl/shared'
	
class Camera
	attr_reader :screen_region
	attr_reader :world_region

	def initialize(screen_region, world_region)
		@screen_region, @world_region = screen_region, world_region
	end

	def activate
		setup_viewport
		setup_rendering
		setup_projection
	end

	def background_color=(color)
		r,g,b,a = color.to_ary
		a = 0.0 unless a
		glClearColor(r,g,b,a)
	end

	def clear
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	end	
	
	def draw_objects( group )
		group.draw
	end

	def setup_projection
		l,r,b,t = @world_region.left, @world_region.right,
		@world_region.bottom, @world_region.top
		
		glMatrixMode( GL_PROJECTION )
		glLoadIdentity()
		glOrtho(l, r, b, t, 0, 100)
	end
	
	def setup_rendering
		glShadeModel(GL_SMOOTH)
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_DEPTH_TEST)
		glDepthFunc(GL_LESS)
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	end
	
	def setup_viewport
		x,y = @screen_region.left, @screen_region.bottom
		w,h = @screen_region.size
		glViewport( x, y, w, h )
	end
end
