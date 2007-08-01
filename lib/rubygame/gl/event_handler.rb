class EventHandler

	#  call-seq:
	#    EventHandler.new { optional block }  ->  new_handler
	# 
	#  Create a new EventHandler. The optional block can be used
	#  for initializing the EventHandler.
	# 
	def initialize(&block)
		@hooks = []
		instance_eval(&block) if block_given?
	end

	# For testing purposes. Remove for production?
	attr_accessor :hooks
	
	#  call-seq:
	#    add_hook( hook, prepend=false )  ->  nil
	# 
	#  Add a hook to perform an action when a matching event is processed.
	#  If the EventHandler already has that hook, this method will only keep
	#  the first one.
	#  See Hook and #process_event.
	# 
	#  hook::     the hook to add. (Hook, required)
	#  prepend::  if true, add the hook at the top of the stack,
	#             otherwise it's added at the bottom. (boolean, optional)
	# 
	#  Returns::  nil
	# 
	def add_hook( hook, prepend=false )
		if prepend
			@hooks = [hook] | @hooks
		else
			@hooks = @hooks | [hook]
		end

		return nil
	end
	
	#  call-seq:
	#    remove_hook( hook )  ->  nil
	# 
	#  Remove a hook from the EventHandler, if that hook exists.
	#  If the EventHandler doesn't have that hook, this method will do nothing.
	# 
	#  hook::     the hook to remove. (Hook, required) 
	# 
	#  Returns::  nil
	# 
	def remove_hook( hook )
		@hooks -= [hook]
		return nil
	end

	#  call-seq:
	#    handle( event )  ->  nil
	#  
	#  Triggers every hook which matches the given event. See Hook.
	#  
	#  event:     the event to handle. (Object, required)
	# 
	#  Returns::  nil.
	# 
	def handle( event )
		matching_hooks = @hooks.select { |hook| hook.match?( event ) }
		matching_hooks.each { |hook| hook.perform( event ) }
		return nil
	end

end
