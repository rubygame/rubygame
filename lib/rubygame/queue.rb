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

require "rubygame/event"

module Rubygame

	# EventQueue provides a simple way to manage SDL's events, allowing the
	# application to detect keyboard presses, mouse movements and clicks,
	# joystick movement, etc. You can also post custom events to the
  # EventQueue to help manage the game state.
  # 
  # This class replaces the old Rubygame::Queue class, which is no longer
  # available. While this class serves the same purpose as the old class,
  # they are significantly different in behavior. Please note that while
  # the old class was a Singleton, this class is not; you may have as many
  # separate instances of EventQueue as you wish (although it is strongly
  # recommended that only one be used to #fetch_sdl_events).
  # 
  # For basic usage, enable autofetch (see #initialize), then call
  # #each once per loop, passing a block which handles events. See the
  # sample applications for examples of this.
  #
  # If you wish to ignore certain types of events, append the ignored event
  # class to the internal variable +@filter+ (accessors are provided).
  # 
  # If the program has to pause and wait for an event (for example, if the
  # player must press a button to begin playing), you might find the #wait
  # method to be convenient.
	# 
	# For reference, the full list of SDL events is:
	# - Event (base class, not used by itself)
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
	class EventQueue < Array
    # Array of classes to be ignored by #push.
    attr_accessor :filter       

    # Whether to fetch SDL events automatically when #each and #wait are used.
    attr_accessor :autofetch    

    # Create a new EventQueue.
    # 
    # This method takes this argument:
    # autofetch:: whether to call #fetch_sdl_events automatically when #each
    #             and #wait are used. Defaults to true. If you do not enable
    #             autofetch, you should fetch SDL events manually.
    #             Autofetch status can be changed after initialization with
    #             the @autofetch accessors.
    def initialize(autofetch=true)
      @autofetch = autofetch
      @filter = []
    end

    # Append events to the EventQueue. Filtered events are silently ignored.
    def push(*events)
      events = events.flatten.delete_if {|e| @filter.include?(e.class)}
      events.each do |e|
        super( e )
      end
    end

    alias post push

    alias peek_each each        # Iterate through all events without removing.

    # Iterate through all events in the EventQueue, yielding them one at a time
    # to the given block. The EventQueue is flushed after all events have been
    # yielded. You can use #peek_each if you want to keep the events.
    #
    # If the internal variable @autofetch is true, this method will call
    # #fetch_sdl_events once before iterating.
    def each(&block)
      fetch_sdl_events if @autofetch
      super
      self.clear
    end

		# Posts pending SDL hardware events to the EventQueue. Only one EventQueue
    # should call this method per application, and only if you are not using
    # Rubygame#get_events to manually process events! Otherwise, some events
    # may be removed from SDL's event stack before they can be properly
    # processed!
		def fetch_sdl_events
			self.push(Rubygame.fetch_sdl_events())
		end

    # Return the first event on the EventQueue, or, if the EventQueue is empty,
    # wait for an event to be posted, then return that event. Only events
    # which are not filtered will trigger return.
    #
    # This method takes this argument:
    # time:: the amount of time (milliseconds) to delay between checking for
    #        new events. Defaults to 10 ms.
    #
    # If a block is given to this method, it will be run after each
    # unsuccessful check for new events. This method will pass to the block the
    # number of times it has checked for new events.
    # 
    # If the internal variable @autofetch is true, this method will call
    # #fetch_sdl_events before every check for new events.
    #
    # Please be cautious when using this method, as it is rather easy to
    # cause an infinite loop. Two ways an infinite loop might occur are:
    # 1. Waiting for an SDL event when @autofetch is disabled. (This is
    #    not a problem if the block will post an event.)
    # 2. Waiting for any event when all possible event types are filtered.
    #
    def wait(delay=10, &block)
      iterations = 0
      if block_given?
        loop do
          fetch_sdl_events() if @autofetch
          if self.length >= 1
            s = self.shift
            return s unless s == nil
          end
          yield iterations
          iterations += 1
          Rubygame::Time.delay(delay)
        end
      else
        loop do 
          fetch_sdl_events() if @autofetch
          s = self.shift
          return s unless s == nil
          iterations += 1
          Rubygame::Time.delay(delay)
        end
      end
    end

	end # class EventQueue

end # module Rubygame
