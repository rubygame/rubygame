#!/usr/bin/env ruby

# Original script was contributed by ageldama (Yun, Jonghyouk)

require 'encoding/character/utf-8'
require 'rubygame'

# Initialize Rubygame
Rubygame.init
screen = Rubygame::Screen.set_mode([320,200])
queue = Rubygame::EventQueue.new

# Initialize fonts

fontname = 'freesansbold.ttf'
str = u'abc123하이~'
if ARGV[0]
  if File.exist?(File.expand_path(ARGV[0]))
    fontname = File.expand_path(ARGV[0])
    str = ARGV[1..-1].join(" ")
  else
    str = ARGV[0..-1].join(" ")
  end
else
  puts <<EOF
This script demonstrates UTF8 (8-bit Unicode Transformation Format) text
rendered with TTF fonts. This allows you to display international symbols
in your games.

Unfortunately, the sample font that is distributed with rubygame
(freesansbold.ttf) cannot display all characters correctly.

If you like, you can give some arguments to this script to try it out:
  1) A path to a different TTF font to use. (optional)
  *) A custom string to display.
EOF
end

Rubygame::TTF.setup
fnt = Rubygame::TTF.new(fontname, 20)

loop do
  queue.each do |event|
    case event
    when Rubygame::KeyDownEvent
      Rubygame::TTF.quit
      Rubygame.quit
      exit
    end
  end

  screen.fill([0, 0, 0])
  surf_str = fnt.render_utf8(str, true, [0xff, 0xff, 0xff])
  surf_str.blit(screen, [10, 10])
  screen.update
end
