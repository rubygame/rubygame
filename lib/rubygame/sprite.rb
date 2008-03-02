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
		include HasEventHandler

		attr_reader :scene, :body, :shapes, :event_handler
		attr_accessor :image, :emit_collide, :solid, :quality
		attr_reader :static
		
		def initialize( scene, &block )
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
			
			@event_handler = EventHandler.new
			
			append_hook({
				:trigger => TickTrigger.new(),
				:action => MethodAction.new(:update, true)
			})
				
			append_hook({
				:trigger => InstanceOfTrigger.new( DrawEvent ),
				:action => MethodAction.new(:draw, true)
			})
				
			append_hook({
				:trigger => InstanceOfTrigger.new( UndrawEvent ),
				:action => MethodAction.new(:undraw, true)
			})
			
			instance_eval(&block) if block_given?
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
				if space.shapes.include?( s.shape )
					space.remove_shape( s.shape ) 
				elsif space.static_shapes.include?( s.shape )
					space.remove_static_shape( s.shape )
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

		
		private
		
		
		def _draw_sdl( camera )
			# Don't need to do anything if it's invisible!
			if( @image )
				image = @image

				trans = camera.world_to_screen(:pos => @body.p, :size => (@size or 1), :rot => @body.a)
				trans[:rot] *= 57.2958 # converted to degrees and flip
				
				# Don't need to do this if there's no rotation or scale change
				unless( trans[:rot] == 0.0 and trans[:size] == 1.0)
					
					# Use antialiasing if quality level is high enough
					aa = (camera.mode.quality * self.quality > 0.5)
					
					image = image.rotozoom( -trans[:rot], trans[:size], aa )
					
				end
				
				rect = image.make_rect
				rect.center = trans[:pos].to_ary

				camera.mode.dirty_rects << image.blit( camera.mode.surface, rect )
			else
				return nil
			end
		end
		
		
		def _undraw_sdl( camera )
			# Don't need to do anything if it's invisible!
			if( @image )
				rect = @image.make_rect
				
				trans = camera.world_to_screen(:pos => @body.p, :size => (@size or 1), :rot => @body.a)
				trans[:rot] *= 57.2958 # converted to degrees and flip
				
				# Don't need to do this if there's no rotation or scale change
				unless( trans[:rot] == 0.0 and trans[:size] == 1.0)
					rect.size = Rubygame::Surface.rotozoom_size( rect.size, -trans[:rot], trans[:size] )
				end
				
				rect.center = trans[:pos].to_ary

				bg = camera.mode.background
				bg.blit( camera.mode.surface, rect, rect )
				
				camera.mode.dirty_rects << rect
			else
				return nil
			end
		end
		
	end
end
