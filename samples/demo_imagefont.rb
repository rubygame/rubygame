#!/usr/bin/env ruby
# encoding: utf-8


require "rubygame"
require "rubygame/imagefont"

include Rubygame


class App
  def initialize( filename, options={} )
    @filename = filename
    @basename = File.basename(filename)

    @font = ImageFont.new( Surface.load(@filename) )

    options = {
      :padding => 10,
      :message => default_message,
      :background => [50,50,50],
    }.merge(options)

    @message = options[:message]
    @padding = options[:padding]
    @background = options[:background]

    @screen = _make_screen()
    @queue  = _make_queue()
    @clock  = _make_clock()

    redraw()
  end


  def go
		catch(:app_quit) do
			loop do
				step
			end
		end
  end


  def step
    @screen.update()

    @queue.each do |event|
      case event
      when Events::QuitRequested
        quit()
      when Events::KeyPressed
        case event.key
        when :escape
          quit()
        else
          handle_keystroke(event)
        end
      end
    end

    @clock.tick()
  end


  def handle_keystroke(event)
    case event.key
    when :backspace
      self.message = @message[0..-2]
    when :return, :keypad_enter
      self.message += "\n"
    else
      unless event.string.empty?
        self.message += event.string
      end
    end
  end


  def redraw
    @screen.fill(@background)
    @font.render_to(@message, @screen, :offset => [@padding, @padding])
    @screen.update
  end


  def message
    @message.dup.freeze
  end

  def message=( new_message )
    # Increase the screen size to fit the new message, if necessary.
    new_size = _calculate_screen_size( new_message )
    new_size[0] = [new_size[0], @screen.width].max
    new_size[1] = [new_size[1], @screen.height].max

    unless new_size == @screen.size
      @screen = _make_screen( new_size )
    end

    @message = new_message

    redraw()
  end


  def default_message
    lines =
      ["Font: %s"%@basename,
       "",
       "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
       "The quick brown fox jumped over the lazy dog.",
       ""]

    # Necessary to use Array#each_slice with Ruby 1.8.6.
    require 'enumerator'

    # Add all the glyphs in the font, in rows of 32 glyphs.
    @font.glyphs.each_slice(32) { |slice|
      lines << slice.join('')
    }

    lines += ["", "Type on the keyboard to edit this text."]

    return lines.join("\n")
  end


  def quit
    throw :app_quit
  end


  private


  # Calculate how big the screen needs to be to fit the message.
  def _calculate_screen_size( message )
    w, h = @font.render_size(message)

    w += @padding * 2
    h += @padding * 2

    # Make sure it's not a super huge window.
    w = 1600 if w > 1600
    h = 1000 if h > 1000

    [w,h]
  end


  def _make_screen( size=:auto )
    size = _calculate_screen_size(@message) if size == :auto
    screen = Screen.new(size)
    screen.title = "ImageFont Test (%s)"%@basename
    return screen
  end


  def _make_queue
    Rubygame.enable_key_repeat
    return EventQueue.new { |q|
      q.enable_new_style_events
    }
  end


  def _make_clock
    return Clock.new { |c|
      c.calibrate
      c.enable_tick_events
      c.target_framerate = 30
    }
  end

end


if ARGV.length < 1
  font_name = "term16.png"
  puts <<EOF
You can pass the filename of a SFont-compatible font as the 
first argument to try it, e.g.: ./demo_imagefont.rb my_font.png

There are many sample fonts available online:   
http://user.cs.tu-berlin.de/~karlb/sfont/fonts.html
EOF
else
  font_name = ARGV[0]
end


App.new(font_name).go()
