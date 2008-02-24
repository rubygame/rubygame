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
require 'rubygame/event_handler'
require 'rubygame/event_hook'
require 'rubygame/event_triggers'
require 'rubygame/event_actions'


module Rubygame

	class Scene
		attr_reader :event_handler, :event_queue, :clock, :sprites, :space
		attr_accessor :time_step
		
		def initialize(size)

			@clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }
			@time_step = 0.02
			@leftover_tick = 0.0
			
			@sprites = []
			@dead_sprites = []
			
			@event_queue = EventQueue.new()
			@event_handler = EventHandler.new()

			# Forward all events to @sprites members
			@event_handler.append_hook do |h|
				h.owner = self
				h.trigger = YesTrigger.new
				h.action = BlockAction.new { |owner, event|
					owner.sprites.each { |sprite| sprite.handle( event ) }
				}
			end
			
			@space = CP::Space.new()
			
			@space.set_default_collision_func { |a,b,contacts|
				if (a.emit_collide and b.emit_collide)
					scene.event_queue.push( CollisionEvent.new(a,b,contacts) )
				end
				return (a.solid and b.solid)
			}

		end

		def handle( event )
			@event_handler.handle( event )
		end
		
		def mark_dead( sprite )
			@dead_sprites << sprite
		end

		def sort_sprites
			@sprites.sort { |a,b| a.depth <=> b.depth }
		end
		
		def step
			tick = @clock.tick
			
			@event_queue.fetch_sdl_events
			@event_queue.push( tick )

			# Update the simulation (using a fixed time step for stability)
			# until it has caught up with the current time.
			@leftover_tick += tick.seconds
			while( @leftover_tick > @time_step )
				@space.step( @time_step )
				@leftover_tick -= @time_step
			end
			
			# Process the accumulated events
			@event_queue.each { |e| self.handle(e) }
			
			# Remove dead sprites from the simulation
			_flush_dead_sprites()

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
