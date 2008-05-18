require 'rubygame/gl/shared'
require 'rubygame/gl/event_types'
require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'

class Camera
	attr_accessor :screen_region
	attr_accessor :world_region
	attr_accessor :clear_screen
	attr_accessor :background_color

	def initialize(&block)
		@screen_region, @world_region = screen_region, world_region
		@clear_screen = true
		@background_color = [0,0,0,0]
		instance_eval(&block) if block_given?
	end

	def activate
		setup_viewport
		setup_rendering
		setup_projection
	end

	def clear
		r,g,b,a = @background_color.to_ary
		a = 0.0 unless a
		glClearColor(r,g,b,a)
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	end	

	def screen_to_world
		s, w = @screen_region, @world_region

		flip = Matrix3.scale( 1, -1 )
		
		shift1 = Matrix3.translate( *(-s.center.to_v) )
		
		normalize = Matrix3.scale(  1/s.width.to_f, 1/s.height.to_f )
		
		shift = Matrix3.translate( 0, 1 )

		resize = Matrix3.scale( w.width, w.height )
		
		shift2 = Matrix3.translate( *(w.center.to_v) )

		return shift2 * resize * flip * normalize * shift1
		#return shift1 * flip * normalize * resize * shift2
	end
	
	def convert_to_worldspace( pos )
		screen_to_world() * Point2[*pos]
	end

	def make_mouseclick( event )
		MouseClickEvent.new(event.button,
		                    convert_to_worldspace(event.pos) )
	end
	
	def make_mousehover( event )
		MouseHoverEvent.new(event.buttons, 
		                    convert_to_worldspace(event.pos),
		                    convert_to_worldspace(event.rel) )
	end

	
	def draw( group )
		clear if @clear_screen
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
		glEnable(GL_SCISSOR_TEST)
		glDepthFunc(GL_LESS)
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	end
	
	def setup_viewport
		x,y = @screen_region.left, @screen_region.bottom
		w,h = @screen_region.size
		glViewport( x, y, w, h )
		glScissor( x, y, w, h )
	end
end
