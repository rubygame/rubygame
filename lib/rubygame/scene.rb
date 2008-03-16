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
require 'rubygame/chipmunk'

require 'rubygame'
require 'rubygame/camera'
require 'rubygame/clock'
require 'rubygame/collision_handler'
require 'rubygame/event'
require 'rubygame/event_handler'
require 'rubygame/event_hook'
require 'rubygame/event_triggers'
require 'rubygame/event_actions'


module Rubygame

	class Scene
		include HasEventHandler
		
		attr_reader :clock, :collision_handler, :event_handler, :event_queue
		attr_reader :camera, :sprites, :space
		attr_accessor :time_step
		
		def initialize( camera_mode )
			super() # Creates @event_handler
			
			@clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }
			@time_step = 0.02
			@leftover_tick = 0.0
			
			@sprites = []
			@dead_sprites = []
			
			@camera = Rubygame::Camera.new( camera_mode )
			
			@collision_handler = CollisionHandler.new()
			
			@event_queue = EventQueue.new()

			# Forward collision events only to the concerned sprites
			append_hook({
				:consumes => true,
				:trigger => CollisionTrigger.new,
				:action => BlockAction.new do |owner, event|
					event.a.sprite.handle( event )
					event.b.sprite.handle( event )
				end
			})
			
			
			append_hook(
				:trigger => AnyTrigger.new( MouseClickTrigger.new,
				                            MouseReleaseTrigger.new ),
				:action => BlockAction.new do |owner, event|
					trans = owner.camera.screen_to_world( {:pos => vect(*event.pos)} )
					event.world_pos = trans[:pos]
					owner.sprites.each { |sprite| sprite.handle( event ) }
				end
			)
			
			
			append_hook(
				:trigger => MouseHoverTrigger.new,
				:action => BlockAction.new do |owner, event|
					trans = owner.camera.screen_to_world( {:pos => vect(*event.pos),
					                                       :rel => vect(*event.rel)} )
					event.world_pos = trans[:pos]
					event.world_rel = trans[:rel]
					owner.sprites.each { |sprite| sprite.handle( event ) }
				end
			)
			
			# Forward all events to @sprites members
			append_hook({
				:trigger => YesTrigger.new,
				:action => BlockAction.new do |owner, event|
					owner.sprites.each { |sprite| sprite.handle( event ) }
				end
			})
			
			# Update simulation on TickEvent.
			append_hook({
				:trigger => TickTrigger.new(),
				:action => MethodAction.new(:update, true)
			})
			
			@space = CP::Space.new()
			
			@space.set_default_collision_func { |a,b,contacts|
				# a and b are the two SHAPES that collided.
				if (a.emit_collide and b.emit_collide)
					self.collision_handler.register( a, b, contacts )
				end
				(a.solid and b.solid)
			}

		end

		def mark_dead( sprite )
			@dead_sprites << sprite
		end

		def register_sprite( sprite )
			@sprites << sprite
		end

		def sort_sprites
			@sprites.sort { |a,b| a.depth <=> b.depth }
		end
		
		def step
			@event_queue.push( *(@collision_handler.flush()) )
			@event_queue.fetch_sdl_events
			
			@event_queue.push( Rubygame::UndrawEvent.new(@camera) )
			@event_queue.push( @clock.tick )
			@event_queue.push( Rubygame::DrawEvent.new(@camera) )
			
			# Process the accumulated events
			@event_queue.each { |e| self.handle(e) }
		end
		
		def update( tick )
			# Remove dead sprites from the simulation
			_flush_dead_sprites()
			
			# Update the simulation (using a fixed time step for stability)
			# until it has caught up with the current time.
			@leftover_tick += tick.seconds
			while( @leftover_tick > @time_step )
				self.handle( PreStepEvent.new(@time_step) )
				@space.step( @time_step )
				@leftover_tick -= @time_step
			end
		end
		
		private
		
		# Remove all dead sprites from the simulation
		# (being careful to make sure they were actually
		# *in* the simulation in the first place).
		def _flush_dead_sprites
			@dead_sprites.each do |spr|
				spr.remove_from_space( space )
			end
			
			@sprites -= @dead_sprites
			
			@dead_sprites = []
		end
		
	end

end
