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

require 'rubygame'

module Rubygame


class AllTrigger
	def initialize( *triggers )
		@triggers = triggers
	end
	
	def match?( event )
		@triggers.all? { |trigger| trigger.match? event }
	end
end



class AnyTrigger
	def initialize( *triggers )
		@triggers = triggers
	end
	
	def match?( event )
		@triggers.any? { |trigger| trigger.match? event }
	end
end



class AttrTrigger
	def initialize( attributes )
		@attributes = attributes
	end
	
	def match?( event )
		@attributes.all? { |key, value|
			event.respond_to?(key) and (event.send(key) == value)
		}
	end
end



class BlockTrigger
	def initialize( &block )
		raise ArgumentError, "BlockTrigger needs a block" unless block_given?
		@block = block
	end
	
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



class InstanceOfTrigger
	def initialize( klass )
		@klass = klass
	end
	
	def match?( event )
		event.instance_of?( @klass )
	end
end



class KeyPressTrigger
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	def match?( event )
		if event.kind_of?( Events::KeyPressed )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.modifiers == [])\
			                 or (event.modifiers == @mods))
		end
	end
end



class KeyReleaseTrigger
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	def match?( event )
		if event.kind_of?( Events::KeyReleased )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.modifiers == [])\
			                 or (event.modifiers == @mods))
		end
	end
end



class KindOfTrigger
	def initialize( klass )
		@klass = klass
	end
	
	def match?( event )
		event.kind_of?( @klass )
	end
end



class MouseClickTrigger
	def initialize( button=:any )
		@button = button
	end
	
	def match?( event )
		if event.kind_of?( Events::MousePressed )
			((@button == :any) or (event.button == @button))
		else
			false
		end
	end
end



# 
# buttons can be:
# 
#  :any              - matches regardless of which buttons are held.
#  :none             - matches when zero buttons are being held.
#  :mouse_left, etc. - matches when at least the given button is being held.
#  [ ... ]           - matches when exactly all buttons in the Array 
#                      are being held, and nothing else.
# 
class MouseHoverTrigger
	def initialize( buttons=:any )
		@buttons = buttons
	end
	
	def match?( event )
		if event.kind_of?( Events::MouseMoved )
			((@buttons == :any) or 
			 (@buttons == :none and event.buttons == []) or 
			 (@buttons == event.buttons) or
			 (event.buttons.include?(@buttons)))
		else
			false
		end
	end
end



class MouseReleaseTrigger
	def initialize( button=:any )
		@button = button
	end
	
	def match?( event )
		if event.kind_of?( Events::MouseReleased )
			((@button == :any) or (event.button == @button))
		else
			false
		end
	end
end



# class TickTrigger
# 	def match?( event )
# 		event.kind_of?( Events::ClockTicked )
# 	end
# end



class YesTrigger
	def match?( event )
		true
	end
end

end
