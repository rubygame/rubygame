#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2008  John Croisant
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

require 'chipmunk'

require 'rubygame'
require 'rubygame/camera'

module Rubygame

	class Sprite
		
		class << self
			def make_child_id
				@counter = defined?(@counter) ? @counter + 1 : 1
				return @counter
			end
		end
		
		include HasEventHandler

		attr_reader :scene, :body, :shapes, :event_handler
		attr_accessor :emit_collide, :solid, :quality
		attr_reader :image, :static
		attr_accessor :name
		
		def initialize( scene, &block )
			super() # Creates @event_handler
			
			@name = "%s %s"%[self.class, self.class.make_child_id]
			
			@scene = scene
			@scene.register_sprite(self)
			
			@body = CP::Body.new(0,0)
			@shapes = []

			@image = nil
			@quality = 1.0
			
			@depth = 0
			@emit_collide = true
			@solid = true
			@static = true
			

			# The smallest amount for either rotation (radians) or size
			# to change before the temporary image is regenerated.
			@change_threshold = { :rot => 0.03, :size => 0.1 }
			

			# Add event hooks to forward certain types of events
			# to the methods that handle them.
			magic_hooks( TickEvent     => :update,
									 DrawEvent     => :draw,
									 UndrawEvent   => :undraw,
									 PreStepEvent  => :pre_step )
			
			
			# Store a rotated/zoomed version of the image to re-use
			# if it doesn't change much next frame.
			@_image = nil

			# Store the rotation/size of the @temp_image, to test
			# for change.
			@_trans = {:rot => 0, :size => 1.0}
			
			# Store the rect of the previous draw position, for undrawing
			@_dirty_rects = []

			instance_eval(&block) if block_given?
		end
		
		
		def to_s
			"#<%s \"%s\">"%[self.class.name, @name]
		end
		
		def inspect
			"#<%s:%0x \"%s\" %s>"%[self.class.name, self.object_id, @name, @body.p]
		end

		
		def add_shape( shape )
			@shapes << shape
			shape.body = @body
			shape.sprite = self
			@scene.space.add_shape(shape)
		end

		
		def draw( event )
			camera = event.camera
			
			case( camera.mode )
			when Camera::RenderModeSDL
				_draw_sdl( camera )				
			else
				return nil				
			end

		end

		
		def image=( new_image )
			@image = new_image
			@_image = @image
		end
		
		
		def mark_dead
			@scene.mark_dead(self)
		end

		
		def recalc_mi
			@body.m = @shapes.inject(0) { |mem, s|
				s.mass ? mem + s.mass : mem
			}
			
			@body.i = @shapes.inject(0) { |mem, s|
				if( s.mass and s.offset )
					case(s)
					when CP::Shape::Poly
						mem + CP.moment_for_poly( s.mass, s.verts, s.offset )
					when CP::Shape::Circle
						mem + CP.moment_for_circle( s.mass, 0, s.r, s.offset )
					else
						mem
					end
				else
					mem
				end
			}
		end
		
		
		def remove_from_space( space )
			if space.bodies.include?( @body )
				space.remove_body( @body )
			end

			@shapes.each { |s|
				if space.shapes.include?( s )
					space.remove_shape( s ) 
				elsif space.static_shapes.include?( s )
					space.remove_static_shape( s )
				end
			}
		end

		
		def static=( enable )
			if( !(enable) and @static)
				@scene.space.add_body( @body )
			elsif( enable and !(@static) )
				@scene.space.remove_body( @body )
			else
				# no change, do nothing
			end
			@static = enable
		end

		
		def undraw( event )
			camera = event.camera
			
			case( camera.mode )
			when Camera::RenderModeSDL
				_undraw_sdl( camera )
			else
				return nil				
			end
		end

		
		def update( tick )
		end
		
		def pre_step( event )
		end

		
		private
		

		def _render_temp_image( trans, quality )
			rot_change  = (trans[:rot ] - @_trans[:rot ]).abs
			size_change = (trans[:size] - @_trans[:size]).abs
			
			if( rot_change  > @change_threshold[:rot ] or \
			    size_change > @change_threshold[:size])

				# Use antialiasing if quality level is high enough
				aa = (quality * self.quality > 0.5)
				
				@_image = @image.rotozoom( -trans[:rot]*57.2958, trans[:size], aa )
				@_trans = trans
				
			end
		end
		
		
		def _draw_sdl( camera )
			# Don't need to do anything if it's invisible!
			if( @image )

				if @_image == nil
					@_image = @image
				end

				trans = camera.world_to_screen(:pos  => @body.p,
				                               :size => (@size or 1),
				                               :rot  => @body.a)
				
				_render_temp_image( trans, camera.mode.quality )
				
				rect = @_image.make_rect
				rect.center = trans[:pos].to_ary

				@_dirty_rects << @_image.blit(camera.mode.surface, rect) 

			else
				return nil
			end
		end
		
		
		def _undraw_sdl( camera )
			# Don't need to do anything if there are no 
			unless( @_dirty_rects.empty?)
				bg = camera.mode.background

				@_dirty_rects.each do |r|
					bg.blit(camera.mode.surface, r, r)
					camera.mode.dirty_rects << r
				end

				@_dirty_rects = []
			else
				return nil
			end
		end
		
	end
end
