class EventHandler

	#  call-seq:
	#    EventHandler.match?( event, hook )  ->  true/false
	#  
	#  Test whether the hook describes the event. This method is used by
	#  EventHandler#process_event.
	#  
	#  event:    the event to be tested. (Object, required)
	#  hook::    a hash table of specifiers. (Hash, required)
	# 
	#  Returns:: true if hook describes event. (boolean)
	# 
	#  The hook describes the event if all specifiers match.
	#  That is, for each {:specifier => value} pair in the hook:
	#    event.send(:specifier) == value.
	#  
	#  NOTE: The :klass specifier (required) is handled specially, to
	#  also match subclasses of the given class:
	#    event.kind_of?( hook[:klass] )
	# 
	#  If you want to match only the class, but not subclasses, give
	#  the :class specifier too.
	# 
	#  NOTE: The :block specifier is ignored, if present.
	# 
	#  Example:
	#    event = Rubygame::KeyDownEvent( "a", [] )
	#    event.send(:string)                 # => "a"
	#    hook = { :klass => Rubygame::KeyDownEvent, :string => "a" }
	#    EventHandler.match?( event, hook )  # => true
	# 
	def self.match?( event, hook )
		hook = hook.dup
		hook.delete(:block)
		klass = hook.delete(:klass)[:klass]
		matches = nil
		if event.kind_of?(klass)
			matches = hook.all? { |key, value|
				event.send(key) == value
			}
		end
		return matches
	end

	#  call-seq:
	#    EventHandler.new { optional block }  ->  new_handler
	# 
	#  Create a new EventHandler. The optional block can be used
	#  for initializing the EventHandler.
	# 
	#  Example:
	#    EventHandler.new do
	#      add_hook( NewGameEvent ) { |event|  setup_new_game() }
	#      add_hook( GameOverEvent ) { |event|  display_high_scores() }
	#    end
	# 
	def initialize(&block)
		@hooks = []
		instance_eval(&block) if block_given?
	end
	
	attr_accessor :hooks
	
	#  call-seq:
	#    add_hook( klass, specifiers={} ) { |event| block }  ->  nil
	# 
	#  Add a new hook to call the block when a matching event is processed.
	#  See EventHandler.match? and #process_event.
	# 
	#  klass::       the class of event to match. (Class, required)
	#  specifiers::  a hash of table of :symbol => value pairs. (Hash, optional)
	# 
	#  Returns::     nil.
	# 
	#  If no specifiers are given, any event which is an instance of klass
	#  (or an instance of a subclass of klass) will trigger the hook.
	# 
	#  If specifiers are given, the event will only trigger the hook if it 
	#  matches all the specifiers. See EventHandler.match?.
	#  
	#  Example:
	#    handler = EventHandler.new()
	#    handler.add_hook( Rubygame::KeyDownEvent, :string => "a" ) { |event|
	#      puts "You pressed the A key!"
	#    }
	#    event = Rubygame::KeyDownEvent( "a", [] )
	#    handler.process_event( event )      # [printed]: You pressed the A key!
	# 	
	def add_hook( klass, specifiers={}, &block )
		unless block_given? or specifiers[:block]
			raise ArgumentError, "a block must be provided"
		end

		hook = Hash.new
		hook[:class] = klass
		hook[:block] = block
		hook.update(specifiers)
		@hooks << hook
		return nil
	end

	#  call-seq:
	#    process_event( event )  ->  nil
	#  
	#  Triggers every hook which matches the given event.
	#  See EventHandler.match?.
	#  
	#  event:     the event to be processed. (Object, required)
	# 
	#  Returns::  nil.
	#  
	#  Example:
	#    handler = EventHandler.new()
	#    handler.add_hook( Rubygame::KeyDownEvent, :string => "a" ) { |event|
	#      puts "You pressed the A key!"
	#    }
	#    event = Rubygame::KeyDownEvent( "a", [] )
	#    handler.process_event( event )      # [printed]: You pressed the A key!
	# 
	def process_event( event )
		matching_hooks = @hooks.select { |hook|
			EventHandler.match?(event, hook)
		}
		matching_hooks.each { |hook|
			hook[:block].call( event )
		}
		return nil
	end
end
