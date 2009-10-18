#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2007  John Croisant
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

module Rubygame

  class << self

    # Retrieves all pending events from SDL's event stack and converts them
    # into Rubygame Event objects. Returns an Array of all the events, in
    # the order they were read.
    #
    # This method is used by the EventQueue class, so don't call it if you are
    # using EventQueue for event management! If you do, the EventQueue will not
    # receive all the events, because they will have been removed from SDL's
    # event stack by this method.
    #
    # However, if you aren't using EventQueue, you can safely use this method
    # to make your own event management system.
    #
    def fetch_sdl_events
      deprecated("Rubygame.fetch_sdl_events", "3.0")
      events = []
      until( ( event = SDL::PollEvent() ).nil? )
        events << _convert_sdlevent(event)
      end
      return events
    end


    private


    def _convert_active( state ) # :nodoc:
      states = []
      states << "mouse"    if (state & SDL::APPMOUSEFOCUS)
      states << "keyboard" if (state & SDL::APPINPUTFOCUS)
      states << "active"   if (state & SDL::APPACTIVE)
      return states
    end


    def _convert_keymod( mods ) # :nodoc:
      array = []
      array << SDL::K_LSHIFT   if( mods & SDL::KMOD_LSHIFT )
      array << SDL::K_RSHIFT   if( mods & SDL::KMOD_RSHIFT )
      array << SDL::K_LCTRL    if( mods & SDL::KMOD_LCTRL  )
      array << SDL::K_RCTRL    if( mods & SDL::KMOD_RCTRL  )
      array << SDL::K_LALT     if( mods & SDL::KMOD_LALT   )
      array << SDL::K_RALT     if( mods & SDL::KMOD_RALT   )
      array << SDL::K_LMETA    if( mods & SDL::KMOD_LMETA  )
      array << SDL::K_RMETA    if( mods & SDL::KMOD_RMETA  )
      array << SDL::K_NUMLOCK  if( mods & SDL::KMOD_NUM    )
      array << SDL::K_CAPSLOCK if( mods & SDL::KMOD_CAPS   )
      array << SDL::K_MODE     if( mods & SDL::KMOD_MODE   )
      return array
    end


    def _convert_mousebuttons( state ) # :nodoc:
      states = []
      states << SDL::BUTTON_LEFT    if (state & SDL::BUTTON_LMASK)
      states << SDL::BUTTON_MIDDLE  if (state & SDL::BUTTON_MMASK)
      states << SDL::BUTTON_RIGHT   if (state & SDL::BUTTON_RMASK)
      return states
    end


    def _convert_sdlevent( ev ) # :nodoc:
      case ev.type

      when SDL::ACTIVEEVENT
        return ActiveEvent.new( (ev.gain == 1), _convert_active(ev.state) )

      when SDL::VIDEOEXPOSE
        return ExposeEvent.new()

      when SDL::JOYAXISMOTION
        return JoyAxisEvent.new( ev.which, ev.axis, ev.value )

      when SDL::JOYBALLMOTION
        return JoyBallEvent.new( ev.which, ev.ball, [ev.xrel, ev.yrel] )

      when SDL::JOYBUTTONDOWN
        return JoyDownEvent.new( ev.which, ev.button )

      when SDL::JOYBUTTONUP
        return JoyUpEvent.new( ev.which, ev.button )

      when SDL::JOYHATMOTION
        return JoyHatEvent.new( ev.which, ev.hat, ev.value )

      when SDL::KEYDOWN
        return KeyDownEvent.new(ev.keysym.sym, _convert_keymod(ev.keysym.mod))

      when SDL::KEYUP
        return KeyUpEvent.new(ev.keysym.sym, _convert_keymod(ev.keysym.mod))

      when SDL::MOUSEBUTTONDOWN
        return MouseDownEvent.new( [ev.x, ev.y], ev.button )

      when SDL::MOUSEBUTTONUP
        return MouseUpEvent.new( [ev.x, ev.y], ev.button )

      when SDL::MOUSEMOTION
        return MouseMotionEvent.new( [ev.x, ev.y], [ev.xrel, ev.yrel],
                                     _convert_mousebuttons(ev.state) )

      when SDL::VIDEORESIZE
        return ResizeEvent.new( [ev.w, ev.h] )

      when SDL::QUIT
        return QuitEvent.new()
      end

    end

  end


	# Converts a keyboard symbol (keysym) into a human-readable text string.
	# If either Shift key was being pressed, alphanumeric or punctuation keys 
	# will be made uppercase or alternate, based on U.S. keyboard layout.
	# E.g. "a" becomes "A", "1" becomes "!", and "/" becomes "?".
	def Rubygame.key2str( sym, mods )
		if (mods.include? K_LSHIFT) or (mods.include? K_RSHIFT)
			return (Rubygame::Key::KEY2UPPER[sym]\
				or Rubygame::Key::KEY2ASCII[sym] or "")
		else
			return (Rubygame::Key::KEY2LOWER[sym]\
				or Rubygame::Key::KEY2ASCII[sym] or "")
		end
	end

	# The parent class for all event classes. You can make custom event classes,
  # if desired; inheriting this class is not necessary, but makes it easier
  # to check if an object is an event or not.
	class Event
	end

	# Indicates that the Rubygame window has gained or lost focus from the
	# window manager.
	# 
	# This event has these attributes:
	# gain::  true if the window gained focus, and false if it lost focus.
	# state:: string indicating what type of focus was gained or lost: 
	#         "mouse"::    the mouse entered/exited the window
	#         "keyboard":: the window gained or lost input focus
	#         "active"::   the window was minimized/iconified.
	class ActiveEvent < Event
		attr_accessor :gain, :state
		def initialize(gain,state)
			@gain = gain
			@state = state 
		end
	end

	# Indicates that a keyboard key was pressed.
	# 
	# This event has these attributes:
	# string:: a human-readable string telling what key was pressed, or nil.
	#          See #key2str.
	# key::    the integer keysym for the key. These can be compared with the
	#          K_* constants in the Rubygame module, e.g. Rubygame::K_A.
	# mods::   an Array of zero or more keysyms indicating which modifier keys
	#          were being pressed when the key was pressed. You can compare
	#          with these constants in the Rubygame module:
	#          K_RSHIFT::    shift key (right side)
	#          K_LSHIFT::    shift key (left side)
	#          K_RCTRL::     ctrl key (right side)
	#          K_LCTRL::     ctrl key (left side)
	#          K_RALT::      alt key (right side)
	#          K_LALT::      alt key (left side)
	#          K_RMETA::     meta key (right side)
	#          K_LMETA::     meta key (left side)
	#          K_RSUPER::    super key, aka. Windows key (right side)
	#          K_LSUPER::    super key, aka. Windows key (left side)
	#          K_RALT::      alt key (right side)
	#          K_NUMLOCK::   num lock
	#          K_CAPSLOCK::  caps lock
	#          K_MODE::      mode key
	#          
	#          
	class KeyDownEvent < Event
		attr_accessor :string,:key,:mods

		# Create a new KeyDownEvent.
		# 
		# key::  either an integer keysym (e.g. Rubygame::K_A) or string (e.g. "a")
		# mods:: array of modifier keysyms
		def initialize(key,mods)
			if key.kind_of? Integer
				@key = key
				@string = Rubygame.key2str(key, mods) #a string or nil
			elsif key.kind_of? String
				@key = Rubygame::Key::ASCII2KEY[key]
				if @key != nil
					@string = key
				else
					raise(ArgumentError,"First argument of KeyDownEvent.new() must be an Integer KeySym (like K_A) or a ASCII-like String (like \"a\" or \"A\"). Got %s (%s)"%[key,key.class])
				end
			end
			@mods = mods
		end
	end

	# Indicates that a keyboard key was released.
	# 
	# See KeyDownEvent.
	class KeyUpEvent < Event
		attr_accessor :string,:key,:mods
		def initialize(key,mods)
			if key.kind_of? Integer
				@key = key
				@string = Rubygame.key2str(key, mods) #a string or nil
			elsif key.kind_of? String
				@key = Rubygame::Key::ASCII2KEY[key]
				if @key != nil
					@string = key
				else
					raise(ArgumentError,"First argument of KeyUpEvent.new() must be an Integer KeySym (like K_A) or a ASCII-like String (like \"a\" or \"A\"). Got %s (%s)"%[key,key.class])
				end
			end
			@mods = mods
		end
	end

	# Indicates that the mouse cursor moved.
	# 
	# This event has these attributes:
	# pos::     the new position of the cursor, in the form [x,y].
	# rel::     the relative movement of the cursor since the last update, [x,y].
	# buttons:: the mouse buttons that were being held during the movement,
	#           an Array of zero or more of these constants in module Rubygame
	#           (or the corresponding button number):
	#           MOUSE_LEFT::   1; left mouse button
	#           MOUSE_MIDDLE:: 2; middle mouse button
	#           MOUSE_RIGHT::  3; right mouse button
	class MouseMotionEvent < Event
		attr_accessor :pos,:rel,:buttons
		def initialize(pos,rel,buttons)
			@pos, @rel, @buttons = pos, rel, buttons
		end
	end

	# Indicates that a mouse button was pressed.
	# 
	# This event has these attributes:
	# string:: string indicating the button that was pressed ("left","middle", or
	#          "right").
	# pos::    the position of the mouse cursor when the button was pressed,
	#          in the form [x,y].
	# button:: the mouse button that was pressed; one of these constants in
	#          module Rubygame (or the corresponding button number):
	#          MOUSE_LEFT::   1; left mouse button
	#          MOUSE_MIDDLE:: 2; middle mouse button
	#          MOUSE_RIGHT::  3; right mouse button
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

	# Indicates that a mouse button was released.
	# 
	# See MouseDownEvent.
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

	# Indicates that a Joystick axis was moved.
	# 
	# This event has these attributes:
	# joynum:: the identifier number of the affected Joystick.
	# axis::   the identifier number of the axis.
	# value::  the new value of the axis, between -32768 and 32767
	class JoyAxisEvent < Event
		attr_accessor :joynum,:axis,:value
		def initialize(joy,axis,value)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@axis, @value = axis, value
		end
	end

	# Indicates that a Joystick trackball was moved.
	# 
	# This event has these attributes:
	# joynum:: the identifier number of the affected Joystick.
	# ball::   the identifier number of the trackball.
	# rel::    the relative movement of the trackball, [x,y].
	class JoyBallEvent < Event
		attr_accessor :joynum,:ball,:rel
		def initialize(joy,ball,rel)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@ball, @rel = ball, rel
		end
	end

	# Indicates that a Joystick POV hat was moved.
	# 
	# This event has these attributes:
	# joynum:: the identifier number of the affected Joystick.
	# hat::    the identifier number of the hat.
	# value::  the new direction of the hat, one of these constants in module
	#          Rubygame (or the corresponding number):
	#          HAT_CENTERED::   0
	#          HAT_UP::         1 
	#          HAT_RIGHT::      2
	#          HAT_DOWN::       4 	
	#          HAT_LEFT::       8
	#          HAT_RIGHTUP::    3
	#          HAT_RIGHTDOWN::  6
	#          HAT_LEFTUP::     9
	#          HAT_LEFTDOWN::   12
	class JoyHatEvent < Event
		attr_accessor :joynum,:hat,:value
		def initialize(joy,hat,value)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@hat, @value = hat, value
		end
	end

	# Indicates that a Joystick button was pressed.
	# 
	# This event has these attributes:
	# joynum:: the identifier number of the affected Joystick.
	# hat::    the identifier number of the button.
	class JoyDownEvent < Event
		attr_accessor :joynum, :button
		def initialize(joy,button)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@button = button
		end
	end

	# Indicates that a Joystick button was released.
	# 
	# See JoyDownEvent.
	class JoyUpEvent < Event
		attr_accessor :joynum, :button
		def initialize(joy,button)
			# eventually, joy could be int OR a Rubygame::Joystick instance,
			# which would be stored as joy or maybe joyinstance?
			@joynum = joy
			@button = button
		end
	end

	# Indicates that the application window was resized. (After this event
	# occurs, you should use Screen#set_mode to change the display surface to
	# the new size.)
	# 
	# This event has these attributes:
	# size:: the new size of the window, in pixels [w,h].
	class ResizeEvent < Event
		attr_accessor :size
		def initialize(new_size)
			@size = new_size
		end
	end

	# Indicates that part of the application window was exposed or otherwise
	# changed, and perhaps the window needs to be refreshed. This event occurs,
	# for example, when an OpenGL display should be updated.
	class ExposeEvent < Event
	end
	
	# Indicates that the application has been signaled to quit. (E.g. the user
	# pressed the close button.)
	class QuitEvent < Event
	end


	# List of all Rubygame hardware event classes. *Do not modify!*
	SDL_EVENTS = [ActiveEvent, KeyDownEvent, KeyUpEvent,\
		MouseMotionEvent,MouseDownEvent,MouseUpEvent,JoyAxisEvent,\
		JoyBallEvent, JoyHatEvent,JoyDownEvent, JoyUpEvent,\
		ResizeEvent, QuitEvent]
  
end # module Rubygame
