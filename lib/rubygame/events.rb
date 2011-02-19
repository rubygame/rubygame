#--
#  This file is one part of:
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
# 
#  Copyright (C) 2008-2009  John Croisant
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# 
#  Changes:
#  * Tyler Church, 2010-09-06: Added Rubygame.get_key_state
#                              (now Rubygame.pressed_keys)
# 
#++


module Rubygame


  # Enable key repeat, so that additional keyboard release and press
  # events are automatically generated for as long as the key is held
  # down. See also #disable_key_repeat.
  #
  # delay::    how many seconds to wait before starting to repeat.
  #            Default is 0.5 seconds. (Numeric or :default, optional)
  #
  # interval:: how many seconds to wait in between repetitions after
  #            the first one. Default is 0.03 seconds. 
  #            (Numeric or :default, optional)
  #
  def self.enable_key_repeat( delay=:default, interval=:default )

    delay = if delay == :default
              SDL::DEFAULT_REPEAT_DELAY.to_f / 1000
            else
              delay.to_f
            end

    interval = if interval == :default
                 SDL::DEFAULT_REPEAT_INTERVAL.to_f / 1000
               else
                 interval.to_f
               end

    if delay < 0.001
      raise( ArgumentError,
             "delay must be at least 0.001 sec (got #{delay})" )
    end

    if interval < 0.001
      raise( ArgumentError,
             "interval must be at least 0.001 sec (got #{interval})" )
    end

    result = SDL.EnableKeyRepeat( (delay * 1000).to_i, (interval * 1000).to_i )

    if result != 0
      raise( Rubygame::SDLError,
             "Could not enable key repeat: #{SDL.GetError()}" )
    end

    return nil
  end


  # Disable key repeat, undoing the effect of #enable_key_repeat.
  #
  def self.disable_key_repeat
    result = SDL.EnableKeyRepeat( 0, 0 )

    if result != 0
      raise( Rubygame::SDLError,
             "Could not disable key repeat: #{SDL.GetError()}" )
    end

    return nil
  end


  # Returns a Hash of the keys that are currently being pressed on the
  # keyboard. Keys that are being pressed with have a value of true.
  # Keys that are not being pressed will not be in the Hash.
  # 
  # Example:
  # 
  #   # Assuming that the "A" and left "Ctrl" keys are being pressed.
  #   
  #   Rubygame.pressed_keys
  #   # => {:a => true, :left_ctrl => true}
  #   
  #   Rubygame.pressed_keys.keys
  #   # => [:a, :left_ctrl]
  #   
  #   Rubygame.pressed_keys[:a]
  #   # => true
  #   
  #   # Not being pressed
  #   Rubygame.pressed_keys[:b]
  #   # => nil
  # 
  def self.pressed_keys
    SDL.PumpEvents()
    keys = {}
    SDL.GetKeyState().each_with_index do |state, key|
      keys[Events._convert_key_symbol(key)] = true if state != 0
    end
    keys
  end


  # The Events module contains classes representing various
  # hardware events (e.g. keyboard presses, mouse clicks)
  # and software events (e.g. clock tick, window becomes active)
  # 
  # This event classes are meant as a full replacement for
  # the older event classes defined in the Rubygame module 
  # (e.g. KeyDownEvent, QuitEvent). The old classes are
  # deprecated and should not be used anymore.
  # 
  module Events



    # NOTE: This method converts the SDL events into the new-style event
    # classes, located in the Rubygame::Events module. For converting to
    # the older (deprecated) events, see Rubygame.fetch_sdl_events.
    #
    # Retrieves all pending events from SDL's event stack and converts them
    # into Rubygame event objects. Returns an Array of all the events, in
    # the order they were read.
    #
    # This method is used by the EventQueue class (among others), so
    # don't call it if you are using any of Rubygame's event management
    # classes (e.g. EventQueue)! If you do, they will not receive all
    # the events, because some events will have been removed from SDL's
    # event stack by this method.
    #
    # However, if you aren't using EventQueue, you can safely use this
    # method to make your own event management system.
    #
    def self.fetch_sdl_events
      events = []
      until( ( event = SDL::PollEvent() ).nil? )
        case ( event = _convert_sdlevent(event) )
        when Array;   events += event
        else;         events << event
        end
      end
      return events
    end



    private


    # Convert SDL's ACTIVEEVENT into zero or more of:
    #
    #  InputFocusGained   or  InputFocusLost
    #  MouseFocusGained   or  MouseFocusLost
    #  WindowUnminimized  or  WindowMinimized
    #
    # Returns a ruby Array of the events it generated.
    #
    def self._convert_activeevent( ev )
      
      state = ev.state
      gain  = ev.gain

      # any_state = SDL::APPACTIVE | SDL::APPINPUTFOCUS | SDL::APPMOUSEFOCUS
      # if (state & any_state) == 0
      #   raise( Rubygame::SDLError, "Unknown ACTIVEEVENT state #{state}. "+
      #          "This is a bug in Rubygame." )
      # end

      events = []

      if (SDL::APPACTIVE & state) != 0
        if( gain == 1 )
          events << WindowUnminimized.new
        else
          events << WindowMinimized.new
        end
      end

      if (SDL::APPINPUTFOCUS & state) != 0
        if( gain == 1 )
          events << InputFocusGained.new
        else
          events << InputFocusLost.new
        end
      end

      if (SDL::APPMOUSEFOCUS & state) != 0
        if( gain == 1 )
          events << MouseFocusGained.new
        else
          events << MouseFocusLost.new
        end
      end

      return events

    end



    # Convert SDL's joystick axis events into JoystickAxisMoved.
    #
    def self._convert_joyaxisevent( ev )
      joy_id = ev.which
      axis   = ev.axis
      value  = ev.value

      # Convert value to the -1.0 .. 1.0 range
      value = if( value > 0 )
                value / 32767.0
              else
                value / 32768.0
              end

      return JoystickAxisMoved.new( joy_id, axis, value )
    end



    # Convert SDL's joystick ball events into JoystickBallMoved.
    #
    def self._convert_joyballevent( ev )
      return JoystickBallMoved.new( ev.which, ev.ball, [ev.xrel, ev.xrel] )
    end



    # Convert SDL's joystick button events into JoystickButtonPressed or
    # JoystickButtonReleased.
    #
    def self._convert_joybuttonevent( ev )
      case ev.state
      when SDL::PRESSED
        JoystickButtonPressed.new( ev.which, ev.button )
      when SDL::RELEASED
        JoystickButtonReleased.new( ev.which, ev.button )
      else
        raise( Rubygame::SDLError, "Unknown joystick button state "+
               "#{ev.jbutton.state}. This is a bug in Rubygame." )
      end
    end



    # Convert SDL's joystick hat events into JoystickHatMoved.
    #
    def self._convert_joyhatevent( ev )
      dir = case ev.value
            when SDL::HAT_RIGHTUP;    :up_right
            when SDL::HAT_RIGHTDOWN;  :down_right
            when SDL::HAT_LEFTUP;     :up_left
            when SDL::HAT_LEFTDOWN;   :down_left
            when SDL::HAT_UP;         :up
            when SDL::HAT_RIGHT;      :right
            when SDL::HAT_DOWN;       :down
            when SDL::HAT_LEFT;       :left
            else;                     nil
            end

      return JoystickHatMoved.new( ev.which, ev.hat, dir )
    end



    # Returns a sanitized symbol for the given key.
    #
    def self._convert_key_symbol( key )
      Rubygame.init_video_system

      name = case key
             when SDL::K_1;             "number 1"
             when SDL::K_2;             "number 2"
             when SDL::K_3;             "number 3"
             when SDL::K_4;             "number 4"
             when SDL::K_5;             "number 5"
             when SDL::K_6;             "number 6"
             when SDL::K_7;             "number 7"
             when SDL::K_8;             "number 8"
             when SDL::K_9;             "number 9"
             when SDL::K_0;             "number 0"
             when SDL::K_EXCLAIM;       "exclamation mark"
             when SDL::K_QUOTEDBL;      "double quote"
             when SDL::K_HASH;          "hash"
             when SDL::K_DOLLAR;        "dollar"
             when SDL::K_AMPERSAND;     "ampersand"
             when SDL::K_QUOTE;         "quote"
             when SDL::K_LEFTPAREN;     "left parenthesis"
             when SDL::K_RIGHTPAREN;    "right parenthesis"
             when SDL::K_ASTERISK;      "asterisk"
             when SDL::K_PLUS;          "plus"
             when SDL::K_MINUS;         "minus"
             when SDL::K_PERIOD;        "period"
             when SDL::K_COMMA;         "comma"
             when SDL::K_SLASH;         "slash"
             when SDL::K_SEMICOLON;     "semicolon"
             when SDL::K_LESS;          "less than"
             when SDL::K_EQUALS;        "equals"
             when SDL::K_GREATER;       "greater than"
             when SDL::K_QUESTION;      "question mark"
             when SDL::K_AT;            "at"
             when SDL::K_LEFTBRACKET;   "left bracket"
             when SDL::K_BACKSLASH;     "backslash"
             when SDL::K_RIGHTBRACKET;  "right bracket"
             when SDL::K_CARET;         "caret"
             when SDL::K_UNDERSCORE;    "underscore"
             when SDL::K_BACKQUOTE;     "backquote"
             when SDL::K_KP1;           "keypad 1"
             when SDL::K_KP2;           "keypad 2"
             when SDL::K_KP3;           "keypad 3"
             when SDL::K_KP4;           "keypad 4"
             when SDL::K_KP5;           "keypad 5"
             when SDL::K_KP6;           "keypad 6"
             when SDL::K_KP7;           "keypad 7"
             when SDL::K_KP8;           "keypad 8"
             when SDL::K_KP9;           "keypad 9"
             when SDL::K_KP0;           "keypad 0"
             when SDL::K_KP_PERIOD;     "keypad period"
             when SDL::K_KP_DIVIDE;     "keypad divide"
             when SDL::K_KP_MULTIPLY;   "keypad multiply"
             when SDL::K_KP_MINUS;      "keypad minus"
             when SDL::K_KP_PLUS;       "keypad plus"
             when SDL::K_KP_EQUALS;     "keypad equals"
             when SDL::K_KP_ENTER;      "keypad enter"
             else;                      SDL::GetKeyName( key )
             end

      name.downcase!
      name.gsub!(/[- ]/, "_")
      return name.to_sym
    end



    # Convert an OR'd list of KMODs into an Array of symbols.
    #
    def self._convert_keymods( mods )
      return [] if mods == 0

      array = []
      array << :left_shift   if (mods & SDL::KMOD_LSHIFT) != 0
      array << :right_shift  if (mods & SDL::KMOD_RSHIFT) != 0
      array << :left_ctrl    if (mods & SDL::KMOD_LCTRL ) != 0
      array << :right_ctrl   if (mods & SDL::KMOD_RCTRL ) != 0
      array << :left_alt     if (mods & SDL::KMOD_LALT  ) != 0
      array << :right_alt    if (mods & SDL::KMOD_RALT  ) != 0
      array << :left_meta    if (mods & SDL::KMOD_LMETA ) != 0
      array << :right_meta   if (mods & SDL::KMOD_RMETA ) != 0
      array << :numlock      if (mods & SDL::KMOD_NUM   ) != 0
      array << :capslock     if (mods & SDL::KMOD_CAPS  ) != 0
      array << :mode         if (mods & SDL::KMOD_MODE  ) != 0

      return array
    end



    # Convert a Unicode char into a UTF8 ruby byte-string.
    #
    def self._convert_unicode( int )
      if( int > 0 )
        [int].pack('U')
      else
        ""
      end
    end



    # Convert SDL's keyboard events into KeyPressed / KeyReleased.
    #
    def self._convert_keyboardevent( ev )
      key  = _convert_key_symbol( ev.keysym.sym );
      mods = _convert_keymods( ev.keysym.mod );

      case ev.state
      when SDL::PRESSED
        unicode = _convert_unicode( ev.keysym.unicode )
        KeyPressed.new( key, mods, unicode )
      when SDL::RELEASED
        KeyReleased.new( key, mods )
      else
        raise( Rubygame::SDLError, "Unknown keyboard event state "+
               "#{ev.key.state}. This is a bug in Rubygame." )
      end
    end



    # Convert SDL's mouse click events into MousePressed / MouseReleased.
    #
    def self._convert_mouseclickevent( ev )
      button = case ev.button
               when SDL::BUTTON_LEFT;         :mouse_left
               when SDL::BUTTON_MIDDLE;       :mouse_middle
               when SDL::BUTTON_RIGHT;        :mouse_right
               when SDL::BUTTON_WHEELUP;      :mouse_wheel_up
               when SDL::BUTTON_WHEELDOWN;    :mouse_wheel_down
               else;                          ("mouse_%d"%ev.button).to_sym
               end

      pos = [ev.x, ev.y]

      case ev.state
      when SDL::PRESSED
        MousePressed.new( pos, button )
      when SDL::RELEASED
        MouseReleased.new( pos, button )
      else
        raise( Rubygame::SDLError, "Unknown mouse event state "+
               "#{ev.button.state}. This is a bug in Rubygame." )
      end
    end



    # Convert SDL's mouse motion events into MouseMoved
    #
    def self._convert_mousemotionevent( ev )
      mods = ev.state

      btns = []
      btns << :mouse_left        if (mods & SDL::BUTTON_LMASK) != 0
      btns << :mouse_middle      if (mods & SDL::BUTTON_MMASK) != 0
      btns << :mouse_right       if (mods & SDL::BUTTON_RMASK) != 0
      btns << :mouse_wheel_up    if (mods & 
                                     (1 << (SDL::BUTTON_WHEELUP - 1))) != 0
      btns << :mouse_wheel_down  if (mods & 
                                     (1 << (SDL::BUTTON_WHEELDOWN - 1))) != 0

      pos = [ev.x,    ev.y]
      rel = [ev.xrel, ev.yrel]

      return MouseMoved.new( pos, rel, btns )
    end



    # Converts an SDL_Event (C type) into a Rubygame event of the
    # corresponding class.
    #
    def self._convert_sdlevent( ev )
      case ev
      when SDL::ActiveEvent
        return _convert_activeevent(ev)
      when SDL::ExposeEvent
        return WindowExposed.new()
      when SDL::JoyAxisEvent
        return _convert_joyaxisevent(ev)
      when SDL::JoyBallEvent
        return _convert_joyballevent(ev)
      when SDL::JoyButtonEvent
        return _convert_joybuttonevent(ev)
      when SDL::JoyHatEvent
        return _convert_joyhatevent(ev)
      when SDL::KeyboardEvent
        return _convert_keyboardevent(ev)
      when SDL::MouseButtonEvent
        return _convert_mouseclickevent(ev)
      when SDL::MouseMotionEvent
        return _convert_mousemotionevent(ev)
      when SDL::ResizeEvent
        return WindowResized.new( [ev.w, ev.h] )
      when SDL::QuitEvent
        return QuitRequested.new()
      end
    end


  end

end


require "rubygame/events/clock_events"
require "rubygame/events/joystick_events"
require "rubygame/events/keyboard_events"
require "rubygame/events/misc_events"
require "rubygame/events/mouse_events"
