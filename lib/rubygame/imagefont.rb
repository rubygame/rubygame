#--
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2011  John Croisant
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
#++

module Rubygame


# ImageFont is a class for loading and rendering \SFont-compatible
# font images. Unlike a TTF font, an ImageFont is loaded from a
# normal image, which contains all the glyphs (letters, numbers,
# punctuation, etc.) in one long row. Because it's an image, you can
# easily create colorful, fun, or unusual custom fonts that would be
# impossible with TTF. ImageFont supports both colorkeyed images
# (using a solid background color) and images with an alpha channel
# for true transparency.
# 
# ImageFont is more flexible than traditional \SFont, because it
# allows you to specify a custom set of glyphs, not just the default
# ASCII characters. For example, you can create a font with accented
# characters like é, ü, and ñ. ImageFont can even handle multi-byte
# characters (e.g. Japanese hiragana, katakana, and kanji), ligatures,
# emoticons, and other strings with multiple characters.
# 
# \SFont-compatible font images are simple and easy to create. The
# image contains all glyphs in a row, ordered from left to right.
# The top-left pixel of the image defines the "separator" color.
# ImageFont then scans across the top row of pixels to divide the
# image into individual glyphs. A line of one or more pixels of the
# separator color mark a division between glyphs. Everywhere else is
# interpreted to be part of a glyph.
#
# So, the image should look like this, where the lines represent the
# separator pixels at the top of the image, and A, B, C, and D
# represent the glyphs themselves:
# 
#   _ _ _ _ _
#    A B C D 
# 
# The official \SFont homepage, with information on \SFont and sample font 
# files, can be found at http://www.linux-games.com/sfont/. More 
# information on \SFont, and a useful utility for automatically generating 
# the top row for a font, can be found at: http://www.nostatic.org/sfont/
# 
class ImageFont

  # ScanError is raised by ImageFont#scan_glyphs if an error occurs
  # while scanning the font surface.
  class ScanError < RuntimeError; end


  # Returns an Array containing the default set of glyphs in an
  # ImageFont. The default set is all ASCII characters ranging from
  # <code>"!"</code> (33) to <code>"~"</code> (126):
  #
  #   !"#$%&'()*+,-./0123456789:;<=>?@
  #   ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
  #   abcdefghijklmnopqrstuvwxyz{|}~
  #
  # Note: whitespace and line breaks in the example above are for
  # readability only. The set of glyphs is actually a single row.
  #
  def self.default_glyphs
    (33..126).to_a.collect{ |i| i.chr }
  end


  # Returns a Hash The default widths of certain whitespace
  # characters, specifically space (<code>" "</code>) and tab
  # (<code>"\t"</code>). See the description of the :whitespace option
  # of ImageFont#new for information about units.
  #
  def self.default_whitespace
    {" " => "0.5em", "\t" => "1.5em"}
  end


  # Create a new ImageFont from the given Surface. May raise
  # ImageFont::ScanError if there is a problem scanning the surface.
  #
  # surface:: A Surface containing a properly-formatted
  #           SFont-compatible font. See the ImageFont class
  #           description for details about the format.
  # options:: Options hash (see below).
  #
  # Note: The surface is used directly, not copied. That means if you
  # modify the surface later, the appearance of the ImageFont will be
  # affected. If you don't want that, you should pass a copy of the
  # surface to this method, e.g.
  # <code>ImageFont.new( my_surface.dup )</code>
  #
  # Recognized keys for the options hash are:
  #
  # +:colorkey+::   How to handle the given surface's colorkey. Can be
  #                 +:auto+, +:keep+, or an argument to be passed to
  #                 Surface#colorkey=. Default: +:auto+.
  #
  #                 * +:keep+ means the surface's colorkey will not be
  #                   modified.
  #
  #                 * +:auto+ means the ImageFont will guess what the
  #                   colorkey should be, using some simple rules.
  #                   Currently, those rules are:
  #
  #                   * If the surface already has a colorkey, do not
  #                     change the colorkey.
  #                   * If the surface has an alpha channel (see
  #                     Surface#unflatten), do not change the
  #                     colorkey.
  #                   * Otherwise, set the colorkey to the color of
  #                     the bottom left pixel of the image.
  #
  # +:glyphs+::     An Array of strings listing every glyph in the
  #                 font, in the order they appear in the surface.
  #                 See ImageFont.default_glyphs for the default list.
  #
  # +:whitespace+:: A Hash describing how wide to render certain
  #                 whitespace characters (e.g. space, tab). See
  #                 ImageFont.default_whitespace for the defaults. If
  #                 a character is listed in both #glyphs and
  #                 #whitespace, #whitespace takes precedence.
  #
  #                 Each hash key is a String containing a single
  #                 whitespace character, and each value is a String
  #                 or an integer describing how wide to render that
  #                 whitespace character. The value can be:
  #
  #                 * <code>"__em"</code> (e.g. "0.5em", "2em").
  #                   Defines the width of the character as a multiple
  #                   of the font's #height. E.g. if the font height
  #                   is 16 pixels, "0.5em" means 8 pixels, and "2em"
  #                   means 32 pixels. The result is rounded to the
  #                   nearest integer after multiplication.
  #
  #                 * <code>"__px"</code> (e.g. "10px"). Defines the
  #                   width as a specific number of pixels. Floats are
  #                   rounded to the nearest integer.
  #
  #                 * An integer (e.g. 10). Same as "__px".
  #
  #
  # Examples:
  #
  # * Simplest form, using all the defaults:
  #
  #     include Rubygame
  #     my_font_surf = Surface.load("my_font.png")
  #     my_font1 = ImageFont.new( my_font_surf )
  #
  # * Using an explicit colorkey:
  #
  #     my_font2 = ImageFont.new( my_font_surf, :colorkey => :blue )
  #
  # * Using a custom set of glyphs to render a non-English language:
  #
  #     # encoding: UTF-8
  #     hiragana_surf = Surface.load("hiragana.gif")
  #     glyphs = ["あ", "い", "う", "え", "お"] # ... etc.
  #     hiragana = ImageFont.new( hiragana_surf, :glyphs => glyphs )
  #
  # * Using a custom set of glyphs to render emoticons.
  # 
  #     emotes_surf = Surface.load("emoticons.png")
  #     glyphs = [":)", ":(", ":P", "^_^", ":lol:", "(heart)"]
  #     emotes = ImageFont.new( emotes_surf, :glyphs => glyphs )
  # 
  # * Using custom whitespace widths:
  #
  #     whitespace = {" " => "0.4em", "\t" => "20px"}
  #     my_font3 = ImageFont.new( my_font_surf, :whitespace => whitespace )
  #
  # * Using all options at once:
  # 
  #     my_font4 = ImageFont.new( my_font_surf, :colorkey => :blue,
  #                                             :whitespace => whitespace,
  #                                             :glyphs => glyphs )
  #    
  #
  def initialize( surface, options={} )
    options = {
      :colorkey => :auto,
      :glyphs => self.class.default_glyphs,
      :whitespace => self.class.default_whitespace,
    }.merge(options)

    unless surface.is_a? Rubygame::Surface
      raise TypeError, "invalid Surface: #{surface.inspect}"
    end

    @surface = surface

    case options[:colorkey]
    when :auto
      if @surface.flat? and @surface.colorkey.nil?
        # Read the colorkey from the bottom left pixel
        @surface.colorkey = @surface.get_at([0, @surface.height - 1])
      else
        # Do not modify colorkey
      end
    when :keep
      # Do not modify colorkey
    else
      @surface.colorkey = options[:colorkey]
    end

    @glyphs = options[:glyphs].dup.freeze
    @rects = {}
    scan_glyphs

    @whitespace = options[:whitespace].dup.freeze

    @tokens = _build_token_regexp
  end


  # See ImageFont.new's +surface+ arg. Note: You should call
  # #scan_glyphs if you modify or replace the surface.
  # 
  attr_accessor :surface


  # Array of glyphs in the font. See ImageFont.new's +:glyphs+ option.
  # Use #glyphs= to modify glyphs.
  # 
  attr_reader :glyphs

  # Replace the glyphs Array.
  # Equivalent to ImageFont.new's +:glyphs+ option.
  # Note: You should call #scan_glyphs after setting glyphs.
  # 
  def glyphs=( new_glyphs )
    @glyphs = new_glyphs.dup.freeze
    @tokens = _build_token_regexp
    nil
  end
  
  # Hash describing the widths of certain whitespace characters.
  # See ImageFont.new's +:whitespace+ option.
  # Use #whitespace= to modify whitespace.
  #
  attr_reader :whitespace

  # Replace the whitespace Hash.
  # Equivalent to ImageFont.new's +:whitespace+ option.
  # 
  def whitespace=( new_whitespace )
    @whitespace = new_whitespace.dup.freeze
    @tokens = _build_token_regexp
    nil
  end
  

  # Scans the surface to determine the position and size of each
  # individual glyph. You should call this if you modify or replace
  # #surface or #glyphs, to make sure the ImageFont stays in sync.
  #
  # May raise ImageFont::ScanError if there is a problem scanning the
  # surface.
  #
  def scan_glyphs
    @rects = {}
    separator = @surface.get_at([0,0])
    height = @surface.height
    cur_x = 0

    @glyphs.each do |glyph|
      start_x = cur_x

      # Scan for the start of the glyph.
      begin
        while @surface.get_at([cur_x,0]) == separator
          cur_x += 1
        end
      rescue IndexError
        raise( ScanError, "ran out of bounds while scanning for " +
               "start of glyph: " + glyph.inspect )
      end

      start_x = cur_x

      # Scan for the end of the glyph.
      begin
        while @surface.get_at([cur_x,0]) != separator
          cur_x += 1
        end
      rescue IndexError
        raise( ScanError, "ran out of bounds while scanning for " +
               "end of glyph: " + glyph.inspect )
      end

      width = cur_x - start_x

      @rects[glyph] = Rubygame::Rect.new([start_x, 0, width, height])
    end

    nil
  end


  def to_s # :nodoc:
    "#<%s>"%self.class
  end

  def inspect # :nodoc:
    "#<%s:0x%x @surface=%s>"%[self.class, object_id, @surface]
  end


  # Returns the height of the font, in pixels. This is the same as the
  # height of the surface.
  #
  def height
    @surface.height
  end


  # call-seq:
  #   render_size( text )  ->  [w,h]
  # 
  # Calculates and returns the Surface size necessary to #render the
  # given text.
  #
  def render_size( text )
    whitespace = _parse_whitespace

    cur_x = cur_y = 0
    max_w = max_h = 0
    font_height = height()

    # Is String#each_char available? (Ruby 1.8.7+)
    # If not, fall back on #each_byte.
    meth = (text.respond_to? :each_char) ? (:each_char) : (:each_byte)

    text.method(meth).call { |char|
      # each_byte can yield a Fixnum in some Ruby versions.
      char = char.chr if char.is_a? Fixnum

      if whitespace[char]
        cur_x += whitespace[char]
      elsif @rects[char]
        cur_x += @rects[char].width
      elsif char == "\n"
        cur_x = 0
        cur_y += font_height
      end

      max_w = cur_x if cur_x > max_w
      max_h = (cur_y+font_height) if (cur_y+font_height) > max_h
    }

    [max_w, max_h]
  end


  # Renders the text onto a new Surface, and returns the Surface.
  def render( text )
    size = render_size(text)
    surf = Rubygame::Surface.new(size, :alpha => true)
    render_to( text, surf )
    surf
  end


  # Renders the given text onto the destination Surface.
  #
  # text::    The text to render.
  # dest::    The destination Surface to render the text on.
  # options:: Options hash (see below).
  # 
  # Recognized keys for the options hash are:
  # 
  # :offset:: Shift the position of all text by [x,y] pixels.
  #           Default: [0,0].
  #
  def render_to( text, dest, options={} )
    options = {
      :offset => [0,0]
    }.merge(options)

    whitespace = _parse_whitespace

    start_x, start_y = options[:offset][0,2]
    cur_x, cur_y = start_x, start_y
    font_height = height()

    text.scan(@tokens) { |token|
      if whitespace[token]
        cur_x += whitespace[token]
      elsif @rects[token]
        @surface.blit(dest, [cur_x, cur_y], @rects[token])
        cur_x += @rects[token].width
      elsif token == "\n"
        cur_x = start_x
        cur_y += font_height
      end
    }

    nil
  end


  private


  # Builds a Regexp that matches any of the @glyphs or @whitespace, or
  # "\n" (but nothing else). This regexp is used in #render_to to scan
  # the text and break it up into an array of individual tokens.
  # 
  def _build_token_regexp
    tokens = (@glyphs + @whitespace.keys + ["\n"]).uniq

    # Sort by string length (descending), so that the Regexp gets the
    # largest possible match.
    tokens.sort!{|a,b| b.length <=> a.length }

    # For each token, escape any chars that have special Regexp
    # meaning, so they don't mess up the final Regexp.
    escape = /\.|\?|\*|\+|\^|\$|\||\(|\)|\\|\{|\}|\[|\]/
    tokens.collect!{ |t| t.gsub(escape, "\\\\\\0") }

    # Return the final Regexp.
    /#{tokens.join("|")}/u
  end


  def _parse_whitespace
    whitespace = {}

    @whitespace.each { |char,width|
      case width
      when /([-\d.]+) *em/i
        whitespace[char] = ($1.to_f * height).round
      when /([-\d.]+) *px/i
        whitespace[char] = $1.to_f.round
      when Numeric
        whitespace[char] = width.round
      else
        warn( "Unrecognized width for whitespace " +
              char.inspect + ": " + width.inspect )
      end
    }

    whitespace
  end

end

end
