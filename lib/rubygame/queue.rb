#--
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2005  John 'jacius' Croisant
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

require "singleton"
require "event"

module Rubygame
	class Queue
		include Singleton
		def initialize()
			@@pending = []
			@@allowed = Rubygame::ALL_EVENT_CLASSES
		end

		def allow(*types)
			added = (Rubygame::ALL_EVENT_CLASSES - types.flatten()) & @@allowed
			for type in types.flatten()
				if type.kind_of? Class
					if not @@allowed.include? type
						@@allowed.push(type)
					end
				elsif type.kind_of? Event
					@@allowed.push(type.class)
				end
			end
			return added
		end

		def allowed
			return @@allowed.dup
		end

		def allowed=(*types)
			added = Rubygame::ALL_EVENT_CLASSES - (types.flatten() & @@allowed)
			@@allowed = []
			self.allow(types)
			return added
		end

		def block(*types)
			removed = @@allowed & types.flatten()
			for type in types.flatten()
				if type.kind_of? Class
					if @@allowed.include? type
						@@allowed.delete(type)
					end
				elsif type.kind_of? Event
					@allowed.delete(type.class)
				end
			end
			return blocked
		end

		def blocked
			return Rubygame::ALL_EVENT_CLASSES - @@allowed.dup
		end

		def blocked=(*types)
			removed = types.flatten() & @@allowed
			@@allowed = Rubygame.ALL_EVENT_CLASSES
			self.block(types)
			return removed
		end

		def get(*types)
			allow = []
			if types.length > 0
				for type in types.flatten()
					if type.kind_of? Class
						if not allow.include? type
							allow.push(type)
						end
					elsif type.kind_of? Event
						allow.push(type.class)
					end
				end
			else
				allow = @@allowed
			end
			update_pending()
			get = @@pending.delete_if{|event| not allow.include? event.class}
			@@pending -= get
			return get
		end

		def post(*events)
			update_pending() # so posted events will appear after SDL events
			not_added = []
			for event in events.flatten()
				if event.kind_of? Event
					@@pending.push(event)
				else not_added.push(event)
				end
			end
			return not_added
		end

		def update_pending
			@@pending += get_sdl()
		end
		private :update_pending

		# Wait until an event of the given class(es) is generated, then return
		# that event. All other types of events will be discarded in the meantime.
		# 
		# +*klasses+ is the event classes which will trigger the method to return.
		# If this argument is omitted, ALL event classes will trigger return.
		# 
		# All classes which are not allowed by the Queue and/or are not
		# Rubygame-generated hardware events (i.e. not custom events) will be
		# stripped from +klasses+.
		# 
		# If +klasses+ is given, but does not contain any valid classes,
		# this method immediately returns +nil+.
		def wait( *klasses )
			klasses.flatten!
			if klasses.length < 1 # no args
				klasses = Rubygame::ALL_EVENT_CLASSES
			end
			# eliminate invalid args
			klasses = klasses.delete_if{ |klass| 
				!(Rubygame::ALL_EVENT_CLASSES.include?(klass) and\
					@@allowed.include?(klass))
			}
			if klasses.length < 1 # no _valid_ args
				return nil
			end
			loop do
				self.get().each { |event|
					return event if klasses.include? event.class
				}
			end
		end

	end # class Queue

end # module Rubygame
