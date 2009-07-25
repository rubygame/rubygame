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


  # Event constants
  NOEVENT         = SDL::NOEVENT
  ACTIVEEVENT     = SDL::ACTIVEEVENT
  KEYDOWN         = SDL::KEYDOWN
  KEYUP           = SDL::KEYUP
  MOUSEMOTION     = SDL::MOUSEMOTION
  MOUSEBUTTONDOWN = SDL::MOUSEBUTTONDOWN
  MOUSEBUTTONUP   = SDL::MOUSEBUTTONUP
  JOYAXISMOTION   = SDL::JOYAXISMOTION
  JOYBALLMOTION   = SDL::JOYBALLMOTION
  JOYHATMOTION    = SDL::JOYHATMOTION
  JOYBUTTONDOWN   = SDL::JOYBUTTONDOWN
  JOYBUTTONUP     = SDL::JOYBUTTONUP
  QUIT            = SDL::QUIT
  SYSWMEVENT      = SDL::SYSWMEVENT
  VIDEORESIZE     = SDL::VIDEORESIZE
  VIDEOEXPOSE     = SDL::VIDEOEXPOSE
  USEREVENT       = SDL::USEREVENT


  # Joystick constants  
  HAT_CENTERED  = SDL::HAT_CENTERED
  HAT_UP        = SDL::HAT_UP
  HAT_RIGHT     = SDL::HAT_RIGHT
  HAT_DOWN      = SDL::HAT_DOWN
  HAT_LEFT      = SDL::HAT_LEFT
  HAT_RIGHTUP   = SDL::HAT_RIGHTUP
  HAT_RIGHTDOWN = SDL::HAT_RIGHTDOWN
  HAT_LEFTUP    = SDL::HAT_LEFTUP
  HAT_LEFTDOWN  = SDL::HAT_LEFTDOWN

  
  # Mouse constants
  MOUSE_LEFT   = SDL::BUTTON_LEFT
  MOUSE_MIDDLE = SDL::BUTTON_MIDDLE
  MOUSE_RIGHT  = SDL::BUTTON_RIGHT
  MOUSE_LMASK  = SDL::BUTTON_LMASK
  MOUSE_MMASK  = SDL::BUTTON_MMASK
  MOUSE_RMASK  = SDL::BUTTON_RMASK


  # ASCII key symbols
  K_UNKNOWN      = SDL::K_UNKNOWN
  K_FIRST        = SDL::K_FIRST
  K_BACKSPACE    = SDL::K_BACKSPACE
  K_TAB          = SDL::K_TAB
  K_CLEAR        = SDL::K_CLEAR
  K_RETURN       = SDL::K_RETURN
  K_PAUSE        = SDL::K_PAUSE
  K_ESCAPE       = SDL::K_ESCAPE
  K_SPACE        = SDL::K_SPACE
  K_EXCLAIM      = SDL::K_EXCLAIM
  K_QUOTEDBL     = SDL::K_QUOTEDBL
  K_HASH         = SDL::K_HASH
  K_DOLLAR       = SDL::K_DOLLAR
  K_AMPERSAND    = SDL::K_AMPERSAND
  K_QUOTE        = SDL::K_QUOTE
  K_LEFTPAREN    = SDL::K_LEFTPAREN
  K_RIGHTPAREN   = SDL::K_RIGHTPAREN
  K_ASTERISK     = SDL::K_ASTERISK
  K_PLUS         = SDL::K_PLUS
  K_COMMA        = SDL::K_COMMA
  K_MINUS        = SDL::K_MINUS
  K_PERIOD       = SDL::K_PERIOD
  K_SLASH        = SDL::K_SLASH
  K_0            = SDL::K_0
  K_1            = SDL::K_1
  K_2            = SDL::K_2
  K_3            = SDL::K_3
  K_4            = SDL::K_4
  K_5            = SDL::K_5
  K_6            = SDL::K_6
  K_7            = SDL::K_7
  K_8            = SDL::K_8
  K_9            = SDL::K_9
  K_COLON        = SDL::K_COLON
  K_SEMICOLON    = SDL::K_SEMICOLON
  K_LESS         = SDL::K_LESS
  K_EQUALS       = SDL::K_EQUALS
  K_GREATER      = SDL::K_GREATER
  K_QUESTION     = SDL::K_QUESTION
  K_AT           = SDL::K_AT
  K_LEFTBRACKET  = SDL::K_LEFTBRACKET
  K_BACKSLASH    = SDL::K_BACKSLASH
  K_RIGHTBRACKET = SDL::K_RIGHTBRACKET
  K_CARET        = SDL::K_CARET
  K_UNDERSCORE   = SDL::K_UNDERSCORE
  K_BACKQUOTE    = SDL::K_BACKQUOTE
  K_A            = SDL::K_a
  K_B            = SDL::K_b
  K_C            = SDL::K_c
  K_D            = SDL::K_d
  K_E            = SDL::K_e
  K_F            = SDL::K_f
  K_G            = SDL::K_g
  K_H            = SDL::K_h
  K_I            = SDL::K_i
  K_J            = SDL::K_j
  K_K            = SDL::K_k
  K_L            = SDL::K_l
  K_M            = SDL::K_m
  K_N            = SDL::K_n
  K_O            = SDL::K_o
  K_P            = SDL::K_p
  K_Q            = SDL::K_q
  K_R            = SDL::K_r
  K_S            = SDL::K_s
  K_T            = SDL::K_t
  K_U            = SDL::K_u
  K_V            = SDL::K_v
  K_W            = SDL::K_w
  K_X            = SDL::K_x
  K_Y            = SDL::K_y
  K_Z            = SDL::K_z
  K_DELETE       = SDL::K_DELETE

  
  # International keyboard symbols
  K_WORLD_0  = SDL::K_WORLD_0
  K_WORLD_1  = SDL::K_WORLD_1
  K_WORLD_2  = SDL::K_WORLD_2
  K_WORLD_3  = SDL::K_WORLD_3
  K_WORLD_4  = SDL::K_WORLD_4
  K_WORLD_5  = SDL::K_WORLD_5
  K_WORLD_6  = SDL::K_WORLD_6
  K_WORLD_7  = SDL::K_WORLD_7
  K_WORLD_8  = SDL::K_WORLD_8
  K_WORLD_9  = SDL::K_WORLD_9
  K_WORLD_10 = SDL::K_WORLD_10
  K_WORLD_11 = SDL::K_WORLD_11
  K_WORLD_12 = SDL::K_WORLD_12
  K_WORLD_13 = SDL::K_WORLD_13
  K_WORLD_14 = SDL::K_WORLD_14
  K_WORLD_15 = SDL::K_WORLD_15
  K_WORLD_16 = SDL::K_WORLD_16
  K_WORLD_17 = SDL::K_WORLD_17
  K_WORLD_18 = SDL::K_WORLD_18
  K_WORLD_19 = SDL::K_WORLD_19
  K_WORLD_20 = SDL::K_WORLD_20
  K_WORLD_21 = SDL::K_WORLD_21
  K_WORLD_22 = SDL::K_WORLD_22
  K_WORLD_23 = SDL::K_WORLD_23
  K_WORLD_24 = SDL::K_WORLD_24
  K_WORLD_25 = SDL::K_WORLD_25
  K_WORLD_26 = SDL::K_WORLD_26
  K_WORLD_27 = SDL::K_WORLD_27
  K_WORLD_28 = SDL::K_WORLD_28
  K_WORLD_29 = SDL::K_WORLD_29
  K_WORLD_30 = SDL::K_WORLD_30
  K_WORLD_31 = SDL::K_WORLD_31
  K_WORLD_32 = SDL::K_WORLD_32
  K_WORLD_33 = SDL::K_WORLD_33
  K_WORLD_34 = SDL::K_WORLD_34
  K_WORLD_35 = SDL::K_WORLD_35
  K_WORLD_36 = SDL::K_WORLD_36
  K_WORLD_37 = SDL::K_WORLD_37
  K_WORLD_38 = SDL::K_WORLD_38
  K_WORLD_39 = SDL::K_WORLD_39
  K_WORLD_40 = SDL::K_WORLD_40
  K_WORLD_41 = SDL::K_WORLD_41
  K_WORLD_42 = SDL::K_WORLD_42
  K_WORLD_43 = SDL::K_WORLD_43
  K_WORLD_44 = SDL::K_WORLD_44
  K_WORLD_45 = SDL::K_WORLD_45
  K_WORLD_46 = SDL::K_WORLD_46
  K_WORLD_47 = SDL::K_WORLD_47
  K_WORLD_48 = SDL::K_WORLD_48
  K_WORLD_49 = SDL::K_WORLD_49
  K_WORLD_50 = SDL::K_WORLD_50
  K_WORLD_51 = SDL::K_WORLD_51
  K_WORLD_52 = SDL::K_WORLD_52
  K_WORLD_53 = SDL::K_WORLD_53
  K_WORLD_54 = SDL::K_WORLD_54
  K_WORLD_55 = SDL::K_WORLD_55
  K_WORLD_56 = SDL::K_WORLD_56
  K_WORLD_57 = SDL::K_WORLD_57
  K_WORLD_58 = SDL::K_WORLD_58
  K_WORLD_59 = SDL::K_WORLD_59
  K_WORLD_60 = SDL::K_WORLD_60
  K_WORLD_61 = SDL::K_WORLD_61
  K_WORLD_62 = SDL::K_WORLD_62
  K_WORLD_63 = SDL::K_WORLD_63
  K_WORLD_64 = SDL::K_WORLD_64
  K_WORLD_65 = SDL::K_WORLD_65
  K_WORLD_66 = SDL::K_WORLD_66
  K_WORLD_67 = SDL::K_WORLD_67
  K_WORLD_68 = SDL::K_WORLD_68
  K_WORLD_69 = SDL::K_WORLD_69
  K_WORLD_70 = SDL::K_WORLD_70
  K_WORLD_71 = SDL::K_WORLD_71
  K_WORLD_72 = SDL::K_WORLD_72
  K_WORLD_73 = SDL::K_WORLD_73
  K_WORLD_74 = SDL::K_WORLD_74
  K_WORLD_75 = SDL::K_WORLD_75
  K_WORLD_76 = SDL::K_WORLD_76
  K_WORLD_77 = SDL::K_WORLD_77
  K_WORLD_78 = SDL::K_WORLD_78
  K_WORLD_79 = SDL::K_WORLD_79
  K_WORLD_80 = SDL::K_WORLD_80
  K_WORLD_81 = SDL::K_WORLD_81
  K_WORLD_82 = SDL::K_WORLD_82
  K_WORLD_83 = SDL::K_WORLD_83
  K_WORLD_84 = SDL::K_WORLD_84
  K_WORLD_85 = SDL::K_WORLD_85
  K_WORLD_86 = SDL::K_WORLD_86
  K_WORLD_87 = SDL::K_WORLD_87
  K_WORLD_88 = SDL::K_WORLD_88
  K_WORLD_89 = SDL::K_WORLD_89
  K_WORLD_90 = SDL::K_WORLD_90
  K_WORLD_91 = SDL::K_WORLD_91
  K_WORLD_92 = SDL::K_WORLD_92
  K_WORLD_93 = SDL::K_WORLD_93
  K_WORLD_94 = SDL::K_WORLD_94
  K_WORLD_95 = SDL::K_WORLD_95

  
  # Numeric keypad symbols
  K_KP0         = SDL::K_KP0
  K_KP1         = SDL::K_KP1
  K_KP2         = SDL::K_KP2
  K_KP3         = SDL::K_KP3
  K_KP4         = SDL::K_KP4
  K_KP5         = SDL::K_KP5
  K_KP6         = SDL::K_KP6
  K_KP7         = SDL::K_KP7
  K_KP8         = SDL::K_KP8
  K_KP9         = SDL::K_KP9
  K_KP_PERIOD   = SDL::K_KP_PERIOD
  K_KP_DIVIDE   = SDL::K_KP_DIVIDE
  K_KP_MULTIPLY = SDL::K_KP_MULTIPLY
  K_KP_MINUS    = SDL::K_KP_MINUS
  K_KP_PLUS     = SDL::K_KP_PLUS
  K_KP_ENTER    = SDL::K_KP_ENTER
  K_KP_EQUALS   = SDL::K_KP_EQUALS

  
  # Arrows + Home/End pad
  K_UP       = SDL::K_UP
  K_DOWN     = SDL::K_DOWN
  K_RIGHT    = SDL::K_RIGHT
  K_LEFT     = SDL::K_LEFT
  K_INSERT   = SDL::K_INSERT
  K_HOME     = SDL::K_HOME
  K_END      = SDL::K_END
  K_PAGEUP   = SDL::K_PAGEUP
  K_PAGEDOWN = SDL::K_PAGEDOWN

  
  # Function keys
  K_F1  = SDL::K_F1
  K_F2  = SDL::K_F2
  K_F3  = SDL::K_F3
  K_F4  = SDL::K_F4
  K_F5  = SDL::K_F5
  K_F6  = SDL::K_F6
  K_F7  = SDL::K_F7
  K_F8  = SDL::K_F8
  K_F9  = SDL::K_F9
  K_F10 = SDL::K_F10
  K_F11 = SDL::K_F11
  K_F12 = SDL::K_F12
  K_F13 = SDL::K_F13
  K_F14 = SDL::K_F14
  K_F15 = SDL::K_F15

  
  # Key state modifier keys
  K_NUMLOCK   = SDL::K_NUMLOCK
  K_CAPSLOCK  = SDL::K_CAPSLOCK
  K_SCROLLOCK = SDL::K_SCROLLOCK
  K_RSHIFT    = SDL::K_RSHIFT
  K_LSHIFT    = SDL::K_LSHIFT
  K_RCTRL     = SDL::K_RCTRL
  K_LCTRL     = SDL::K_LCTRL
  K_RALT      = SDL::K_RALT
  K_LALT      = SDL::K_LALT
  K_RMETA     = SDL::K_RMETA
  K_LMETA     = SDL::K_LMETA
  K_LSUPER    = SDL::K_LSUPER
  K_RSUPER    = SDL::K_RSUPER
  K_MODE      = SDL::K_MODE

  
  # Miscellaneous keys
  K_HELP   = SDL::K_HELP
  K_PRINT  = SDL::K_PRINT
  K_SYSREQ = SDL::K_SYSREQ
  K_BREAK  = SDL::K_BREAK
  K_MENU   = SDL::K_MENU
  K_POWER  = SDL::K_POWER
  K_EURO   = SDL::K_EURO
  K_LAST   = SDL::K_LAST




	module Mouse
		# Hash to translate mouse button sym to string
		MOUSE2STR = {
			MOUSE_LEFT => "left",
			MOUSE_MIDDLE => "middle",
			MOUSE_RIGHT => "right"
		}
		# And to translate the other way...
		STR2MOUSE = MOUSE2STR.invert()
		# And allow numbers too (1 = left, so on)...
		STR2MOUSE[1] = MOUSE_LEFT
		STR2MOUSE[2] = MOUSE_MIDDLE
		STR2MOUSE[3] = MOUSE_RIGHT
	end # module Mouse

	module Key
		# All the keys which have ASCII print values
		# It is 87 lines from here to the closing }, if you want to skip it...
		KEY2ASCII = {
			K_BACKSPACE => "\b",
			K_TAB => "\t",
			K_RETURN => "\n", #SDL docs: "\r". Win vs *nix? What about Mac?
			K_ESCAPE => "^[",
			K_SPACE => " ",
			K_EXCLAIM => "!",
			K_QUOTEDBL => "\"",
			K_HASH => "#",
			K_DOLLAR => "$",
			K_AMPERSAND => "&",
			K_QUOTE => "\'",
			K_LEFTPAREN => "(",
			K_RIGHTPAREN => ")",
			K_ASTERISK => "*",
			K_PLUS => "+",
			K_COMMA => ",",
			K_MINUS => "-",
			K_PERIOD => ".",
			K_SLASH => "/",
			K_0 => "0",
			K_1 => "1",
			K_2 => "2",
			K_3 => "3",
			K_4 => "4",
			K_5 => "5",
			K_6 => "6",
			K_7 => "7",
			K_8 => "8",
			K_9 => "9",
			K_COLON => ":",
			K_SEMICOLON => ";",
			K_LESS => "<",
			K_EQUALS => "=",
			K_GREATER => ">",
			K_QUESTION => "?",
			K_AT => "@",
			K_LEFTBRACKET => "[",
			K_BACKSLASH => "\\",
			K_RIGHTBRACKET => "]",
			K_CARET => "^",
			K_UNDERSCORE => "_",
			K_BACKQUOTE => "`",
			K_A => "a",
			K_B => "b",
			K_C => "c",
			K_D => "d",
			K_E => "e",
			K_F => "f",
			K_G => "g",
			K_H => "h",
			K_I => "i",
			K_J => "j",
			K_K => "k",
			K_L => "l",
			K_M => "m",
			K_N => "n",
			K_O => "o",
			K_P => "p",
			K_Q => "q",
			K_R => "r",
			K_S => "s",
			K_T => "t",
			K_U => "u",
			K_V => "v",
			K_W => "w",
			K_X => "x",
			K_Y => "y",
			K_Z => "z",
			K_KP0 => "0",
			K_KP1 => "1",
			K_KP2 => "2",
			K_KP3 => "3",
			K_KP4 => "4",
			K_KP5 => "5",
			K_KP6 => "6",
			K_KP7 => "7",
			K_KP8 => "8",
			K_KP9 => "9",
			K_KP_PERIOD => ".",
			K_KP_DIVIDE => "/",
			K_KP_MULTIPLY => "*",
			K_KP_MINUS => "-",
			K_KP_PLUS => "+",
			K_KP_ENTER => "\n", #again, SDL docs say "\r"
			K_KP_EQUALS => "=",
		}

		# And to translate the other way...
		ASCII2KEY = KEY2ASCII.invert()
		# accept uppercase letters too, return same as lowercase version:
		("a".."z").each{ |letter| ASCII2KEY[letter.upcase] = ASCII2KEY[letter] }

		# All the keys that are affected by the Shift key, in lower case
		# 49 lines from here to the end of the hash
		KEY2LOWER = {
			K_QUOTE => "\'",
			K_COMMA => ",",
			K_MINUS => "-",
			K_PERIOD => ".",
			K_SLASH => "/",
			K_0 => "0",
			K_1 => "1",
			K_2 => "2",
			K_3 => "3",
			K_4 => "4",
			K_5 => "5",
			K_6 => "6",
			K_7 => "7",
			K_8 => "8",
			K_9 => "9",
			K_SEMICOLON => ";",
			K_EQUALS => "=",
			K_LEFTBRACKET => "[",
			K_BACKSLASH => "\\",
			K_RIGHTBRACKET => "]",
			K_BACKQUOTE => "`",
			K_A => "a",
			K_B => "b",
			K_C => "c",
			K_D => "d",
			K_E => "e",
			K_F => "f",
			K_G => "g",
			K_H => "h",
			K_I => "i",
			K_J => "j",
			K_K => "k",
			K_L => "l",
			K_M => "m",
			K_N => "n",
			K_O => "o",
			K_P => "p",
			K_Q => "q",
			K_R => "r",
			K_S => "s",
			K_T => "t",
			K_U => "u",
			K_V => "v",
			K_W => "w",
			K_X => "x",
			K_Y => "y",
			K_Z => "z",
		}

		# All the keys that are affected by the Shift key, in UPPER case
		# 49 lines from here to the end of the hash
		KEY2UPPER = {
			K_QUOTE => "\"",
			K_COMMA => "<",
			K_MINUS => "_",
			K_PERIOD => ">",
			K_SLASH => "?",
			K_0 => ")",
			K_1 => "!",
			K_2 => "@",
			K_3 => "#",
			K_4 => "$",
			K_5 => "%",
			K_6 => "^",
			K_7 => "&",
			K_8 => "*",
			K_9 => "(",
			K_SEMICOLON => ":",
			K_EQUALS => "+",
			K_LEFTBRACKET => "{",
			K_BACKSLASH => "|",
			K_RIGHTBRACKET => "}",
			K_BACKQUOTE => "~",
			K_A => "A",
			K_B => "B",
			K_C => "C",
			K_D => "D",
			K_E => "E",
			K_F => "F",
			K_G => "G",
			K_H => "H",
			K_I => "I",
			K_J => "J",
			K_K => "K",
			K_L => "L",
			K_M => "M",
			K_N => "N",
			K_O => "O",
			K_P => "P",
			K_Q => "Q",
			K_R => "R",
			K_S => "S",
			K_T => "T",
			K_U => "U",
			K_V => "V",
			K_W => "W",
			K_X => "X",
			K_Y => "Y",
			K_Z => "Z",
		}
	end #module Key

end # module Rubygame
