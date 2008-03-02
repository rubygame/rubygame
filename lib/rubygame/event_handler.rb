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

require 'rubygame/event_hook'

module Rubygame

class EventHandler

	#  call-seq:
	#    EventHandler.new { |handler| ... }  ->  new_handler
	# 
	#  Create a new EventHandler. The optional block can be used
	#  for further initializing the EventHandler.
	# 
	def initialize(&block)
		@hooks = []
		yield self if block_given?
	end

	attr_accessor :hooks
	
	#  call-seq:
	#    append_hook( hook )  ->  hook
	#    append_hook( description )  ->  hook
	# 
	#  Puts an EventHook at the bottom of the stack (it will be handled last).
	#  If the EventHandler already has that hook, it is moved to the bottom.
	#  See EventHook and #handle. 
	# 
	#  This method has two distinct forms. The first form adds an existing Hook
	#  instance; the second form constructs a new EventHook instance and adds it.
	# 
	#  hook::        the hook to add. (EventHook, for first form only)
	# 
	#  description:: a Hash to initialize a new EventHook.
	#                (Hash, for second form only)
	# 
	#  Returns::  the hook that was added. (EventHook)
	# 
	#  Contrast this method with #prepend, which puts the EventHook at
	#  the top of the stack.
	# 
	def append_hook( hook )
		hook = EventHook.new( hook ) if hook.kind_of?( Hash )
		@hooks = @hooks | [hook]
		return hook
	end

	#  call-seq:
	#    prepend_hook( hook )  ->  hook
	#    prepend_hook( description )  ->  hook
	# 
	#  Exactly like #append_hook, except that the EventHook is put at the
	#  top of the stack (it will be handled first).
	#  If the EventHandler already has that hook, it is moved to the top.
	# 
	def prepend_hook( hook )
		hook = EventHook.new( hook ) if hook.kind_of?( Hash )
		@hooks = [hook] | @hooks
		return hook
	end
	
	#  call-seq:
	#    handle( event )  ->  nil
	#  
	#  Triggers every hook in the stack which matches the given event.
	#  See EventHook.
	# 
	#  If one of the matching hooks has @consumes enabled, no hooks
	#  after it will receive that event. (Example use: a mouse click that
	#  only affects the top-most object it hits, not any below it.)
	#  
	#  event:     the event to handle. (Object, required)
	# 
	#  Returns::  nil.
	# 
	def handle( event )
		matching_hooks = @hooks.select { |hook| hook.match?( event ) }
		
		catch :event_consumed do
			matching_hooks.each do |hook|
				hook.perform( event )
				throw :event_consumed if hook.consumes
			end
		end
			
		return nil
	end	
end

module HasEventHandler
	def append_hook( hook )
		hook = _prepare_hook( hook )
		@event_handler.append_hook( hook )
	end
	
	def handle( event )
		@event_handler.handle( event )
	end
	
	def magic_hooks( hash )
		hash.each_pair do |symbol, method|
			
			hook = { :action => MethodAction.new(method,true) }
			
			case(symbol.to_s)
			when /mouse/
				hook[:trigger] = MouseClickTrigger.new(symbol)
			else
				hook[:trigger] = KeyPressTrigger.new(symbol)
			end
			
			append_hook( hook )
			
		end
		nil
	end
	
	def prepend_hook( hook )
		hook = _prepare_hook( hook )
		@event_handler.prepend_hook( hook )
	end
	
	private
	
	def _prepare_hook( hook )
		if( hook.kind_of? Hash )
			hook = EventHook.new( {:owner => self}.merge(hook) )
		end
		
		if( hook.owner == nil )
			hook = hook.dup
			hook.owner = self
		end
		
		return hook
	end
end

end
