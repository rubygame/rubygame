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

	# 
	#  Takes either a Hook instance, or parameters to pass to Hook.new.
	#  Returns a Hook instance either way!
	# 
	def _return_or_create_hook( hook_or_owner, block ) # :nodoc:
		if hook_or_owner.kind_of?(Hook)
			return hook_or_owner
		else
			return Hook.new(hook_or_owner, &block )
		end			
	end
	private :_return_or_create_hook
	
	#  call-seq:
	#    append_hook( hook )  ->  hook
	#    append_hook( owner, &block )  ->  hook
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
	#  owner::    the new hook's owner. (Object, for second form only)
	#  block::    a block to initialize the hook. (Proc, for second form only)
	# 
	#  Returns::  the hook that was added. (Hook)
	# 
	#  Contrast this method with #prepend, which puts the Hook at
	#  the top of the stack.
	# 
	def append_hook( hook_or_owner, &block )
		hook = _return_or_create_hook( hook_or_owner, block )
		@hooks = @hooks | [hook]
		return hook
	end

	#  call-seq:
	#    prepend_hook( hook )  ->  hook
	#    prepend_hook( owner, &block )  ->  hook
	# 
	#  Exactly like #append_hook, except that the Hook is put at the
	#  top of the stack (it will be handled first).
	#  If the EventHandler already has that hook, it is moved to the top.
	# 
	def prepend_hook( hook_or_owner )
		hook = _return_or_create_hook( hook_or_owner, block )
		@hooks = [hook] | @hooks
		return hook
	end
	
	#  call-seq:
	#    remove_hook( hook )  ->  hook
	# 
	#  Remove a hook from the EventHandler, if that hook exists.
	#  If the EventHandler doesn't have that hook, this method will do nothing.
	# 
	#  hook::     the hook to remove. (Hook, required) 
	# 
	#  Returns::  the hook that was removed. (Hook)
	# 
	def remove_hook( hook )
		@hooks -= [hook]
		return hook
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
