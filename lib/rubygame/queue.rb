#--
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2006  John 'jacius' Croisant
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


  # A mixin module to extend EventQueue with the ability to 'deliver' specific
  # types of events to subscribed objects, a la a mailing list. Each object
  # must be subscribed for the types (classes) of events it wishes to receive;
  # then, when the ForwardingQueue receives an event of that type, it will
  # push it onto the subscriber objects. See #subscribe for more information.
  # 
  # Please note that if you extend an already-existing EventQueue object
  # with this mixin module (rather than including it in a class), you must
  # call #setup before using the object. This will create the necessary
  # internal variables for the MailQueue.
  # 
  module MailQueue
    attr_accessor :autodeliver

    # Create a new MailQueue object. If +autodeliver+ is true, the queue
    # will automatically deliver events after #push; otherwise, you must
    # call #deliver to deliver all events on the queue.
    def initialize(autodeliver=true,*args)
      setup(autodeliver)
      super(*args)
    end

    # Create the necessary internal variables for the MailQueue.
    def setup(autodeliver=true)
      @subscribe = Hash.new
      @autodeliver = autodeliver
    end

    # Returns an Array of all event classes which have at least one subscribed
    # client object.
    def list
      @subscribe.collect { |k, v|  
        (v.length > 0) ? k : nil  rescue NoMethodError nil
      }.compact
    end

    # Subscribe +client+ to receive events that match +klass+.
    # 
    # After the client object has been subscribed, the MailQueue will
    # push along any event for which "klass === event" is true. This usually
    # means that the event is an instance of klass or one of klass's child
    # classes; however, note that klass may have changed its own #=== operator
    # to have different behavior, so this is not always the case.
    #
    # Important: the MailQueue uses the client's #push method to deliver
    # events! If the client does not have such a method, MailQueue will
    # silently catch the error and move on to the next client.
    # 
    # A client object may be subscribed for many different types of events
    # simultaneously, and more than one client object may be subscribed to
    # any type of event (in which case each object will receive the event).
    # A client may also be subscribed multiple times for the same type (in
    # which case it will receive duplicate events). Likewise, the client will
    # receive duplicates if it is subscribed to multiple classes which share
    # ancestry, for example Numeric and Float.
    # 
    # If a client wishes to receive ALL types of events, it can subscribe to
    # Object, which is a parent class of all objects.
    # 
    # If the queue's @autodeliver is true, it will deliver events to
    # subscribers immediately after they are posted, rather than waiting for
    # #deliver to be called.
    def subscribe(client,klass)
      @subscribe[klass] << client
    rescue NoMethodError
      @subscribe[klass] = [client] if @subscribe[klass].nil?
    ensure
      return  
    end

    # Returns true if +client+ is currently subscribed to receive events
    # of type +klass+.
    def subscribed?(client,klass)
      return true if @subscribe[klass].include?(client)  rescue NoMethodError
      return false
    end

    # Unsubscribes the client to stop receiving events of type +klass+.
    # It is safe (no effect) to unsubscribe for an event type you are not
    # subscribed to receive.
    def unsubscribe(client,klass)
      @subscribe[klass] -= [client]  rescue NoMethodError
    ensure
      return
    end

    # This private method is used by #deliver to do the real work.
    def deliver_event(event)
      @subscribe.each_pair { |klass,clients|
        begin
          if klass === event
            clients.each { |client|
              client.push(event) rescue NoMethodError
            } 
          end
        rescue NoMethodError
        end
      }
    end
    private :deliver_event

    # Deliver each pending event to objects which are subscribed to its
    # type of event. Every client object MUST have a #push method, or
    # events can't be delivered to it, and it will become very lonely!
    # 
    # The queue will be cleared of all events after all deliveries are done.
    def deliver()
      each() { |event|  deliver_event(event) }
      clear()
    end

    # Append events to the queue. If @autodeliver is enabled, all events
    # on the queue will be delivered to subscribed client objects afterwards.
    def push(*args)
      # Temporarily disable autofetch to avoid infinite loop
      a, @autofetch = @autofetch, false
      # Fetch once to emulate autofetch, if it was enabled before
      fetch_sdl_events() if a

      super
      deliver() if @autodeliver

      @autofetch = a
      return
    end
  end

#   # Rewrite this blurb.
#   # 
#   # Like a MailQueue, but in addition to filtering by event class,
#   # it can filter by value of event attributes. Essentially, this shifts
#   # more of the work away from the object, and onto the queue.
#   # 
#   # E.g. an object might subscribe to receive KeyDownEvents whose
#   # :key attribute == K_A, and would then be notified when the A key is
#   # pressed, but not other keys.
#   module SmartQueue
#     include MailQueue

#     def subscribe(client,klass,hash=nil)
#       @subscribe[klass] << [client,hash]
#     rescue NoMethodError
#       @subscribe[klass] = [[client,nil]] if @subscribe[klass].nil?
#     ensure
#       return
#     end

#     # Returns true if +client+ is currently subscribed to receive events
#     # of type +klass+.
#     def subscribed?(client,klass,hash=nil)
#       return true if @subscribe[klass].select { |pair|
#         pair[0] == client and pair[1] == hash
#       }.length > 0
#     rescue NoMethodError
#       return false
#     end

#     # Unsubscribes the client to stop receiving events of type +klass+.
#     # It is safe (no effect) to unsubscribe for an event type you are not
#     # subscribed to receive.
#     def unsubscribe(client,klass,hash=nil)
#       @subscribe[klass].reject! { |pair|
#         pair[0] == client and pair[1] == hash
#       } rescue NoMethodError
#     ensure
#       return
#     end

#     def deliver_event(event)
#       begin
#         e = event.dup
#       rescue TypeError
#         e = event
#       end
#       @subscribe.each_pair { |klass,clients|
#         begin
#           if klass === e
#             clients.each_pair { |client,hash|
#               good = true
#               unless hash.nil?
#                 hash.each_pair { |attribute, val|
#                   good = false unless e.send(attribute) == val
#                 }
#               end
#               if good
#                 client.push(event) rescue NoMethodError
#               end
#             } 
#           end
#         rescue NoMethodError
#         end
#       }
#     end
#   end

end # module Rubygame
