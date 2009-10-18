#--
# 
# This file is one part of:
#	  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
# 
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
# 
#++



module Rubygame

	# EventQueue provides a simple way to manage SDL's events, allowing the
	# application to detect keyboard presses, mouse movements and clicks,
	# joystick movement, etc. You can also post custom events to the
  # EventQueue to help manage the game state.
  # 
  # For basic usage, create a #new EventQueue with autofetch, then call the
  # #each method once per game loop, passing a block which handles events.
  # See the sample applications for examples of this.
  # 
  # In Rubygame 2.4 and later, you can call #enable_new_style_events to make
  # EventQueue fetch the new event classes (in the Rubygame::Events module).
  # Otherwise, the old classes will be used, for backwards compatibility.
  # 
  # It is **strongly recommended** that you use the new event classes.
  # The old classes are deprecated as of Rubygame 2.4, and will be removed
  # entirely in Rubygame 3.0.
  #
  # If you wish to ignore all events of a certain class, append those classes
  # the instance variable @ignore (accessors are provided). You can ignore as
  # many classes of events as you want, but make sure you don't ignore ALL
  # event classes, or the user won't be able to control the game!
  # 
  # If the program has to pause and wait for an event (for example, if the
  # player must press a button to begin playing), you might find the #wait
  # method to be convenient.
	# 
	class EventQueue < Array
    # Array of classes to be ignored by #push.
    attr_accessor :ignore

    # Whether to fetch SDL events automatically when #each and #wait are used.
    # Enabled by default.
    attr_accessor :autofetch    

    # Create a new EventQueue.
    def initialize()
      @autofetch = true
      @ignore = []
      @new_style_events = false
      yield self if block_given?
    end


    # Enable new-style events. These are the event classes in the 
    # Rubygame::Events module, which were added in Rubygame 2.4.
    # 
    # If you call this method, the new event classes will be used.
    # Otherwise, the old classes will be used, for backwards
    # compatibility.
    # 
    # It is **strongly recommended** that you use the new event
    # classes. The old classes are deprecated as of Rubygame 2.4,
    # and will be removed entirely in Rubygame 3.0.
    # 
    def enable_new_style_events
      @new_style_events = true
    end


    # Append events to the EventQueue.
    # Silently ignores events whose class is in @ignore.
    def push(*events)
      events = events.flatten.delete_if {|e| @ignore.include?(e.class)}
      events.each do |e|
        super( e )
      end
    end

    alias post push


    alias :_old_each :each
    private :_old_each

    # Iterate through all events in the EventQueue, yielding them one at a time
    # to the given block. The EventQueue is flushed after all events have been
    # yielded. You can use #peek_each if you want to keep the events.
    #
    # If the internal variable @autofetch is true, this method will call
    # #fetch_sdl_events once before iterating.
    def each( &block )
      fetch_sdl_events if @autofetch
      _old_each( &block )
      self.clear
    end

    # Like #each, but doesn't remove the events from the queue after
    # iterating. 
    def peek_each( &block )
      fetch_sdl_events if @autofetch
      _old_each( &block )
    end


    # Posts pending SDL hardware events to the EventQueue. Only one EventQueue
    # should call this method per application, and only if you are not using
    # Rubygame#fetch_sdl_events to manually process events! Otherwise, some
    # events may be removed from SDL's event stack before they can be properly
    # processed!
		def fetch_sdl_events
      if @new_style_events
        self.push( Rubygame::Events.fetch_sdl_events() )
      else
        Rubygame.deprecated("Rubygame::EventQueue with old event classes",
                            "3.0")
        self.push( Rubygame.fetch_sdl_events() )
      end
		end

    # Wait for an event to be posted, then return that event.
    # If there is already an event in the queue, this method will immediately
    # return that event.
    # Events that are ignored will not trigger the return.
    #
    # This method takes this argument:
    # time:: how long (in milliseconds) to delay between each check for
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
    # 2. Waiting for any event when all possible event types are ignored.
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
          Rubygame::Clock.delay(delay)
        end
      else
        loop do 
          fetch_sdl_events() if @autofetch
          s = self.shift
          return s unless s == nil
          iterations += 1
          Rubygame::Clock.delay(delay)
        end
      end
    end

	end # class EventQueue


  # A mixin module to extend EventQueue with the ability to 'deliver' specific
  # types of events to subscribed objects, a la a mailing list. Each object
  # must subscribe for the classes of events it wishes to receive;
  # when the MailQueue receives an event of that type, it will deliver
  # it to the subscribers. See #subscribe for more information.
  # 
  # Please note that if you extend an already-existing EventQueue object
  # with this mixin module (rather than including it in a class), you must
  # call #setup before using the object. This will create the necessary
  # internal variables for the MailQueue to work.
  # 
  module MailQueue
    # Whether to automatically deliver events as they are received.
    # Enabled by default.
    attr_accessor :autodeliver

    # Create a new MailQueue object.
    # Like EventQueue.new, this method will yield self if a block is given.
    def initialize()
      setup()
      super
    end

    # Create the necessary internal variables for the MailQueue.
    def setup
      @subscribe = Hash.new
      @autodeliver = true
    end

    # Returns an Array of all event classes which have at least one subscriber.
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
    end

    # Returns true if +client+ is currently subscribed to receive events
    # of type +klass+.
    def subscribed?(client,klass)
      return true if @subscribe[klass].include?(client)  rescue NoMethodError
      return false
    end

    # Unsubscribes the client to stop receiving events of type +klass+.
    # It is safe (has no effect) to unsubscribe for an event type you
    # are not subscribed to receive.
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
            clients.each do |client|
              client.push(event) rescue NoMethodError
            end 
          end
        rescue NoMethodError
        end
      }
    end
    private :deliver_event

    # Deliver each pending event to all objects which are subscribed to
    # that event class. Every client object MUST have a #push method, or
    # events can't be delivered to it, and it will become very lonely!
    # 
    # The queue will be cleared of all events after all deliveries are done.
    def deliver()
      each() { |event|  deliver_event(event) }
      clear()
    end

    # Append events to the queue. If @autodeliver is enabled, all events
    # on the queue will be delivered to subscribed client objects immediately.
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

end # module Rubygame
