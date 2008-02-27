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

	ShapeStruct = Struct.new(:shape, :mass, :offset)
	
	class Sprite
		attr_reader :scene, :body, :event_handler
		attr_accessor :shapes, :image
		attr_accessor :emit_collide, :solid, :quality
		attr_reader :static
		
		def initialize( scene, &block )
			@scene = scene
			@body = CP::Body.new(0,0)
			@shapes = []

			@image = nil
			@quality = 1.0
			
			@depth = 0
			@emit_collide = true
			@solid = true
			@static = false
			
			@event_handler = EventHandler.new do |handler|
				handler.append_hook { |h|
					h.owner = self
					h.trigger = TickTrigger.new()
					h.action = MethodAction.new(:update, true)
				}
				
				handler.append_hook { |h|
					h.owner = self
					h.trigger = InstanceOfTrigger.new( DrawEvent )
					h.action = MethodAction.new(:draw, true)
				}
			end
			
			instance_eval(&block) if block_given?
		end

		
		def add_shape( shape, mass, offset )
			@shapes += ShapeStruct.new( shape, mass, offset )
			shape.body = @body
			@space.add_shape(shape)
		end

		
		def draw( event )
			camera = event.camera
			
			case( camera.mode )
			when Camera::RenderModeSDL
				
				# Don't need to do anything if it's invisible!
				if( @image )
					image = @image
					
					rot = (@body.a + camera.rotation) * PI/180
					scale = camera.zoom
					
					# Don't need to do this if there's no rotation or scale change
					if(rot != 0.0 and scale != 1.0)
						
						# Use antialiasing if quality level is high enough
						aa = (camera.quality * self.quality > 0.5)
						image = image.rotozoom( rot, scale, aa )
						
					end
					
					rect = image.make_rect
					rect.center = ((@body.p * camera.zoom) - camera.position).to_ary

					camera.mode.dirty_rects << image.blit( camera.mode.surface, rect )
				else
					return nil
				end
				
			else
				return nil				
			end

		end

		
		def handle( event )
			@event_handler.handle( event )
		end

		
		def mark_dead
			@scene.mark_dead(self)
		end

		
		def recalc_mi
			@body.m = @shapes.inject(0) { |mem, s| mem + s.mass }
			
			@body.i = @shapes.inject(0) { |mem, s|
				case(s.shape)
				when CP::Shape::Poly
					mem + CP.moment_for_poly( s.mass, s.shape.verts, s.offset )
				when CP::Shape::Circle
					mem + CP.moment_for_circle( s.mass, 0, s.shape.r, s.offset )
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
			if( enable and !(@static) )
				@scene.space.add_body( @body )
			elsif( !(enable) and @static )
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
				
				# Don't need to do anything if it's invisible!
				if( @image )
					rect = @image.make_rect
					
					rot = (@body.a + camera.rotation) * PI/180
					scale = camera.zoom
					
					# Don't need to do this if there's no rotation or scale change
					if(rot != 0.0 and scale != 1.0)
						rect.size = Rubygame::Surface.rotozoom_size( rect.size, rot, scale )
					end
					
					rect.center = ((@body.p * camera.zoom) - camera.position).to_ary

					bg = camera.background
					bg.blit( camera.mode.surface, rect, rect )
					
					camera.mode.dirty_rects << rect
				else
					return nil
				end
				
			else
				return nil				
			end
		end

		
		def update( tick )
		end
				
	end
end
