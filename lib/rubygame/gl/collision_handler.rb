
# Signals that objects have collided.
class CollisionEvent
	attr_accessor :objects
	
	def initialize( *objects )
		@objects = objects
	end
end


# CollisionHandler registers objects to be checked for collision.
# When two registered objects collide, a CollisionEvent is emitted.
class CollisionHandler
	
	# for debugging; remove later
	attr_accessor :layers
	
	def initialize
		@layers = {}
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
	
	def find_collisions
		@pairs = []

		@layers.each_value do |objects|
			objects.each_with_index do |a, index|

				# We only want to check against objects appearing *after* this one.
				# Otherwise, we'd be doing lots of redundant checks.

				objects.slice( ((index+1)..-1) ).each do |b|

					if a.collides_with? b

						# We'll add this pair, but not if it has already been added
						# (i.e. on another layer). We sort by object_id to make sure
						# [A, B] and [B, A] are considered as the same pair.
						
						sorted = [a, b].sort_by { |o| o.object_id }
						@pairs |= [sorted]

					end

				end

			end
		end
		
		return @pairs.collect { |pair| CollisionEvent.new(*pair) }
	end
end
