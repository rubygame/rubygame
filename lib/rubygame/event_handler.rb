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

class Rubygame::EventHandler

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



# HasEventHandler is a mixin module to conveniently integrate
# EventHandler into any class, allowing instances of the class
# to hold event hooks and handle incoming events.
# 
# To use HasEventHandler, you simply 'include' it in your class,
# and call 'super' from initialize. Example:
# 
#    class Player
#      include Rubygame::EventHandler::HasEventHandler
#      
#      def initialize()
#        # creates @event_handler if it doesn't exist already
#        super
#
#        # The rest of your initialization code...
#      end
#      
#      # The rest of your class definition...
#      
#    end
# 
# You can then use all of the functionality of HasEventHandler.
# 
# HasEventHandler provides several methods for adding new
# event hooks to the object. The two basic methods for that are 
# #append_hook and #prepend_hook. The #magic_hooks method can
# create multiple hooks very simply and conveniently.
# 
# HasEventHandler also defines the #handle method, which accepts
# an event and gives it to the object's event handler. This is
# the recommended way to make the object process an event.
# 
module Rubygame::EventHandler::HasEventHandler

	def initialize( *args )
		# Try super with the given arguments, but rescue if it fails.
		super
	rescue ArgumentError
		# do nothing
	ensure
		@event_handler = EventHandler.new() unless defined?( @event_handler )
	end
	

	# Appends a new hook to the end of the list. If the hook does
	# not have an owner, the owner is set to this object before
	# appending.
	# 
	# hook:: the hook to append. 
	#        (EventHook or Hash description, required)
	# 
	# See also EventHandler#append_hook.
	# 
	# Example:
	# 
	#   # Create and append new hook from a description:
	#   trigger = KeyPressedTrigger.new(:space)
	#   action  = MethodAction.new(:jump)
	#   player.append_hook( :trigger => trigger, :action  => action )
	# 
	#   # You can also give it an EventHook instance, if you want.
	#   hook = EventHook.new( :trigger => trigger, :action => action )
	#   player.append_hook( hook )
	# 
	def append_hook( hook )
		hook = _prepare_hook( hook )
		@event_handler.append_hook( hook )
	end
	
	# Passes the given event to the object's event handler.
	def handle( event )
		@event_handler.handle( event )
	end
	
	def magic_hooks( hash )
		hash.each_pair do |trigger, action|
			
			hook = {}
			
			case trigger
			when Symbol
				case(trigger.to_s)
				when /mouse/
					hook[:trigger] = MouseClickTrigger.new(trigger)
				else
					hook[:trigger] = KeyPressTrigger.new(trigger)
				end
			when Class
				hook[:trigger] = InstanceOfTrigger.new(trigger)
			end
			
			case action
			when Symbol
				hook[:action] = MethodAction.new(action,true)
			when Proc, Method
				hook[:action] = BlockAction.new(&action)
			end
			
			append_hook( hook )
			
		end
		nil
	end

	# Exactly like #append_hook, except that the hook is put at the
	# top of the stack (it will be handled first).
	# 
	# See also EventHandler#prepend_hook.
	# 
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
