
# Signals that objects have begun colliding.
class CollisionStartEvent
	attr_accessor :objects
	
	def initialize( *objects )
		@objects = objects
	end
end

# Signals that objects are still colliding.
# This will be periodically emitted while the objects
# are colliding with each other.
class CollisionEvent
	attr_accessor :objects
	
	def initialize( *objects )
		@objects = objects
	end
end

# Signals that objects are no longer colliding.
class CollisionEndEvent
	attr_accessor :objects
	
	def initialize( *objects )
		@objects = objects
	end
end


# CollisionHandler registers objects to be checked for collision.
# When two registered objects collide, a CollisionEvent is emitted.
class CollisionHandler
	
	# for debugging; remove later
	attr_accessor :layers, :colliding_pairs, :event_outbox
	
	def initialize
		@layers = {}
		@colliding_pairs = []
		@event_outbox = []
	end
	
	def [](key)
		@layers[key]
	end
	
	def []=(key,value)
		@layers[key] = value
	end
	
	def add_to_layer( layer, *objects )
		@layers[layer] |= objects
	end
	
	def remove_from_layer( layer, *objects )
		@layers[layer] -= objects		
	end
	
	def handle
		check_existing_collisions
		find_new_collisions
		flush_events
	end

	def check_existing_collisions
		pairs = @colliding_pairs
		pairs.each do |pair|

			a, b = *pair
			if a.collides_with? b
				@event_outbox << CollisionEvent.new(*pair)
			else
				@event_outbox << CollisionEndEvent.new(*pair)
				@colliding_pairs.delete(pair)
			end

		end
	end
	
	def find_new_collisions
		@layers.each_value do |objects|
			objects.each_with_index do |a, index|

				# We only need to check against objects appearing *after* this one.
				objects.slice( ((index+1)..-1) ).each do |b|

					if a.collides_with? b

						# We sort by object_id to make [A, B] and [B, A] the same.
						sorted = [a, b].sort_by { |o| o.object_id }

						# Don't do anything if we're already watching
						unless @colliding_pairs.include? sorted
							@colliding_pairs << sorted
							@event_outbox << CollisionStartEvent.new(*sorted)
						end

					end

				end

			end
		end
	end
	
	def flush_events
		outbox, @event_outbox = @event_outbox, []
		return outbox
	end
end
