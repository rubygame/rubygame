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

module Rubygame

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
