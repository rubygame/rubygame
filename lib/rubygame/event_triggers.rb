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



# This module contains all the event trigger classes that
# come with Rubygame. 
# 
# An event trigger class is simply a class which can be
# used as a trigger an EventHook. The trigger is used to
# determine whether the EventHook matches a particular
# event that occurs.
#
# The only requirement for an event trigger is this:
# 
# * It must have a #match? method which takes exactly one
#   argument (an event) and always returns either true or
#   false.
# 
# You can make your own custom event trigger classes and
# use them in an EventHook if they meet that requirement.
#
# NOTE: The #match? method may be called many times every
# second, even if there is no matching event. So, you should
# try to keep the method simple and fast, to have the least
# impact on your game's framerate.
# 
# Here is an overview of the event trigger classes that
# come with Rubygame as of version 2.5:
# 
# 
# AndTrigger::          Holds multiple other triggers, and
#                       matches if ALL of the triggers
#                       match the event.
# 
# OrTrigger::           Holds multiple other triggers, and
#                       matches if ONE OR MORE of the
#                       triggers match the event.
# 
# AttrTrigger::         Matches if the event's attributes
#                       have the expected values.
# 
# BlockTrigger::        Passes the event to a custom code
#                       block to check whether it matches.
# 
# InstanceOfTrigger::   Matches if the event is an
#                       instance of a particular class.
# 
# KeyPressTrigger::     Matches certain KeyPressed events.
# 
# KeyReleaseTrigger::   Matches certain KeyReleased events.
# 
# KindOfTrigger::       Matches if the event is #kind_of? a
#                       particular class or module.
# 
# MousePressTrigger::   Matches certain MousePressed events.
# 
# MouseMoveTrigger::    Matches certain MouseMoved events.
# 
# MouseReleaseTrigger:: Matches certain MouseReleased events.
# 
# TickTrigger::         Matches ClockTicked events.
# 
# YesTrigger::          Matches every event, no matter what.
# 
module Rubygame::EventTriggers

# 
# AndTrigger is an event trigger which contains one or
# more other triggers, and fires when an event matches
# all of its triggers. You can use this to create more
# complex logic than is possible with a single trigger.
#
# Contrast with OrTrigger.
# 
class AndTrigger

	# Initialize a new instance of AndTrigger, containing
	# the given triggers.
	# 
	# \*triggers:: The triggers to contain.
	#              (Array of triggers, required)
	# 
	# Example:
	#   
	#   gameover_trigger = InstanceOfTrigger.new( GameOver )
	#   won_trigger = AttrTrigger.new( :won_game => true )
	# 
	#   # Matches only an event which is BOTH:
	#   #  1. an instance of class GameOver, AND
	#   #  2. returns true when #won_game is called
	#   AndTrigger.new( gameover_trigger, won_trigger )
	# 
	def initialize( *triggers )
		@triggers = triggers
	end
	
	# Returns true if the event matches all the triggers
	# that the AndTrigger contains.
	# 
	def match?( event )
		@triggers.all? { |trigger| trigger.match? event }
	end
end



# 
# OrTrigger is an event trigger which contains one or
# more other triggers, and fires when an event matches
# one or more of its triggers.
# 
# Contrast with AndTrigger.
# 
class OrTrigger

	# Initialize a new instance of OrTrigger, containing
	# the given triggers.
	# 
	# \*triggers:: The triggers to contain.
	#              (Array of triggers, required)
	# 
	# Example:
	#   
	#   is_red = AttrTrigger.new( :color => :red )
	#   is_blue = AttrTrigger.new( :color => :blue )
	# 
	#   # Matches only an event which has EITHER:
	#   #  1. #color == :red, OR
	#   #  2. #color == :blue
	#   is_red_or_blue = OrTrigger.new( is_red, is_blue )
	# 
	# 
	#   # More complex example with nested logic triggers:
	#   
	#   changed = InstanceOfTrigger.new( ColorChanged )
	# 
	#   changed_to_red_or_blue = 
	#     AndTrigger.new( changed, is_red_or_blue )
	# 
	def initialize( *triggers )
		@triggers = triggers
	end
	
	# Returns true if the event matches one or more of 
	# the triggers that the OrTrigger contains.
	# 
	def match?( event )
		@triggers.any? { |trigger| trigger.match? event }
	end
end



# 
# AttrTrigger is an event trigger which fires when an event
# has the expected value(s) for one or more attributes.
# 
# AttrTrigger stores a Hash of :attr => value pairs, and
# checks each event to see if event.attr returns value.
# If all attributes have the expected value, the trigger fires.
# 
class AttrTrigger

	# Initialize a new instance of AttrTrigger with a
	# Hash of one or more :attr => value pairs.
	# 
	# attributes:: The attributes / value pairs to check.
	#              (Hash, required)
	# 
	# Example:
	# 
	#   # Matches if event.color returns :red and
	#   # event.size returns :big
	#   AttrTrigger.new( :color => :red, :size => :big )
	# 
	def initialize( attributes )
		@attributes = attributes
	end

	# Returns true if, for every :attr => value pair, the event
	# responds to :attr and calling event.attr returns value.
	# 
	# Returns false if any of the attributes is not the expected value.
	# 
	def match?( event )
		@attributes.all? { |key, value|
			event.respond_to?(key) and (event.send(key) == value)
		}
	end
end



# 
# BlockTrigger is an event trigger which calls a block 
# to check events. The trigger fires if the block returns
# true when called with the event as the only parameter.
# 
class BlockTrigger

	# Initialize a new instance of BlockTrigger with the given
	# block. The block should take only 1 parameter, the event,
	# and return true for matching events.
	# 
	# &block:: The block to pass events to. (Proc, required)
	# 
	def initialize( &block )
		raise ArgumentError, "BlockTrigger needs a block" unless block_given?
		@block = block
	end
	
	# Returns true if the block returns true when called 
	# with the event as the only parameter.
	# 
	def match?( event )
		@block.call( event ) == true
	end
end



# class CollisionTrigger
#
# 	# type can be :start, :hold, :end, or :any
# 	def initialize( a=:any, b=:any, type=:any )
# 		@a, @b, @type = a, b, type
# 	end
#	
# 	def match?( event )
# 		matching_types =
# 			case( event )
# 			when CollisionStartEvent
# 				[:start, :any]
# 			when CollisionEvent
# 				[:hold, :any]
# 			when CollisionEndEvent
# 				[:end, :any]
# 			else
# 				[]
# 			end
#		
# 		matching_types.include?(@type) and _has_objects?( event )
# 	end
#	
# 	private
#
# 	# True if the event concerns the object(s) this trigger
# 	# is watching. It's not important that the event's pair order
# 	# matches the trigger's pair order.
# 	def _has_objects?( event )
# 		obs = [event.a, event.a.sprite, event.b, event.b.sprite]
#		
# 		(@a == :any  or  obs.include?(@a)) and \
# 		(@b == :any  or  obs.include?(@b))
# 	end
#end



# 
# InstanceOfTrigger is an event trigger which fires when
# the event is an instance of the given class. (In other
# words, when event.instance_of?( klass ) is true.)
# 
# Contrast with KindOfTrigger.
# 
class InstanceOfTrigger

	# Initialize a new instance of InstanceOfTrigger with the
	# given class.
	# 
	# klass:: The class to check for. (Class, required)
	# 
	def initialize( klass )
		@klass = klass
	end
	
	# Returns true if the event is an instance of the class.
	# 
	def match?( event )
		event.instance_of?( @klass )
	end
end



# 
# KeyPressTrigger is an event trigger which fires when
# a key on the keyboard is pressed down (i.e. KeyPressed).
# See also KeyReleaseTrigger.
# 
# This trigger can be configured to fire for any key,
# or a specific key. It can also fire depending on which
# modifier keys are held (ctrl, shift, alt, etc.).
# 
# NOTE: This trigger only works with the new-style KeyPressed
# event class, not with the older KeyDownEvent.
# See EventQueue#enable_new_style_events
# 
class KeyPressTrigger

	# Initialize a new instance of KeyPressTrigger with the
	# given key and modifier keys.
	# 
	# key::   the key symbol to detect, or :any (default)
	#         to detect any key. (Symbol, optional)
	# 
	# mods::  an Array of one or more modifier key symbols, or
	#         :none to detect key presses with exactly no modifiers,
	#         or :any (default) to detect any key modifiers.
	# 
	#         Valid modifiers are: 
	#         * :alt,   :left_alt,   :right_alt,
	#         * :ctrl,  :left_ctrl,  :right_ctrl,
	#         * :shift, :left_shift, :right_shift,
	#         * :meta,  :left_meta,  :right_meta,
	#         * :numlock
	#         * :capslock
	#         * :mode
	# 
	#         :alt, :ctrl, :shift, and :meta will match either the
	#         left version or right version (e.g. :left_alt or
	#         :right_alt).
	# 
	# Example:
	# 
	#   # Matches any key press, regardless of the key or modifiers.
	#   KeyPressTrigger.new
	# 
	#   # Matches the 'A' key with any (or no) modifiers.
	#   KeyPressTrigger.new( :a )
	# 
	#   # Matches the 'A' with both Ctrl and Shift modifiers.
	#   KeyPressTrigger.new( :a, [:ctrl, :shift] )
	# 
	#   # Matches the 'A' with both Left Ctrl and Left Shift modifiers.
	#   KeyPressTrigger.new( :a, [:left_ctrl, :left_shift] )
	# 
	# 
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	# Returns true if the event is a KeyPressed event and the event's
	# key and mods BOTH match the trigger's expectations.
	# 
	# Key matches if either of these is true:
	# * the trigger's key is the symbol :any
	# * the event's key is the same as the trigger's key
	#
	# Modifiers matches if any of these is true: 
	# * the trigger's @mods is the symbol :any
	# * the event has no modifiers and the trigger's @mods is
	#   the symbol :none
	# * every one of the trigger's @mods matches one of the event's
	#   modifiers. "Matches" means either it is the same symbol,
	#   or it is a more general version. For example, :alt will 
	#   match either :left_alt or :right_alt.
	#
	def match?( event )
		if event.kind_of?( Rubygame::Events::KeyPressed )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.modifiers == [])\
			                 or (_mods_match?(event.modifiers)))
		end
	end


	private

	# True if every modifier in @mods matches a modifier in
	# evmods. :alt, :ctrl, :meta, and :shift match either
	# the left or right versions (e.g. :left_alt, :right_alt).
	# All other symbols match themselves.
	# 
	def _mods_match?( evmods )    # :nodoc:
		@mods.all? { |mod|
			case mod
			when :alt, :ctrl, :meta, :shift
				evmods.include?("left_#{mod}".intern) or
					evmods.include?("right_#{mod}".intern)
			else
				evmods.include?(mod)
			end
		}
	end

end



# 
# KeyReleaseTrigger is an event trigger which fires when
# a key on the keyboard is released (i.e. KeyReleased).
# 
# NOTE: This trigger is identical to KeyPressTrigger, except that
# it fires for KeyReleased instead of KeyPressed. Please
# see the documentation for KeyPressTrigger for info about
# the parameters and behavior of the trigger.
# 
# NOTE: This trigger only works with the new-style KeyReleased
# event class, not with the older KeyUpEvent.
# See EventQueue#enable_new_style_events
# 
class KeyReleaseTrigger

	# Initialize a new instance of KeyReleaseTrigger with the
	# given key and modifier keys.
	# 
	# See KeyPressTrigger#new for more information and examples.
	# 
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	# Returns true if the event is a KeyReleased event and the event's
	# key and mods BOTH match the trigger's expectations.
	# 
	# See KeyPressTrigger#match? for more information.
	# 
	def match?( event )
		if event.kind_of?( Rubygame::Events::KeyReleased )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.modifiers == [])\
			                 or (_mods_match?(event.modifiers)))
		end
	end


	private

	# True if every modifier in @mods matches a modifier in
	# evmods. :alt, :ctrl, :meta, and :shift match either
	# the left or right versions (e.g. :left_alt, :right_alt).
	# All other symbols match themselves.
	# 
	def _mods_match?( evmods )    # :nodoc:
		@mods.all? { |mod|
			case mod
			when :alt, :ctrl, :meta, :shift
				evmods.include?("left_#{mod}".intern) or
					evmods.include?("right_#{mod}".intern)
			else
				evmods.include?(mod)
			end
		}
	end


end



# 
# KindOfTrigger is an event trigger which fires when
# the event is kind of the given class or module. 
# (In other words, when event.kind_of?( kind ) is
# true.)
# 
# Contrast with InstanceOfTrigger.
# 
class KindOfTrigger

	# Initialize a new instance of KindOfTrigger with the
	# given class or module.
	# 
	# kind:: The class/module to check for.
	#        (Class or Module, required)
	# 
	def initialize( kind )
		@kind = kind
	end
	
	# Returns true if the event is kind of the class/module.
	# 
	def match?( event )
		event.kind_of?( @kind )
	end
end



# 
# MousePressTrigger is an event trigger which fires when
# a mouse button is pressed down (i.e. MousePressed).
# 
# By default, this trigger fires for any mouse press, but
# it can be configured to fire for only a specific mouse 
# button by passing a button symbol to #new.
# 
# See also MousReleaseTrigger.
# 
class MousePressTrigger

  
	# Initialize a new instance of MousePressTrigger with
	# the given mouse button.
	# 
	# button:: The mouse button symbol to detect, or :any
	#          to detect any button press.
	# 
	#          Valid mouse button symbols are: :mouse_left,
	#          :mouse_middle, :mouse_right, :mouse_wheel_up,
	#          and :mouse_wheel_down.
	# 
	def initialize( button=:any )
		@button = button
	end
	
	# Returns true if the event is a MousePressed event and
	# the event's button is the same as the trigger's button
	# (or the trigger's button is :any).
	# 
	def match?( event )
		if event.kind_of?( Rubygame::Events::MousePressed )
			((@button == :any) or (event.button == @button))
		else
			false
		end
	end
end



# 
# MouseMoveTrigger is an event trigger which fires when the
# mouse cursor is moved (MouseMoved). If buttons are given,
# it only matches events with those buttons. See #new for details.
# 
class MouseMoveTrigger

	# 
	# Create a new instance of MouseMoveTrigger.
	# 
	# The buttons parameter determines which mouse buttons can
	# be held down and still match this trigger. It can be one of:
	# 
	# 1. +:any+. Matches if zero or more buttons are held.
	# 2. +:none+. Matches when zero buttons are being held.
	# 3. +:mouse_left+, etc. Matches when at least the given 
	#    button is being held.
	# 4. An array of +:mouse_*+ symbols. Matches when exactly all
	#    buttons in the Array are being held, and nothing else.
	# 
	# 
	# Example:
	# 
	#    # Matches all MouseMoved events, regardless of buttons:
	#    MouseMoveTrigger.new()
	#    MouseMoveTrigger.new( :any )
	#    
	#    
	#    # Matches only if no buttons pressed:
	#    MouseMoveTrigger.new( :none )
	#    MouseMoveTrigger.new( [] )
	#    
	#    
	#    # Matches if left mouse is held down, maybe with others:
	#    MouseMoveTrigger.new( :mouse_left )
	#    
	#    
	#    # Matches if ONLY left mouse held down, nothing else:
	#    MouseMoveTrigger.new( [:mouse_left] )
	#    
	#    
	#    # Matches if BOTH left AND right mouse are held down, nothing else:
	#    MouseMoveTrigger.new( [:mouse_left, :mouse_right] )
	#    
	#    
	#    # Matches if EITHER left OR right mouse are held down:
	#    OrTrigger.new( MouseMoveTrigger.new(:mouse_left),
	#                   MouseMoveTrigger.new(:mouse_right) )
	# 
	# 
	def initialize( buttons=:any )
		@buttons = buttons
	end
	
	# 
	# Returns true if the given event matches this trigger.
	# See #new for information about how events match.
	# 
	def match?( event )
		if event.kind_of?( Rubygame::Events::MouseMoved )
			((@buttons == :any) or 
			 (@buttons == :none and event.buttons == []) or 
			 (_buttons_match?(event.buttons)) or
			 (event.buttons.include?(@buttons)))
		else
			false
		end
	end

  private

  # Returns true if evbuttons is the same as @buttons,
  # ignoring the order of the symbols.
  # 
  def _buttons_match?( evbuttons )
    if( @buttons.kind_of? Symbol )
      return false
    end

    e = evbuttons.sort_by { |button|  button.to_s }
    t = @buttons.sort_by  { |button|  button.to_s }
    return (e == t)
  end

end



# 
# MouseReleaseTrigger is an event trigger which fires when
# a mouse button is released (i.e. MouseReleased).
# 
# By default, this trigger fires for any mouse release, but
# it can be configured to fire for only a specific mouse 
# button by passing a button symbol to #new.
# 
# See also MousePressTrigger.
# 
class MouseReleaseTrigger

	# Initialize a new instance of MouseReleaseTrigger with
	# the given mouse button.
	# 
	# button:: The mouse button symbol to detect, or :any
	#          to detect any button press.
	# 
	#          Valid mouse button symbols are: :mouse_left,
	#          :mouse_middle, :mouse_right, :mouse_wheel_up,
	#          and :mouse_wheel_down.
	# 
	def initialize( button=:any )
		@button = button
	end
	
	# Returns true if the event is a MouseReleased event and
	# the event's button is the same as the trigger's button
	# (or the trigger's button is :any).
	# 
	def match?( event )
		if event.kind_of?( Rubygame::Events::MouseReleased )
			((@button == :any) or (event.button == @button))
		else
			false
		end
	end
end



# 
# TickTrigger is an event trigger which will fire
# when the Clock ticks (ClockTicked).
# 
class TickTrigger

	# Returns true if the event is a ClockTicked event.
	def match?( event )
		event.kind_of?( Rubygame::Events::ClockTicked )
	end
end



#
# YesTrigger is an event trigger which will fire
# when any event occurs, regardless of the event
# type or details.
# 
class YesTrigger

	# Returns true every time.
	def match?( event )
		true
	end
end

end
