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
	#    append_hook( hook )  ->  hook
	#    append_hook( &block )  ->  hook
	# 
	#  Puts a Hook at the bottom of the stack (it will be handled last).
	#  If the EventHandler already has that hook, it is moved to the bottom.
	#  See Hook and #handle. 
	# 
	#  This method has two distinct forms. The first form adds an existing Hook
	#  instance; the second form constructs a new Hook instance and adds it.
	# 
	#  hook::     the hook to add. (Hook, for first form only)
	# 
	#  block::    a block to initialize the hook. (Proc, for second form only)
	# 
	#  Returns::  the hook that was added. (Hook)
	# 
	#  Contrast this method with #prepend, which puts the Hook at
	#  the top of the stack.
	# 
	def append_hook( hook=nil, &block )
		hook = Hook.new( &block ) if block_given?
		@hooks = @hooks | [hook]
		return hook
	end

	#  call-seq:
	#    prepend_hook( hook )  ->  hook
	#    prepend_hook( &block )  ->  hook
	# 
	#  Exactly like #append_hook, except that the Hook is put at the
	#  top of the stack (it will be handled first).
	#  If the EventHandler already has that hook, it is moved to the top.
	# 
	def prepend_hook( hook )
		hook = Hook.new( &block ) if block_given?
		@hooks = [hook] | @hooks
		return hook
	end
	
	#  call-seq:
	#    remove_hook( *hooks )  ->  removed_hooks
	# 
	#  Remove one or more hooks from the EventHandler. Safe to use even
	#  if the EventHandler does not include some of the given hooks.
	# 
	#  *hooks::   the hooks to remove. (Hooks, required) 
	# 
	#  Returns::  the hooks that were found and removed by this operation.
	#             (Array of Hooks)
	# 
	def remove_hook( *hooks )
		overlap = @hooks & hooks
		@hooks -= hooks
		return overlap
	end

	#  call-seq:
	#    handle( event )  ->  nil
	#  
	#  Triggers every hook in the stack which matches the given event.
	#  See Hook.
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
