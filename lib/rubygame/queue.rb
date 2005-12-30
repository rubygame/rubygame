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

	# (Note: I'm not putting much effort into documenting the current Queue
	# class, because it is going to be changing substantially in the next
	# version. It is mostly usable for now, but neither elegant nor fun to use.
	# Frankly, I think it's an abomination, and it took all my willpower to
	# put off rewriting it until next version.)
	# 
	# Queue provides an interface to SDL's events, allowing the
	# application to detect keyboard presses, mouse movements and clicks,
	# joystick movement, etc.
	# 
	# The full list of default events is:
	# - Event (base class, not useful by itself)
	# - ActiveEvent
	# - JoyAxisEvent
	# - JoyBallEvent
	# - JoyDownEvent
	# - JoyHatEvent
	# - JoyUpEvent
	# - KeyDownEvent
	# - KeyUpEvent
	# - MouseDownEvent
	# - MouseMotionEvent
	# - MouseUpEvent
	# - QuitEvent
	# - ResizeEvent
	#
	# You are allowed to create new child classes of Event and post them to
	# the Queue, but for now you would probably be better off using some other
	# data structure to hold your own events. I recommend checking out the queue
	# class in Ruby's stardard library.
	# 
	# P.S. Queue is a singleton, so you must use Queue.instance, not Queue.new.
	# 
	class Queue
		include Singleton
		def initialize()						# :nodoc:
			@@pending = []
			@@allowed = Rubygame::ALL_EVENT_CLASSES
		end

		# Allow the given event classes. Returns all event classes that had
		# previously been disallowed, but are now allowed.
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

		# Returns all event classes which are allowed.
		def allowed
			return @@allowed.dup
		end

		# Allow ONLY the given event classes. Returns all event classes that had
		# previously been disallowed, but are now allowed.
		def allowed=(*types)
			added = Rubygame::ALL_EVENT_CLASSES - (types.flatten() & @@allowed)
			@@allowed = []
			self.allow(types)
			return added
		end

		# Disallow the given event classes from being posted. Returns all classes
		# which had previously been allowed, but are now disallowed.
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

		# Return all default Rubygame event classes which are disallowed
		# by the Queue.
		def blocked
			return Rubygame::ALL_EVENT_CLASSES - @@allowed.dup
		end

		# Cause the Queue to allow ONLY all default Rubygame event classes EXCEPT
		# the given classes. Returns all classes which had previously been allowed,
		# but are now disallowed.
		def blocked=(*types)
			removed = types.flatten() & @@allowed
			@@allowed = Rubygame.ALL_EVENT_CLASSES
			self.block(types)
			return removed
		end

		# call-seq: get( *klasses )  ->  Array
		# 
		# Get all events currently in the Queue which match the classes in the
		# Array +klasses+, and return them in an Array. If +klasses+ is omitted,
		# returns all 
		# 
		# Events which did not match will remain on the Queue, so make sure you
		# eventually #get every class of events that is #allowed, or they might
		# build up in the Queue.)
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

		# call-seq: post( *events )  ->  Array
		# 
		# Post one or more events to the Queue. Only events which meet these
		# criteria will be posted:
		# - its class is a child class of Event.
		# - its class is allowed by the Queue.
		# 
		# Returns all the given events which were not posted.
		def post(*events)
			update_pending() # so posted events will appear after SDL events
			not_added = []
			for event in events.flatten()
				if event.kind_of? Event and @@allowed.include?(event.class)
					@@pending.push(event)
				else not_added.push(event)
				end
			end
			return not_added
		end

		# Adds SDL hardware events to the Queue's list of pending events.
		def update_pending					# :nodoc:
			@@pending += get_sdl()
		end
		private :update_pending

		# call-seq: wait( *klasses )  ->  Event
		# 
		# Waits until an event matching the classes in Array +klasses+ occurs,
		# then return that event. All non-matching events will be *discarded* in
		# the meantime.
		# 
		# If +klasses+ is omitted, ANY event class allowed by the Queue will
		# trigger return. (Important: omitting +klasses+ is not the same as 
		# giving +nil+.)
		# 
		# +klasses+ is an Array of the Event classes which will trigger this method
		# to return. Any classes which are blocked by the Queue or are 
		# not Rubygame-generated hardware events will be stripped from +klasses+.
		# 
		# If +klasses+ is given, but does not contain any valid classes,
		# this method will immediately return +nil+.
		# 
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
