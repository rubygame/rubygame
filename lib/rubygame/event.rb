#
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004  John 'jacius' Croisant
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

require "singleton" #used by Queue

# Table of Contents:
#
# ALL_EVENT_CLASSES -- a list of all the event classes
# key2str -- get display string for a key
#
# class Event
#
# class ActiveEvent
# class KeyDownEvent
# class KeyUpEvent
# class MouseMotionEvent
# class MouseDownEvent
# class MouseUpEvent
# class JoyAxisEvent
# class JoyBallEvent
# class JoyHatEvent
# class JoyDownEvent
# class JoyUpEvent
# class ResizeEvent
# class QuitEvent
#
# class Queue
#
# End Table of Contents

module Rubygame

	# List of all event classes.
	ALL_EVENT_CLASSES = [ActiveEvent, KeyDownEvent, KeyUpEvent,\
		MouseMotionEvent,MouseDownEvent,MouseUpEvent,JoyAxisEvent,\
		JoyBallEvent, JoyHatEvent,JoyDownEvent, JoyUpEvent,\
		ResizeEvent, QuitEvent]

	def Rubygame.key2str( sym, mods )
		if (mods.include? K_LSHIFT) or (mods.include? K_RSHIFT)
			str = Rubygame::Key::KEY2UPPER[sym]
		else
			str = Rubygame::Key::KEY2LOWER[sym]
		end

		#it will be nil if it was not in KEY2UPPER or KEY2LOWER
		if str == nil # last resort
			str = Rubygame::Key::KEY2ASCII[sym] 
		end

		# it will still be nil if it wasn't in KEY2ASCII either
		if str == nil
			return ""
		else
			return str
		end
	end

	class Event
	end

	class ActiveEvent < Event
		attr_accessor :gain, :state
		def initialize(gain,state)
			@gain = gain
			@state = state #"mouse", "keyboard", or "active"
		end
	end

	class KeyDownEvent < Event
		attr_accessor :string,:key,:mods
		def initialize(key,mods)
			if key.kind_of? Integer
				@key = key
				@string = Rubygame.key2str(key, mods) #a string or nil
			elsif key.kind_of? String
				@key = Rubygame::ASCII2KEY[key]
				if @key != nil
					@string = key
				else
					raise(ArgumentError,"First argument of KeyDownEvent.new() must be an Integer KeySym (like K_A) or a ASCII-like String (like \"a\" or \"A\"). Got %s (%s)"%[key,key.class])
				end
			end
			@mods = mods
		end
	end

	class KeyUpEvent < Event
		attr_accessor :string,:key,:mods
		def initialize(key,mods)
			if key.kind_of? Integer
				@key = key
				@string = Rubygame.key2str(key, mods) #a string or nil
			elsif key.kind_of? String
				@key = Rubygame::ASCII2KEY[key]
				if @key != nil
					@string = key
				else
					raise(ArgumentError,"First argument of KeyUpEvent.new() must be an Integer KeySym (like K_A) or a ASCII-like String (like \"a\" or \"A\"). Got %s (%s)"%[key,key.class])
				end
			end
			@mods = mods
		end
	end

	class MouseMotionEvent < Event
		attr_accessor :pos,:rel,:buttons
		def initialize(pos,rel,buttons)
			@pos, @rel, @buttons = pos, rel, buttons
		end
	end

	class MouseDownEvent < Event
		attr_accessor :string,:pos,:button
		def initialize(pos,button)
			@pos = pos
			if button.kind_of? Integer
				@button = button
				@string = Rubygame::Mouse::MOUSE2STR[button] #a string or nil
			elsif key.kind_of? String
				@button = Rubygame::Mouse::STR2MOUSE[key]
				if @button != nil
					@string = button
				else
					raise(ArgumentError,"First argument of MouseDownEvent.new() must be an Integer Mouse button indentifier (like MOUSE_LEFT) or a String (like \"left\"). Got %s (%s)"%[button,button.class])
				end
			end
		end
	end

	class MouseUpEvent < Event
		attr_accessor :string,:pos,:button
		def initialize(pos,button)
			@pos = pos
			if button.kind_of? Integer
				@button = button
				@string = Rubygame::Mouse::MOUSE2STR[button] #a string or nil
			elsif key.kind_of? String
				@button = Rubygame::Mouse::STR2MOUSE[key]
				if @button != nil
					@string = button
				else
					raise(ArgumentError,"First argument of MouseUpEvent.new() must be an Integer Mouse button indentifier (like MOUSE_LEFT) or a String (like \"left\"). Got %s (%s)"%[button,button.class])
				end
			end
		end
	end

	class JoyAxisEvent < Event
		attr_accessor :joynum,:axis,:value
		def initialize(joy,axis,value)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@axis, @value = axis, value
		end
	end

	class JoyBallEvent < Event
		attr_accessor :joynum,:ball,:rel
		def initialize(joy,ball,rel)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@ball, @rel = ball, rel
		end
	end

	class JoyHatEvent < Event
		attr_accessor :joynum,:hat,:value
		def initialize(joy,hat,value)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@hat, @value = hat, value
		end
	end

	class JoyDownEvent < Event
		attr_accessor :joynum, :button
		def initialize(joy,button)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@button = button
		end
	end

	class JoyUpEvent < Event
		attr_accessor :joynum, :button
		def initialize(joy,button)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@button = button
		end
	end

	class ResizeEvent < Event
		attr_accessor :size
		def initialize(new_size)
			@size = new_size
		end
	end
	
	class QuitEvent < Event
	end

#------------------------------

	class Queue
		include Singleton
		def initialize()
			@@pending = []
			@@allowed = Rubygame::ALL_EVENT_CLASSES
		end

		def update_pending
			#puts "Going to get SDL events..."
			@@pending += get_sdl()
			#puts "Got SDL events."
		end
		private :update_pending

		def get(*types)
			allow = []
			if types.length > 0
				for type in types.flatten()
					if type.kind_of? Class
						if not allow.include? type
							allow.push(type)
						end
					elsif type.kind_of? Event
						allow.push(type.class)
					end
				end
			else
				allow = @@allowed
			end
			#puts "Going to update pending..."
			update_pending()
			#puts "Updated pending."
			get = @@pending.delete_if{|event| not allow.include? event.class}
			@@pending -= get
			return get
		end

		def post(*events)
			# so posted events will appear after SDL events
			update_pending()
			not_added = []
			for event in events.flatten()
				if event.kind_of? Event
					@@pending.push(event)
				else not_added.push(event)
				end
			end
			return not_added
		end

		def allow(*types)
			added = (Rubygame::ALL_EVENT_CLASSES - types.flatten()) & @@allowed
			for type in types.flatten()
				if type.kind_of? Class
					if not @@allowed.include? type
						@@allowed.push(type)
					end
				elsif type.kind_of? Event
					@@allowed.push(type.class)
				end
			end
			return added
		end

		def block(*types)
			removed = @@allowed & types.flatten()
			for type in types.flatten()
				if type.kind_of? Class
					if @@allowed.include? type
						@@allowed.delete(type)
					end
				elsif type.kind_of? Event
					@allowed.delete(type.class)
				end
			end
			return blocked
		end

		def allowed
			return @@allowed.dup
		end

		def blocked
			return Rubygame::ALL_EVENT_CLASSES - @@allowed.dup
		end

		def allowed=(*types)
			added = Rubygame::ALL_EVENT_CLASSES - (types.flatten() & @@allowed)
			@@allowed = []
			self.allow(types)
			return added
		end

		def blocked=(*types)
			removed = types.flatten() & @@allowed
			@@allowed = Rubygame.ALL_EVENT_CLASSES
			self.block(types)
			return removed
		end

	end # class Queue

end # module Rubygame
