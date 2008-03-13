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

require 'rubygame/event'

module Rubygame

	class CollisionHandler
		def initialize
			@collisions = {}
			@old = [{}]*3
			@outbox = []
		end
		
		def flush
			_check_old
			
			out = @outbox
			@outbox = []
			return out
		end
		
		def register( a, b, contacts )
			@collisions[ [a,b] ] = contacts
			
			old_collide = false
			@old.each { |old| old_collide = true if old[[a,b]] }
			
			if( old_collide )
				@outbox << CollisionEvent.new( a, b, contacts )
			else
				@outbox << CollisionStartEvent.new( a, b, contacts )
			end
		end
		
		private
		
		def _check_old
			
			oldest = @old.shift
			@old << @collisions
			
			recent = {}
			
			# "Flatten" the old collisions to get a summary of
			# the collisions that have happened recently.
			@old.reverse_each { |old|
				old.each_pair { |k,v| 
					recent[k] = v
				}
			}

			# Check each collision in the set of oldest collisions,
			# and emit an End event if it doesn't appear in the more
			# recent collisions.
			oldest.each_pair { |k,v|
				a, b = k
				if recent[k] == nil
					@outbox << CollisionEndEvent.new( a, b, v )
				end
			}

			@collisions = {}
		end
		
	end

end
