#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"
require "rubygame/sfont"
include Rubygame

def main(*args)
  font_name = ""

	if args.length < 1
    font_name = "term16.png"
		puts <<EOF
You can pass the filename of a SFont-compatible font as the 
first argument to try it, e.g.: ./demo_sfont.rb my_font.png

There are many sample fonts available online:   
http://user.cs.tu-berlin.de/~karlb/sfont/fonts.html
EOF
  else
    font_name = args[0]
	end

  screen = Screen.set_mode([700,400])
  queue = EventQueue.new()
  queue.ignore = [ActiveEvent,MouseMotionEvent,MouseUpEvent,MouseDownEvent]


  screen.title = "SFont Test (%s)"%font_name
  font = SFont.new(font_name)
  renders = []
  renders << font.render("This font is: %s"%font_name)
  renders << font.render("I say, \"I love pie!\"")
  renders << font.render("I could eat #{Math::PI} pies.")
  renders << font.render("0 1 2 3 4 5 6 7 8 9")
  renders << font.render("!@\#$%^&*()[]{}<>;:/\\+=-_'`\"")
  renders << font.render("abcdefghijklmnopqrstuvwxyz")
  renders << font.render("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

  (renders.length).times do |i|
    renders[i].blit(screen,[10,10+font.height*i])
  end
  screen.update()

		queue.wait()
end

main(*ARGV)
