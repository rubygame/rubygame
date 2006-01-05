#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"

def wait_for_keypress(queue)
    catch :keypress do
        loop do
            queue.get.each do |event|
                case(event)
                    when Rubygame::QuitEvent
                        throw :rubygame_quit
                    when Rubygame::KeyDownEvent
                        if event.key == Rubygame::K_ESCAPE
                            throw :rubygame_quit
                        else
                            throw :keypress
                        end
                end
            end
        end
    end
end

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
		screen = Rubygame::Screen.set_mode([700,400])
		queue = Rubygame::Queue.instance()

		screen.set_caption("SFont Test (%s)"%args[0])
		font = Rubygame::SFont.new(args[0])
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

		wait_for_keypress(queue)
	end
end

main(*ARGV)
