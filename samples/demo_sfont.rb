#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"
include Rubygame

def main(*args)
	if args.length < 1
		puts
		puts "   Download a SFont-compatible font (there are lots of them at"
		puts "   http://user.cs.tu-berlin.de/~karlb/sfont/fonts.html) and pass"
		puts "   it as the first argument, e.g. './demo_sfont.rb my_font.png'"
		puts
		puts "   An example SFont-compatible font (term16.png) is included"
		puts "   in this directory for your convenience."
		return
	end

	catch :rubygame_quit do
		screen = Screen.set_mode([700,400])
		queue = EventQueue.new()
    queue.filter = [ActiveEvent,MouseMotionEvent,MouseUpEvent,MouseDownEvent]


		screen.set_caption("SFont Test (%s)"%args[0])
		font = SFont.new(args[0])
		renders = []
		renders << font.render("This is: %s"%args[0])
		renders << font.render("I say, \"I love pie!\"")
		renders << font.render("I could eat 3.1415926 pies.")
		renders << font.render("0 1 2 3 4 5 6 7 8 9")
		renders << font.render("!@\#$%^&*()[]{}<>;:/\\+=-_'`")
		renders << font.render("abcdefghijklmnopqrstuvwxyz")
		renders << font.render("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

		(renders.length).times do |i|
			renders[i].blit(screen,[0,font.height*i])
		end
		screen.update()

		queue.wait()
	end
end

main(*ARGV)
