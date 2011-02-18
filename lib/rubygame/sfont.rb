#--
# Rubygame -- Ruby code and bindings to SDL to facilitate game creation
# Copyright (C) 2004-2007  John Croisant
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++

module Rubygame

  # *NOTE*: SFont is DEPRECATED and will be removed in Rubygame 3.0!
  # Use ImageFont instead.
  # 
  # *NOTE*: you must require 'rubygame/sfont' manually to gain access to
  # Rubygame::SFont. It is not imported with Rubygame by default!
  # 
  # SFont is a type of bitmapped font, which is loaded from an image file
  # with a meaningful top row of pixels, and the font itself below that. The
  # top row provides information about what parts of of the lower area
  # contains font data, and which parts are empty.
  # 
  # The image file should contain all of the glyphs on one row, with the
  # colorkey color at the bottom-left pixel and the "skip" color at the 
  # top-left pixel.
  # 
  # The colorkey color is applied to the image file when it is loaded, so
  # that all pixels of that color appear transparent. Alternatively, if the
  # alpha value of pixel [0,0] is 0 (that is, if it is fully transparent),
  # the image file is assumed to have a proper alpha channel, and no colorkey
  # is applied. The skip color is used in the top row of pixels to indicate
  # that all the  pixels below it contain empty space, and that the next 
  # pixel that is not the skip color marks the beginning of the next glyph.
  # 
  # The official SFont homepage, with information on SFont and sample font 
  # files, can be found at http://www.linux-games.com/sfont/. More 
  # information on SFont, and a useful utility for automatically generating 
  # the top row for a font, can be found at: http://www.nostatic.org/sfont/

  class SFont
    @@default_glyphs = [\
      "!",'"',"#","$","%","&","'","(",")","*","+",",","-",".","/","0",
      "1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@",
      "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
      "Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`",
      "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
      "q","r","s","t","u","v","w","x","y","z","{","|","}","~"]

    # Returns an array of strings, each string a single ASCII character
    # from ! (33) to ~ (126). This is the default set of characters in a
    # SFont. The full set is as follows:
    # 
    #   ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @
    #   A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ `
    #   a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~
    def SFont.default_glyphs
      @@default_glyphs
    end

    # Create a now SFont instance.
    # 
    # This function takes these arguments:
    # filename:: the name of the image file from which the font should be
    #            loaded. Or, a Surface with a font image on it. The
    #            Surface will be copied onto separate Surfaces for each
    #            glyph, so the original Surface can be recycled.
    # glyphs::   array of strings, one for each glyph, in the order they
    #            are found in the image file. If glyphs is not provided,
    #            or is nil, it is assumed to be the normal SFont order;
    #            that is, ASCII characters ! (33) to ~ (126). See 
    #            SFont.default_glyphs for a full list.
    # spacew::   represents the width of a space character ( ). You can
    #            either specify the width in pixels, or specify a 
    #            character whose width, as found in the image, should be
    #            used. Alternatively, you could add a space character to
    #            the list of glyphs, and to the image file. If +spacew+
    #            is not given or is nil, and the space character is not 
    #            in the list of glyphs, it will have the same width as
    #            the double-quote character (").
    def initialize(filename,glyphs=nil,spacew=nil)
      Rubygame.deprecated("Rubygame::SFont", "3.0",
                          "Use Rubygame::ImageFont instead.")

      # load the surface containing all the glyphs
      surface = nil
      if filename.is_a? String
        surface = Surface.load(filename)
      elsif filename.is_a? Surface
        surface = filename
      end
      @height = surface.height
      colorkey = surface.get_at(0,@height-1)

      # set colorkey if "transparent" color is not actually transparent
      if colorkey[3] != 0
        surface.colorkey = colorkey[0..2]
      end

      @glyphs = {}
      @skip = surface.get_at(0,0)[0..2]

      # split the glyphs into separate surfaces
      glyphs = (glyphs or @@default_glyphs)
      start_x = 2
      glyphs.each{ |glyph| start_x = load_glyph(surface,glyph,start_x) }

      if not glyphs.include?(" ")
        if spacew == nil
          spacew = @glyphs['"'].width
        elsif spacew.kind_of? Numeric
          spacew = spacew.to_i
        elsif spacew.kind_of? String
          if glyphs.include? spacew
            spacew = @glyphs[spacew].width
          else
            spacew = @glyphs['"'].width
          end
        else
          raise(ArgumentError,"spacew must be Numeric, String, \
or nil (got %s)"%[spacew.class])
        end
        @glyphs[" "] = Surface.new([spacew,@height])
      end
    end

    # Return the height of the font, in pixels. This is the same as the
    # height of the image file (all glyphs are the same height). 
    attr_reader :height

    # This is a private function which is used to parse the font image.
    # 
    # Create a Surface for a single glyph, and store it as a value in the
    # +@glyphs+ hash, indexed by the glyph (string) it represents. 
    # 
    # Starting at a pixel in the "skip" region to the left of the glyph.
    # Scans to the right along the top row until it finds a non-skip pixel
    # (this is where the glyph starts) and then scans until it finds a skip
    # pixel (this is where the glyph ends.
    # 
    # Returns the x value it stops at, plus 1. This should be fed back in
    # for the +start_x+ of the next glyph.
    # 
    # This _private_ method takes these arguments:
    # surface:: the Surface containing all glyph image data.
    # glyph::   a string containing the current glyph
    # start_x:: the x position to start scanning at. 
    def load_glyph(surface,glyph,start_x) # :doc:
      # find where this glyph starts
      begin
        while(surface.get_at(start_x,0)[0..2] == @skip)
          start_x += 1
        end
      rescue IndexError
        return -1
      end

      end_x = start_x

      # find how wide this glyph is
      begin
        while(surface.get_at(end_x,0)[0..2] != @skip)
          end_x += 1
        end
      rescue IndexError
        return -1
      end

      # make a new surface for the glyph and blit the image onto it
      rect = Rect.new(start_x, 0, end_x-start_x, surface.h)
      @glyphs[glyph] = Surface.new(rect.size)
      surface.blit(@glyphs[glyph],[0,0],rect)
      
      return end_x+1
    end
    private :load_glyph

    # This is a private function which is used to render a string.
    # 
    # Blit a single glyph to a Surface at the given position.
    # 
    # This _private_ method takes these arguments:
    # glyph::   a string containing the glyph to blit.
    # surface:: the target surface to blit onto.
    # pos::     an Array of the x and y values to blit the glyph to.
    def blit_glyph(glyph,surface,pos) # :doc:
      @glyphs[glyph].blit(surface,pos)
    end
    private :blit_glyph

    # Pretends to render the given string, and returns the width in pixels
    # of the surface that would be created if it were rendered using 
    # SFont#render. If you want the height too, you can get it with 
    # SFont#height (the height is contant).
    # 
    # This method takes this argument:
    # string:: the string to pretend to render.
    def string_width(string)
      w = 0
      string.each_byte { |glyph| w += @glyphs["%c"%[glyph]].width }
      return w
    end

    # Renders the given string to a Surface, and returns that surface.
    # 
    # This method takes this argument:
    # string:: the text string to render.
    def render(string)
      size = [self.string_width(string),self.height]
      render = Surface.new(size)
      x = 0
      string.each_byte { |glyph| 
        blit_glyph("%c"%[glyph],render,[x,0])
        x += @glyphs["%c"%[glyph]].width
      }
      return render
    end
  end # class SFont

end # module Rubygame
