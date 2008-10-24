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


# This module contains all the event action classes that
# come with Rubygame. 
# 
# An event action class is simply a class which can be
# used as an action an EventHook. The action is used to
# cause some effect when the EventHook matches an event.
#
# The only requirement for an event action is this:
# 
# * It must have a #perform method which takes exactly two
#   arguments (the hook owner and an event). Return values
#   are ignored.
# 
# You can make your own custom event action classes and
# use them in an EventHook if they meet that requirement.
#
# Here is an overview of the event action classes that
# come with Rubygame as of version 2.4:
# 
# BlockAction::  Calls a custom code block, passing it the
#                hook owner and the event.
# 
# MethodAction:: Calls one of the owner's methods, passing
#                it the event.
# 
# MultiAction::  Holds multiple other actions and performs
#                each of them, in order.
# 
module Rubygame::EventActions


# BlockAction is an event action used with EventHook. BlockAction
# takes a code block at initialization. When the action is performed,
# it executes the block, passing in the EventHook#owner and the event
# that is being handled as the two parameters to the block.
# 
# Example:
# 
#   hit_by_missile = KindOfTrigger.new( MissileCollisionEvent )
# 
#   take_damage = BlockAction.new { |owner, event|
#     owner.health -= event.damage_amount
#   }
# 
#   hook = EventHook.new( :owner   => player_ship,
#                         :trigger => hit_by_missile,
#                         :action  => take_damage )
# 
# 
# NOTE: It is also possible to pass a Proc or detached Method
# as the block, using the standard Ruby syntax for that:
# 
#   # Using a pre-built Proc.
# 
#   my_proc = Proc.new { |owner, event| do_something() }
# 
#   BlockAction.new( &my_proc )
# 
# 
#   # Using a detached method.
# 
#   def a_method( owner, event )
#     do_something
#   end
# 
#   detached_method = method(:a_method)
# 
#   BlockAction.new( &detached_method )
# 
# 
class BlockAction

	# Create a new BlockAction using the given code block.
	# 
	# &block::     the code block to execute. Should take two parameters,
	#              owner and event. (Proc, required)
	# 
	# May raise::  ArgumentError, if no block is provided.
	# 
	def initialize( &block )
		raise ArgumentError, "BlockAction needs a block" unless block_given?
		@block = block
	end
	
	# Execute the code block, passing in owner and event as the two
	# parameters to the block. This is automatically called by EventHook
	# when an event matches the trigger. You should usually not call it
	# in your own code.
	# 
	# owner::  the owner of the EventHook, or nil if there is none.
	#          (Object, required)
	# event::  the event that matched the trigger. (Object, required)
	# 
	def perform( owner, event )
		@block.call( owner, event )
	end
end


# MethodAction is an event action used with EventHook.
# MethodAction takes a symbol giving the name of a method. When
# it is performed, it calls that method on the owner, passing
# it the event that triggered the hook.
# 
# Example:
# 
#   class Player
#     def aim_at( event )
#       self.crosshair_pos = event.pos
#     end
#   end
# 
#   player1 = Player.new
# 
#   EventHook.new( :owner   => player1,
#                  :trigger => MouseMoveTrigger.new(),
#                  :action  => MethodAction.new( :aim_at ) )
# 
class MethodAction

	# Create a new MethodAction using the given method name.
	# 
	# method_name::  the method to call when performing.
	#                (Symbol, required)
	# 
	def initialize( method_name )
		@method_name = method_name
	end


	# Call the method of the owner represented by @method_name,
	# passing in the event as the only argument.
	# 
	# If that causes ArgumentError (e.g. because the method doesn't
	# take an argument), calls again without any arguments.
	# 
	# If that also fails, this method re-raises the original error.
	# 
	def perform( owner, event )
		owner.method(@method_name).call( event )
	rescue ArgumentError => s
		begin
			# Oops! Try again, without any argument.
			owner.method(@method_name).call()
		rescue ArgumentError
			# That didn't work either. Raise the original error.
			raise s
		end
	end
end



# MultiAction is an event action used with EventHook.
# It takes zero or more actions (e.g. BlockAction or MethodAction
# instances) at initialization.
# 
# When MultiAction is performed, it performs all the given
# actions, in the order they were given, passing in the owner
# and event.
# 
# As the name suggests, you can use MultiAction to cause
# multiple actions to occur when an EventHook is triggered.
# 
class MultiAction

	# Create a new MultiAction instance with the given sub-actions.
	# 
	# *actions:: the actions to perform. (Action instances)
	# 
	def initialize( *actions )
		@actions = actions
	end
	
	# Performs all the sub-actions, in the order they were given,
	# passing in the owner and event to each one.
	# 
	def perform( owner, event )
		@actions.each { |action| action.perform( owner, event ) }
	end
end

end
