#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2009  John Croisant
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



require "ruby-sdl-ffi/ttf"

Rubygame::VERSIONS[:sdl_ttf] = SDL::TTF.Linked_Version().to_ary


# *IMPORTANT*: this class only exists if SDL_ttf is available!
# Your code should check "defined?(Rubygame::TTF) != nil" to see if
# you can use this class, or be prepared to rescue from NameError.
# 
# TTF provides an interface to SDL_ttf, allowing TrueType Font files to be
# loaded and used to render text to Surfaces.
#
# The TTF class *must* be initialized with the #setup method before any
# TTF objects can be created or used.
#
class Rubygame::TTF


  # Initializes SDL_ttf. Optional. This will be called automatically
  # the first time SDL_ttf is needed.
  #
  def self.setup
    if( SDL::TTF.WasInit() == 0 and SDL::TTF.Init() != 0 )
      raise( Rubygame::SDLError,
             "Could not setup TTF class: #{SDL.GetError()}" )
    end
  end


  # Clean up and quit SDL_ttf, making the TTF class unusable as a result
  # (until it is setup again). This does not need to be called before Rubygame
  # exits, as it will be done automatically.
  #
  def self.quit
    if( SDL::TTF.WasInit() != 0 )
      SDL::TTF.Quit()
    end
  end



  # Create a new TTF object, which can render text to a Surface with a
  # particular font style and size.
  #
  # file:: filename of the TrueType font to use. Should be a TTF or
  #        FON file.
  # size:: point size (based on 72DPI). (That means the height in pixels from
  #        the bottom of the descent to the top of the ascent.)
  #
  def initialize( file, size )
    self.class.setup

    @struct = SDL::TTF.OpenFont( file.to_s, size )

    if( @struct.pointer.null? )
      raise Rubygame::SDLError, "Could not open font: #{SDL.GetError()}"
    end
  end


  attr_reader :struct # :nodoc:
  protected :struct


  def _get_style( style )       # :nodoc:
    return (SDL::TTF.GetFontStyle(@struct) & style == style)
  end


  # Sets the style and returns the old value.
  #
  def _set_style( enable, style ) # :nodoc:
    old = SDL::TTF.GetFontStyle(@struct)
    if( !enable and (old & style == style ) )
			SDL::TTF.SetFontStyle( @struct, old ^ style )
      return true
    elsif( enable )
      SDL::TTF.SetFontStyle( @struct, old | style )
      return false
    else
      # No change
      return enable;
    end
  end



  # True if bold mode is enabled for this font.
  #
  def bold?
    _get_style( SDL::TTF::STYLE_BOLD )
  end
  alias :bold :bold?


  # Enable or disable bold mode for this font. Returns the old value.
  #
  def bold=( enabled )
    _set_style( enabled, SDL::TTF::STYLE_BOLD )
  end



  # True if italic mode is enabled for this font.
  #
  def italic?
    _get_style( SDL::TTF::STYLE_ITALIC )
  end
  alias :italic :italic?


  # Enable or disable italic mode for this font. Returns the old
  # value.
  #
  def italic=( enabled )
    _set_style( enabled, SDL::TTF::STYLE_ITALIC )
  end



  # True if underline mode is enabled for this font.
  #
  def underline?
    _get_style( SDL::TTF::STYLE_UNDERLINE )
  end
  alias :underline :underline?


  # Enable or disable underline mode for this font. Returns the old
  # value.
  #
  def underline=( enabled )
    _set_style( enabled, SDL::TTF::STYLE_UNDERLINE )
  end


  # Return the biggest height (bottom to top; in pixels) of all glyphs
  # in the font.
  #
  def height
    SDL::TTF.FontHeight( @struct )
  end


  # Return the biggest ascent (baseline to top; in pixels) of all
  # glyphs in the font.
  #
  def ascent
    SDL::TTF.FontAnscent( @struct )
  end


  # Return the biggest descent (baseline to bottom; in pixels) of all
  # glyphs in the font.
  #
  def descent
    SDL::TTF.FontDescent( @struct )
  end


  # Return the recommended distance (in pixels) from a point on a line
  # of text to the same point on the line of text below it.
  #
  def line_skip
    SDL::TTF.FontLineSkip( @struct )
  end



  # The width and height the text would be if it were rendered,
  # without the overhead of actually rendering it.
  #
  def size_text( text )
    SDL::TTF.SizeText(@struct, text)
  end


  # The width and height the UTF-8 encoded text would be if it were
  # rendered, without the overhead of actually rendering it.
  #
  def size_utf8( text )
    SDL::TTF.SizeUTF8(@struct, text)
  end


  # The width and height the Unicode text would be if it were
  # rendered, without the overhead of actually rendering it.
  #
  def size_unicode( text )
    SDL::TTF.SizeUNICODE(@struct, text)
  end



  # Does the heavy lifting for the render methods.
  #
  def _render( text, smooth, color, back, shaded, blended, solid ) # :nodoc;

    color = SDL::Color.new( Rubygame::Color.make_sdl_rgba(color) )

    if back
      back = SDL::Color.new( Rubygame::Color.make_sdl_rgba(back) )
    end

    surf =
      if smooth
        if back
          shaded.call( @struct, text, color, back )
        else
          blended.call( @struct, text, color )
        end
      else
        if back
          s = solid.call( @struct, text, color )
          SDL::SetColors( s, back.pointer, 0, 1 )
          SDL::SetColorKey( s, 0, 0 );
          s
        else
          solid.call( @struct, text, color )
        end
      end

    if surf.pointer.null?
      raise Rubygame::SDLError, "Could not render text: #{SDL.GetError()}"
    end

    return Rubygame::Surface.new( surf )

  end


  # Renders a string to a Surface with the font's style and the given
  # color(s).
  #
  # text::   the text string to render
  # smooth:: Use anti-aliasing if true. Enabling this makes the text
  #          look much nicer (smooth curves), but is much slower.
  # color::  the color to render the text, in the form [r,g,b]
  # back::   the color to use as a background for the text. This
  #          option can be omitted to have a transparent background.
  #
  def render( text, smooth, color, back=nil )
    _render( text, smooth, color, back,
             SDL::TTF.method(:RenderText_Shaded),
             SDL::TTF.method(:RenderText_Blended),
             SDL::TTF.method(:RenderText_Solid) )
  end


  # Renders a UTF-8 string to a Surface with the font's style and the
  # given color(s).
  #
  # text::   the text string to render
  # smooth:: Use anti-aliasing if true. Enabling this makes the text
  #          look much nicer (smooth curves), but is much slower.
  # color::  the color to render the text, in the form [r,g,b]
  # back::   the color to use as a background for the text. This
  #          option can be omitted to have a transparent background.
  #
  def render_utf8( text, smooth, color, back=nil )
    _render( text, smooth, color, back,
             SDL::TTF.method(:RenderUTF8_Shaded),
             SDL::TTF.method(:RenderUTF8_Blended),
             SDL::TTF.method(:RenderUTF8_Solid) )
  end


  # Renders a Unicode string to a Surface with the font's style and
  # the given color(s).
  #
  # text::   the text string to render
  # smooth:: Use anti-aliasing if true. Enabling this makes the text
  #          look much nicer (smooth curves), but is much slower.
  # color::  the color to render the text, in the form [r,g,b]
  # back::   the color to use as a background for the text. This
  #          option can be omitted to have a transparent background.
  #
  def render_unicode( text, smooth, color, back=nil )
    _render( text, smooth, color, back,
             SDL::TTF.method(:RenderUNICODE_Shaded),
             SDL::TTF.method(:RenderUNICODE_Blended),
             SDL::TTF.method(:RenderUNICODE_Solid) )
  end


end
