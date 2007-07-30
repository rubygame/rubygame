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
			:a => "a",
			:b => "b",
			:c => "c",
			:d => "d",
			:e => "e",
			:f => "f",
			:g => "g",
			:h => "h",
			:i => "i",
			:j => "j",
			:k => "k",
			:l => "l",
			:m => "m",
			:n => "n",
			:o => "o",
			:p => "p",
			:q => "q",
			:r => "r",
			:s => "s",
			:t => "t",
			:u => "u",
			:v => "v",
			:w => "w",
			:x => "x",
			:y => "y",
			:z => "z",

			:digit_0 => "0",
			:digit_1 => "1",
			:digit_2 => "2",
			:digit_3 => "3",
			:digit_4 => "4",
			:digit_5 => "5",
			:digit_6 => "6",
			:digit_7 => "7",
			:digit_8 => "8",
			:digit_9 => "9",

			:tab => "\t",
			:space => " ",
			:return => "\n", #SDL docs: "\r". Win vs *nix? What about Mac?

			:comma => ",",
			:period => ".",
			:colon => ":",
			:semicolon => ";",
			:quote => "\'",
			:double_quote => "\"",

			:backquote => "`",
			:exclaim => "!",
			:at => "@",
			:hash => "#",
			:dollar => "$",
			:caret => "^",
			:ampersand => "&",
			:asterisk => "*",

			:left_paren => "(",
			:right_paren => ")",
			:left_bracket => "[",			
			:right_bracket => "]",

			:less => "<",
			:equals => "=",
			:greater => ">",
			:plus => "+",
			:minus => "-",

			:backslash => "\\",
			:slash => "/",
			:question => "?",
			:underscore => "_",

			:keypad_0 => "0",
			:keypad_1 => "1",
			:keypad_2 => "2",
			:keypad_3 => "3",
			:keypad_4 => "4",
			:keypad_5 => "5",
			:keypad_6 => "6",
			:keypad_7 => "7",
			:keypad_8 => "8",
			:keypad_9 => "9",
			:keypad_period => ".",
			:keypad_divide => "/",
			:keypad_multiply => "*",
			:keypad_minus => "-",
			:keypad_plus => "+",
			:keypad_enter => "\n", #again, SDL docs say "\r"
			:keypad_equals => "=",

			:escape => "^[",
			:backspace => "\b",

		}

		# And to translate the other way...
		ASCII2KEY = KEY2ASCII.invert()
		# accept uppercase letters too, return same as lowercase version:
		("a".."z").each{ |letter| ASCII2KEY[letter.upcase] = ASCII2KEY[letter] }

		# All the keys that are affected by the Shift key, in lower case
		# 49 lines from here to the end of the hash
		KEY2LOWER = {
			:a => "a",
			:b => "b",
			:c => "c",
			:d => "d",
			:e => "e",
			:f => "f",
			:g => "g",
			:h => "h",
			:i => "i",
			:j => "j",
			:k => "k",
			:l => "l",
			:m => "m",
			:n => "n",
			:o => "o",
			:p => "p",
			:q => "q",
			:r => "r",
			:s => "s",
			:t => "t",
			:u => "u",
			:v => "v",
			:w => "w",
			:x => "x",
			:y => "y",
			:z => "z",

			:digit_0 => "0",
			:digit_1 => "1",
			:digit_2 => "2",
			:digit_3 => "3",
			:digit_4 => "4",
			:digit_5 => "5",
			:digit_6 => "6",
			:digit_7 => "7",
			:digit_8 => "8",
			:digit_9 => "9",

			:comma => ",",
			:period => ".",
			:semicolon => ";",
			:quote => "\'",
			:backquote => "`",
			:left_bracket => "[",			
			:right_bracket => "]",
			:slash => "/",
			:equals => "=",
			:minus => "-",
			:backslash => "\\",
		}

		# All the keys that are affected by the Shift key, in UPPER case
		# 49 lines from here to the end of the hash
		KEY2UPPER = {
			:a => "A",
			:b => "B",
			:c => "C",
			:d => "D",
			:e => "E",
			:f => "F",
			:g => "G",
			:h => "H",
			:i => "I",
			:j => "J",
			:k => "K",
			:l => "L",
			:m => "M",
			:n => "N",
			:o => "O",
			:p => "P",
			:q => "Q",
			:r => "R",
			:s => "S",
			:t => "T",
			:u => "U",
			:v => "V",
			:w => "W",
			:x => "X",
			:y => "Y",
			:z => "Z",

			:digit_0 => ")",
			:digit_1 => "!",
			:digit_2 => "@",
			:digit_3 => "#",
			:digit_4 => "$",
			:digit_5 => "%",
			:digit_6 => "^",
			:digit_7 => "&",
			:digit_8 => "*",
			:digit_9 => "(",

			:comma => "<",
			:period => ">",
			:semicolon => ":",
			:quote => "\"",
			:backquote => "~",
			:left_bracket => "{",
			:right_bracket => "}",
			:slash => "?",
			:equals => "+",
			:minus => "_",
			:backslash => "|",
		}
	end #module Key

end # module Rubygame
