#--
#
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2009  John Croisant
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


require "rubygame/event_hook"


# EventHandler provides a simple, extensible system for
# hook-based event handling.
# 
# An EventHandler holds a list of EventHook objects. When
# the EventHandler receives a new event (passed to #handle),
# it tests the event against each EventHook. If the event
# matches the EventHook, the EventHandler passes the event to
# the EventHook to perform an action (such as calling a
# method or executing a block).
# 
# Although the EventHandler and EventHook classes are very
# simple in themselves, they can be used as building blocks
# to create flexible and complex systems, whatever is needed
# by your application.
# 
# Here are a few ways you could use EventHandler:
# 
# * One central EventHandler with EventHooks to perform
#   all types of actions. This is good for simple apps.
# 
# * Multiple EventHandlers, one for each category of
#   event. For example, one for keyboard input, one for
#   mouse input, one for game logic events, etc.
# 
# * An EventHandler in every game object (using the 
#   HasEventHandler mixin module), being fed events from
#   a central EventHandler.
# 
# You can also extend the possibilities of EventHandler and
# EventHook by creating your own event trigger and action
# classes. See EventHook for more information.
# 
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
		hook = Rubygame::EventHook.new( hook ) if hook.kind_of?( Hash )
		@hooks = (@hooks - [hook]) | [hook]
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
		hook = Rubygame::EventHook.new( hook ) if hook.kind_of?( Hash )
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

	#  Returns true if the given EventHook instance is on the stack.
	def has_hook?( hook )
		@hooks.include?( hook )
	end

	#  Removes the given EventHook instance from the stack, if it exists
	#  on the stack.
	# 
	#  Returns:: the hook that was removed, or nil if the hook did not
	#            exist on the stack.
	#  
	#  NOTE: You must pass the exact EventHook instance to remove it!
	#  Passing another EventHook that is "similar" will not work.
	#  So, you should store a reference to the hook when it is returned
	#  by #append_hook or #prepend_hook.
	# 
	def remove_hook( hook )
		@hooks.delete( hook )
	end

end



# HasEventHandler is a mixin module to conveniently integrate
# EventHandler into any class, allowing instances of the class
# to hold event hooks and handle incoming events.
# 
# To use HasEventHandler, you simply 'include' it in your class:
# 
#    class Player
#      include Rubygame::EventHandler::HasEventHandler
# 
#      # ... the rest of your class ...
# 
#    end
# 
# You can then use all of the functionality of HasEventHandler.
# 
# HasEventHandler provides several methods for adding new
# event hooks to the object. The two basic methods for that are 
# #append_hook and #prepend_hook. The #make_magic_hooks method can
# create multiple hooks very simply and conveniently.
# 
# HasEventHandler also defines the #handle method, which accepts
# an event and gives it to the object's event handler. This is
# the recommended way to make the object process an event.
# 
module Rubygame::EventHandler::HasEventHandler

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
		_make_event_handler if @event_handler.nil?
		hook = _prepare_hook( hook )
		@event_handler.append_hook( hook )
	end
	
	# Passes the given event to the object's event handler.
	def handle( event )
		_make_event_handler if @event_handler.nil?
		@event_handler.handle( event )
	end
	
	# Returns true if the object's event handler includes the given
	# EventHook instance. 
	def has_hook?( hook )
		_make_event_handler if @event_handler.nil?
		@event_handler.has_hook?( hook )
	end


	# Convenience method for creating and appending hooks easily.
	# It takes a Hash of {trigger_seed => action_seed} pairs, and
	# creates and appends a new EventHook for each pair.
	# 
	# Returns:: an Array of the EventHook instances that were
	#           created and appended.
	# 
	# May raise::  ArgumentError, if an object doesn't match any
	#              conversion rules.
	# 
	# Trigger and action can be symbols, classes, or other types of
	# object. The method uses simple rules to convert the "seed"
	# objects into appropriate event triggers or event actions.
	# 
	# By default, triggers are converted according to these rules:
	# 
	#   * Symbols starting with "mouse" become a MouseClickTrigger.
	#   * The symbol :tick becomes a TickTrigger. (Rubygame 2.5+)
	#   * Keyboard symbols become a KeyPressTrigger.
	#   * Classes become an InstanceOfTrigger.
	#   * Objects with a #match? method are duplicated and used
	#     as the trigger without being converted.
	# 
	# By default, actions are converted according to these rules:
	# 
	#   * Symbols become a MethodAction.
	#   * Proc and Method instances become a BlockAction.
	#   * Objects with a #perform method are duplicated and used
	#     as the action without being converted.
	# 
	# This method raises ArgumentError if an object doesn't match
	# any of the conversion rules.
	# 
	# You can define your own custom conversion rules by overriding
	# the private methods #_make_magic_trigger and #make_magic_action
	# in your class.
	# 
	# NOTE: Additional default rules may be added in the future, but
	# objects which match the existing rules will continue to match
	# them. However, objects which are invalid in one version might
	# become valid in future versions, if a new rule is added. So, you
	# should never depend on ArgumentError being raised for a paricular
	# object!
	# 
	# Example:
	# 
	#   died_action = proc { |owner, event| 
	#     owner.say "Blargh, I'm dead!" if event.who_died == owner
	#   }
	# 
	#   player.make_magic_hooks( :space      => :jump,
	#                            :left       => :move_left,
	#                            :right      => :move_right,
	#                            :mouse_left => :shoot,
	#                            DiedEvent   => died_action )
	# 
	def make_magic_hooks( hooks_hash )
		hooks_hash.collect do |trigger, action|
			append_hook( :trigger => _make_magic_trigger( trigger ),
									 :action  => _make_magic_action(  action  ))
		end
	end


  # Exactly like #make_magic_hooks, but the hooks' owner will be the
  # given object, instead of self. See EventHook for more information
  # about hook owners.
  # 
  def make_magic_hooks_for( owner, hooks_hash )
    hooks_hash.collect do |trigger, action|
      append_hook( :owner   => owner,
                   :trigger => _make_magic_trigger( trigger ),
                   :action  => _make_magic_action(  action  ) )
    end
  end


	# Exactly like #append_hook, except that the hook is put at the
	# top of the stack (it will be handled first).
	# 
	# See also EventHandler#prepend_hook.
	# 
	def prepend_hook( hook )
		_make_event_handler if @event_handler.nil?
		hook = _prepare_hook( hook )
		@event_handler.prepend_hook( hook )
	end
	
	# Remove the given EventHook instance from the stack, if it
	# exists on the stack.
	# See EventHandler#remove_hook for details and restrictions.
	# 
	# Returns:: the hook that was removed, or nil if the hook did not
	#           exist on the stack.
	# 
	def remove_hook( hook )
		_make_event_handler if @event_handler.nil?
		@event_handler.remove_hook( hook )
	end

	private

	# Sets @event_handler to a new EventHandler if needed.
	def _make_event_handler
		@event_handler = Rubygame::EventHandler.new() if @event_handler.nil?
	end

	# This method is called by #make_magic_hooks to convert an
	# object into an event action instance. For example, when
	# this method is given a Proc, it creates and returns a
	# BlockAction using that Proc. See #make_magic_hooks for
	# information about how other objects are converted.
	# 
	# You can override this method in your own classes to
	# define your own custom conversion rules. Example:
	# 
	#   class Player
	#     include Rubygame::EventHandler::HasEventHandler
	# 
	#     private
	# 
	#     def _make_magic_action( action )
	#       if( action == :move_left )
	#         return BlockAction.new { |owner, event|
	#           owner.move_by( [-1, 0] )
	#         }
	#       else
	#         super
	#       end
	#     end
	# 
	#   end
	# 
	# 
	# Returns::    an event action instance
	# 
	# May raise::  ArgumentError, if the given object does not
	#              match any of the conversion rules.
	# 
	def _make_magic_action( action )
		case action

		when Symbol
			Rubygame::EventActions::MethodAction.new(action)

		when Proc, Method
			Rubygame::EventActions::BlockAction.new(&action)

		else
			if action.respond_to? :perform
				action.dup
			else
				raise( ArgumentError, 
				       "invalid action '#{action.inspect}'. " +\
				       "See HasEventHandler#make_magic_hooks docs for " +\
				       "allowed action types." )
			end
		end
	end


	# This method is called by #make_magic_hooks to convert an
	# object into an event trigger instance. For example, when
	# this method is given the symbol :mouse_left, it creates
	# and returns a MousePressTrigger that matches :mouse_left.
	# See #make_magic_hooks for information about how other objects
	# are converted.
	# 
	# You can override this method in your own classes to
	# define your own custom conversion rules. Example:
	# 
	#   class Player
	#     include Rubygame::EventHandler::HasEventHandler
	# 
	#     private
	# 
	#     def _make_magic_trigger( trigger )
	#       if( trigger == :game_over )
	#         return GameOverTrigger.new()
	#       else
	#         super
	#       end
	#     end
	# 
	#   end
	# 
	# 
	# Returns::    an event trigger instance
	# 
	# May raise::  ArgumentError, if the given object does not
	#              match any of the conversion rules.
	# 
	def _make_magic_trigger( trigger )
		case trigger

		when Symbol
			case(trigger.to_s)
			when /mouse/
				Rubygame::EventTriggers::MousePressTrigger.new(trigger)
			when "tick"
				Rubygame::EventTriggers::TickTrigger.new
			else
				Rubygame::EventTriggers::KeyPressTrigger.new(trigger)
			end

		when Class
			Rubygame::EventTriggers::InstanceOfTrigger.new(trigger)

		else
			if trigger.respond_to? :match?
				trigger.dup
			else
				raise( ArgumentError, 
				       "invalid trigger '#{trigger.inspect}'. " +\
				       "See HasEventHandler#make_magic_hooks docs for " +\
				       "allowed trigger types." )
			end
		end
	end
	

	def _prepare_hook( hook )
		if( hook.kind_of? Hash )
			hook = Rubygame::EventHook.new( {:owner => self}.merge(hook) )
		end
		
		if( hook.owner == nil )
			hook = hook.dup
			hook.owner = self
		end
		
		return hook
	end
end
