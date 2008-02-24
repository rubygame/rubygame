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

module Rubygame

	ShapeStruct = Struct.new(:shape, :mass, :offset)
	
	class Sprite
		attr_reader :scene, :body, :event_handler
		attr_accessor :shapes
		attr_accessor :emit_collide, :solid
		attr_reader :static
		
		def initialize( scene, &block )
			@scene = scene
			@body = CP::Body.new(0,0)
			@shapes = []
			
			@depth = 0
			@emit_collide = true
			@solid = true
			@static = false
			
			@event_handler = EventHandler.new do
				append_hook { |h|
					h.owner = self
					h.trigger = TickTrigger.new()
					h.action = MethodAction.new(:update, true)
				}
				
				append_hook { |h|
					h.owner = self
					h.trigger = InstanceOfTrigger.new( DrawEvent )
					h.action = MethodAction.new(:draw, true)
				}
			end
			
			instance_eval(&block) if block_given?
		end

		def add_shapes( *shape_structs )
			@shapes += shape_structs
		end
		
		def draw( event )
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
		
		def update( tick )
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
		
	end
end
