#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2011  John Croisant
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



# Surface represents an image, a block of colored pixels arranged in a
# 2D grid. You can load image files to a new Surface with #load,
# or create an empty one with Surface.new and draw shapes on it with
# #draw_line, #draw_circle, and all the rest.
#
# One of the most important Surface concepts is #blit, copying image
# data from one Surface onto another. By blitting Surfaces onto the
# Screen (which is a special type of Surface) and then using
# Screen#update, you can make images appear for the player to see.
#
# As of Rubygame 2.3.0, Surface includes the Rubygame::NamedResource
# mixin module, which can perform autoloading of images on demand,
# among other things.
#
class Rubygame::Surface

  include Rubygame::NamedResource

  #--
  #
  # Image loading code is defined in image.rb
  #
  #++


  attr_reader :struct # :nodoc:
  protected :struct


  # call-seq:
  #   new( size, opts={} )
  #   new( size, depth=0, flags=[] )  # DEPRECATED
  # 
  # Create and initialize a new Surface.
  #
  # A Surface is a grid of image data which you blit (i.e. copy) onto
  # other Surfaces. Since the Screen is also a Surface, Surfaces can
  # be blit to the screen; this is the most common way to display
  # images on the screen.
  #
  # This method may raise SDLError if the SDL video subsystem could
  # not be initialized for some reason.
  #
  # This function takes these arguments:
  # 
  # size:: Surface size to create, [width, height] (in pixels).
  # 
  # opts::
  #   Hash of options. The possible options are:
  # 
  #   :depth::    Requested color depth (in bits per pixel). If this
  #               is 0 or unspecified, Rubygame automatically chooses
  #               the depth based on the Screen mode or system depth.
  #               Possible values: 0, 8, 15, 16, 24, 32. Default: 0.
  # 
  #   :alpha::    If true, the Surface will have a per-pixel alpha
  #               channel (i.e. it will not be #flat?). Only Surfaces
  #               with depth 32 can have an alpha channel. If an
  #               incompatible :depth option is specified, a warning
  #               message will be printed and depth 32 used instead.
  #               Default: false.
  # 
  #   :opacity::  Initial value for #opacity. Default: 1.0.
  # 
  #   :colorkey:: Initial value for #colorkey. Default: nil.
  # 
  #   :hardware:: If true, try to create a hardware accelerated
  #               Surface (using a graphics card), which may be very
  #               fast to blit onto other hardware accelerated
  #               Surfaces, but somewhat slower to access in other
  #               ways. Creates a normal, non-accelerated Surface if
  #               hardware Surfaces are not available. Default: false.
  # 
  #   :masks::    For advanced users. Set the Surface's color masks
  #               manually, as [r,g,b,a]. If this is nil or
  #               unspecified, the color masks are calculated
  #               automatically.
  # 
  # For backwards compatibility, you can provide the following
  # arguments instead of the ones above. However, this form is
  # DEPRECATED and will be removed in Rubygame 3.0:
  # 
  # size::  Surface size to create, [width, height] (in pixels).
  # depth:: requested color depth (in bits per pixel). If depth is 0 (default),
  #         automatically choose a color depth: either the depth of the Screen
  #         mode (if one has been set), or the greatest color depth available
  #         on the system.
  # flags:: an Array or Bitwise-OR'd list of zero or more of the following
  #         flags (located in the Rubygame module, e.g. Rubygame::SWSURFACE).
  #         This argument may be omitted, in which case the Surface
  #         will be a normal software surface (this is not necessarily a bad
  #         thing).
  #         SWSURFACE::   (default) request a software surface.
  #         HWSURFACE::   request a hardware-accelerated surface (using a
  #                       graphics card), if available. Creates a software
  #                       surface if hardware surfaces are not available.
  #         SRCCOLORKEY:: request a colorkeyed surface. #set_colorkey will
  #                       also enable colorkey as needed. For a description
  #                       of colorkeys, see #set_colorkey.
  #         SRCALPHA::    request an alpha channel. #set_alpha will
  #                       also enable alpha. as needed. For a description
  #                       of alpha, see #alpha.
  #
  def initialize( size, *args )

    # Cheating a bit. First arg can be a SDL::Surface to wrap it.
    #
    if( size.kind_of? SDL::Surface )
      surf = size
      if( surf.pointer.null? )
        raise Rubygame::SDLError, "Surface cannot wrap NULL Surface!"
      else
        @struct = surf
        @opacity ||= @struct.format.alpha / 255.0
      end
    else
      if args.empty? or args[0].is_a? Hash
        args = _parse_args( size, args[0] )
        @struct = SDL.CreateRGBSurface( args[:flags],
                                        args[:width], args[:height],
                                        args[:depth], *args[:masks] )
        if args[:opacity]
          self.opacity = args[:opacity]
        else
          @opacity ||= @struct.format.alpha / 255.0
        end

        if args.has_key?(:colorkey)
          self.colorkey = args[:colorkey]
        end

      else
        # Support old argument style for backwards compatibility.
        _initialize_old( size, *args )
        @opacity ||= @struct.format.alpha / 255.0
      end
    end

  end


  # This method is used by #dup and #clone.
  def initialize_copy( original ) # :nodoc:
    ostruct = original.struct
    # Copies the Surface by "converting" it to its own format.
    @struct = SDL.ConvertSurface( ostruct, ostruct.format, ostruct.flags )
  end

  if false
    # Returns a new copy of the Surface. The copy will not be frozen,
    # even if the original was frozen.
    def dup
      # Stub method for documentation purposes.
    end

    # Like #dup, but if the original was frozen, the copy will also be
    # frozen.
    def clone
      # Stub method for documentation purposes.
    end
  end

  
  private


  def _parse_args( size, options )
    options ||= {}

    unless size.is_a?(Array) and size.size == 2 and
        size.all?{ |i| i.is_a?(Integer) and i > 0 }
      raise( TypeError, "Invalid size: " + size.inspect +
             " (expected [width,height] array of integers >= 0)" )
    end

    depth = options[:depth] || 0
    unless depth.is_a?(Integer) and depth >= 0
      raise( TypeError, "Invalid depth: " + depth.inspect +
             " (expected integer >= 0)" )
    end

    flags = 0

    alpha = options.has_key?(:alpha) ? options[:alpha] : false
    if alpha
      unless depth == 0 or depth == 32
        Kernel.warn("WARNING: Cannot create a #{depth}-bit Surface "+
                    "with an alpha channel. Using depth 32 instead.")
      end
      depth = 32
      flags |= SDL::SRCALPHA
    end

    # No depth determined yet, so choose one automatically
    if depth == 0
      vs = SDL.GetVideoSurface()
      if not vs.pointer.null?
        # Color depth is retrieved from the video surface (Screen).
        depth = vs.format.BitsPerPixel
      else
        # We can only get the system color depth when the
        # video system has been initialized.
        if( Rubygame.init_video_system == 0 )
          depth = SDL.GetVideoInfo().vfmt.BitsPerPixel
        else
          # No luck, use depth 24 just to be safe.
          depth = 24
        end
      end
    end

    masks = options[:masks]
    if masks.nil?
      masks = _make_masks( depth, alpha )
    else
      unless masks.size == 4 and masks.all?{|m| m.is_a?(Integer) and m >= 0}
        raise( TypeError, "Invalid masks: " + masks.inspect +
               " (expected [r,g,b,a] array of integers >= 0)" )
      end
    end

    flags |= SDL::HWSURFACE if options[:hardware]    

    args ={
      :width  => size[0],
      :height => size[1],
      :depth  => depth,
      :masks  => masks,
      :flags  => flags,
    }

    if options.has_key?(:opacity)
      args[:opacity] = options[:opacity]
    end

    if options.has_key?(:colorkey)
      args[:colorkey] = options[:colorkey]
    end

    args
  end


  # Calculate color masks based on requested depth and (for 32 bit)
  # whether or not to have an alpha channel.
  def _make_masks( depth, alpha ) # :nodoc:
    a = alpha ? 0xff000000 : 0

    masks = case depth
            when 32;  [0xff0000,  0x00ff00,  0x0000ff,  a]
            when 24;  [0xff0000,  0x00ff00,  0x0000ff,  0]
            when 16;  [0x00f800,  0x0007e0,  0x00001f,  0]
            when 15;  [0x007c00,  0x0003e0,  0x00001f,  0]
            else      [       0,         0,         0,  0]
            end

    if FFI::Platform::BYTE_ORDER == FFI::Platform::BIG_ENDIAN
      masks[0,3] = masks[0,3].reverse
    end

    masks
  end


  # Initialize the Surface in the deprecated (pre-2.7) way.
  def _initialize_old( size, depth=0, flags=[] ) # :nodoc:
    Rubygame.deprecated("Rubygame::Surface#new legacy argument style", "3.0")

    unless size.kind_of? Array
      raise TypeError, "Surface size is not an Array: #{size.inspect}"
    end

    unless size.length == 2 and size.all?{ |n| n.kind_of? Numeric }
      raise ArgumentError, "Invalid Surface size: #{size.inspect}"
    end


    pixformat = nil

    vs = SDL.GetVideoSurface()

    unless( vs.pointer.null? )
      # Pixel format is retrieved from the video surface.
      pixformat = vs.format
    else
      # We can only get the system color depth when the
      # video system has been initialized.
      if( Rubygame.init_video_system == 0 )
        pixformat = SDL.GetVideoInfo().vfmt
      else
        raise(Rubygame::SDLError,
              "Could not initialize SDL video subsystem.")
      end
    end

    rmask = pixformat.Rmask
    gmask = pixformat.Gmask
    bmask = pixformat.Bmask
    amask = pixformat.Amask

    if( depth <= 0 )
      depth = pixformat.BitsPerPixel
    end

    w, h = size

    flags = Rubygame.collapse_flags(flags)

    @struct = SDL.CreateRGBSurface(flags, w, h, depth,
                                   rmask, gmask, bmask, amask)
  end


  public


  # Return the width (in pixels) of the surface.
  #
  def w
    @struct.w
  end
  alias :width :w


  # Return the height (in pixels) of the surface.
  #
  def h
    @struct.h
  end
  alias :height :h


  # call-seq:
  #   size  ->  [w,h]
  #
  # Return the surface's width and height (in pixels) in an Array.
  #
  def size
    [@struct.w, @struct.h]
  end


  # Return the color depth (in bits per pixel) of the surface.
  #
  def depth
    @struct.format.BitsPerPixel
  end


  # Return any flags the surface was initialized with
  # (as a bitwise OR'd integer).
  #
  def flags
    @struct.flags
  end


  # call-seq:
  #   masks  ->  [r,g,b,a]
  #
  # Return the color masks [r,g,b,a] of the surface. Almost everyone can
  # ignore this function. Color masks are used to separate an
  # integer representation of a color into its seperate channels.
  #
  def masks
    fmt = @struct.format
    [fmt.Rmask, fmt.Gmask, fmt.Bmask, fmt.Amask]
  end


  # call-seq:
  #   opacity  ->  Float
  #   opacity( new_value )  ->  self
  # 
  # Returns the Surface's opacity (aka "per-surface alpha") as a Float
  # ranging from 0.0 (fully transparent) to 1.0 (fully opaque).
  # The default opacity for new Surfaces is 1.0.
  # 
  # If you give an argument to this method, it acts like #opacity=,
  # except that it returns self (so you can chain method calls).
  # 
  # Opacity < 1.0 makes flat Surfaces (see #flat?) appear partially
  # transparent when blitted onto another Surface. Opacity has NO
  # EFFECT on Surfaces with a per-pixel alpha channel (i.e. non-flat
  # Surfaces).
  # 
  def opacity( *args )
    if not args.empty?
      self.opacity = args[0]
      self
    else
      @opacity
    end
  end

  # Sets the Surface's opacity (aka "per-surface alpha") as a Float
  # ranging from 0.0 (fully transparent) to 1.0 (fully opaque).
  # 
  # See also #opacity.
  # 
  def opacity=( new_value )
    raise "can't modify frozen object" if frozen?

    new_value = new_value.to_f
    new_value = 0.0 if new_value < 0.0
    new_value = 1.0 if new_value > 1.0
    @opacity = new_value

    flags = 0
    if @opacity < 1.0 or not self.flat?
      flags = SDL::SRCALPHA
    end

    SDL.SetAlpha( @struct, flags, (255 * @opacity).to_i )

    @opacity
  end


  # NOTE: This method is DEPRECATED and will be removed in Rubygame
  # 3.0. Use #opacity instead (but be aware that it ranges from 0.0 to
  # 1.0, not 0 to 255).
  #
  # Return the per-surface alpha (i.e. #opacity) of the surface. It
  # can range from 0 (full transparent) to 255 (full opaque).
  # 
  def alpha
    Rubygame.deprecated("Rubygame::Surface#alpha", "3.0")
    @struct.format.alpha
  end

  # NOTE: This method is DEPRECATED and will be removed in Rubygame
  # 3.0. Use #opacity or #opacity= instead (but be aware that it
  # ranges from 0.0 to 1.0, not 0 to 255).
  #
  # Sets the per-surface alpha (i.e. #opacity) of the surface. You can
  # do the same thing with #alpha= if you don't care about flags.
  #
  # This function takes these arguments:
  # alpha:: requested opacity of the surface. Alpha must be from 0
  #         (fully transparent) to 255 (fully opaque).
  # flags:: 0 or Rubygame::SRCALPHA (default). Most people will want the
  #         default, in which case this argument can be omitted. For advanced
  #         users: this flag affects the surface as described in the docs for
  #         the SDL C function, SDL_SetAlpha.
  #
  # Returns self.
  #
  def set_alpha( alpha, flags=Rubygame::SRCALPHA )
    Rubygame.deprecated("Rubygame::Surface#set_alpha", "3.0")

    raise "can't modify frozen object" if frozen?

    result = SDL.SetAlpha(@struct, flags, alpha.to_i)
    raise Rubygame::SDLError, SDL.GetError() unless result == 0

    @opacity = (alpha/255.0)
    return self
  end

  # Alias of #set_alpha.
  # 
  # NOTE: This method is DEPRECATED and will be removed in Rubygame
  # 3.0. Use #opacity or #opacity= instead (but be aware that it
  # ranges from 0.0 to 1.0, not 0 to 255).
  #
  def alpha=( alpha, flags=Rubygame::SRCALPHA )
    Rubygame.deprecated("Rubygame::Surface#alpha=", "3.0")

    raise "can't modify frozen object" if frozen?

    result = SDL.SetAlpha(@struct, flags, alpha.to_i)
    raise Rubygame::SDLError, SDL.GetError() unless result == 0

    @opacity = (alpha/255.0)
    return self
  end


  # call-seq:
  #   colorkey  ->  [r,g,b] or nil
  #   colorkey( new_value )  ->  self
  #
  # Return the colorkey of the surface in the form [r,g,b] (range
  # 0..255). Returns nil if there is no colorkey.
  # 
  # If you give an argument to this method, it acts like #colorkey=,
  # except that it returns self (so you can chain method calls).
  # 
  # The colorkey of a Surface is a color which will be ignored when
  # the surface is blitted, effectively turning that color
  # transparent. This is often used to make a solid background color
  # on a flat image seem transparent.
  # 
  # The colorkey has no effect on Surfaces that are not flat (see
  # #flat?). If you set a flat Surface's colorkey and then use
  # #unflatten or #to_display_alpha, pixels matching the colorkey will
  # become transparent in the new Surface returned by those methods.
  #
  def colorkey( *args )
    if not args.empty?
      self.colorkey = args[0]
      self
    else
      if( (@struct.flags & SDL::SRCCOLORKEY) == SDL::SRCCOLORKEY )
        SDL::GetRGB(@struct.format.colorkey, @struct.format)
      else
        nil
      end 
    end
  end


  # call-seq:
  #   colorkey = color
  # 
  # Set the colorkey of the surface. See #colorkey for a description
  # of what effect a colorkey has.
  #
  # color:: color to use as the colorkey, or +nil+ for no colorkey.
  #
  # For backwards compatibility, this method accepts a second
  # argument, +flags+. This argument is DEPRECATED and will no longer
  # be accepted in Rubygame 3.0.
  # 
  # flags:: For advanced users only. This flag affects the Surface as
  #         described in the docs for the SDL function
  #         SDL_SetColorkey.
  #
  def colorkey=( color, flags=:auto )
    raise "can't modify frozen object" if frozen?

    if flags == :auto
      flags = SDL::SRCCOLORKEY
    else
      Rubygame.deprecated("Rubygame::Surface#colorkey= with flags", "3.0")
    end

    if color.nil?
      color, flags = 0, 0
    else
      color = _map_sdl_color( color )
    end

    result = SDL.SetColorKey(@struct, flags, color)
    if result != 0
      raise( Rubygame::SDLError, "Could not set colorkey: " + 
             SDL.GetError() )
    end

    color
  end


  # Similar to #colorkey=. This method is DEPRECATED and will be
  # removed in Rubygame 3.0. Use #colorkey or #colorkey= instead.
  # 
  def set_colorkey( color, flags=Rubygame::SRCCOLORKEY )
    Rubygame.deprecated("Rubygame::Surface#set_colorkey", "3.0")

    raise "can't modify frozen object" if frozen?

    if color.nil?
      color, flags = 0, 0
    else
      color = _map_sdl_color( color )
    end

    result = SDL.SetColorKey(@struct, flags, color)
    if result != 0
      raise( Rubygame::SDLError, "Could not set colorkey: " + 
             SDL.GetError() )
    end

    color
  end


  # Returns the palette of the Surface, as an array of [r,g,b] arrays
  # (each component ranges from 0-255). See #set_palette for more
  # information about Surface palettes.
  # 
  # Only Surfaces with 8-bit color depth or less can have a palette.
  # If the Surface does not have a palette, this method returns nil.
  # 
  # NOTE: Surface palettes are not related to the
  # Rubygame::Color::Palette class.
  #
  # 
  def palette
    pal = @struct.format.palette
    unless pal.pointer.null?
      return pal.entries.collect { |color|  color.to_ary[0,3]  }
    end
  end


  # Replaces some or all of the colors in the Surface's palette.
  # 
  # NOTE: Surface palettes are not related to the
  # Rubygame::Color::Palette class.
  #
  # Only Surfaces with 8-bit color depth or less can have a palette.
  # The number of entries in the palette depends on the color depth.
  # For example:
  # 
  # * 1-bit = 2**1 = 2 entries
  # * 2-bit = 2**2 = 4 entries
  # * 4-bit = 2**4 = 16 entries
  # * 8-bit = 2**8 = 256 entries
  # 
  # 
  # This method takes these arguments:
  #
  # colors:: An Array of colors to apply to the palette. Each color
  #          can be [r,g,b] (0-255), a color name, or Rubygame::Color.
  # 
  # opts::   An optional Hash of zero or more of the following options:
  # 
  #          :offset:: Replace the palette starting at this index.
  #                    (Integer, default 0)
  #
  # Raises SDLError if an error if the Surface does not support a
  # palette (e.g. because its color depth is greater than 8-bit), or
  # if something went wrong. (Unfortunately SDL provides no way to
  # find out what the problem is.)
  #
  # 
  # Example:
  #
  #   include Rubygame
  #   include Rubygame::Color
  #   
  #   
  #   # Create a new 2-bit Surface.
  #   # It has 4 entries in its palette, all black by default.
  #   surf = Rubygame::Surface.new( [10,10], :depth => 2 )
  #   surf.palette
  #   # => [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
  #   
  #   
  #   # Replace entry 3:
  #   surf.set_palette( [[255,0,255]], :offset => 3 )
  #   surf.palette
  #   # => [[0, 0, 0], [0, 0, 0], [0, 0, 0], [255, 0, 255]]
  #   
  #   
  #   # Replace entries 1 and 2:
  #   surf.set_palette( [ColorRGB.new([1,0,0]), :blue], :offset => 1 )
  #   surf.palette
  #   # => [[0, 0, 0], [255, 0, 0], [0, 0, 255], [255, 0, 255]]
  #   
  #   
  #   # Reverse the palette order (palette= is an alias for set_palette):
  #   surf.palette = surf.palette.reverse
  #   # => [[255, 0, 255], [0, 0, 255], [255, 0, 0], [255, 255, 255]]
  #   
  #   
  #   # Change the palette to all red:
  #   surf.palette = [:red]*4
  #   # => [[255, 0, 0], [255, 0, 0], [255, 0, 0], [255, 0, 0]]
  #   
  #
  def set_palette( colors, opts={} )
    if @struct.format.palette.pointer.null?
      raise Rubygame::SDLError, "#{depth}-bit Surface has no palette."
    end

    raise "can't modify frozen object" if frozen?

    offset = (opts[:offset] || 0).to_i

    ncolors = colors.length
    buf = FFI::Buffer.new( SDL::Color, ncolors )
    colors.each_with_index do |color,i|
      color = SDL::Color.new( Rubygame::Color.make_sdl_rgba(color) )
      buf[i].put_bytes( 0, color.to_bytes )
    end

    result = SDL::SetPalette( @struct, SDL::LOGPAL, buf, offset, ncolors )
    unless result == 1
      raise Rubygame::SDLError, "Palette failed (reason unknown)"
    end

    return self
  end

  alias :palette= :set_palette



  # Blit (copy) all or part of the surface's image to another surface,
  # at a given position. Returns a Rect representing the area of
  # +target+ which was affected by the blit.
  #
  # This method takes these arguments:
  # target::   the target Surface on which to paste the image.
  # pos::      the coordinates of the top-left corner of the blit.
  #            Affects the area of +target+ the image data is /pasted/
  #            over. Can also be a Rect or an Array larger than 2, but
  #            width and height will be ignored.
  # src_rect:: a Rect representing the area of the source surface to get data
  #            from. Affects where the image data is /copied/ from.
  #            Can also be an Array of no less than 4 values.
  #
  def blit( target, pos, src_rect=nil )
    if not target.kind_of? Rubygame::Surface
      raise TypeError, "blit target must be a Surface"
    elsif target.frozen?
      raise "can't blit to a frozen Surface"
    end

    src_x, src_y, src_w, src_h =
      case src_rect
      when Rubygame::Rect, SDL::Rect, Array
        src_rect.to_ary
      when nil
        [0, 0] + self.size
      else
        raise( TypeError, "Invalid src_rect (expected Rect or Array, " +
               "got #{src_rect.inspect})" )
      end

    src_rect  = SDL::Rect.new([src_x,  src_y,  src_w, src_h])

    blit_x, blit_y = 
      case pos
      when Rubygame::Rect, SDL::Rect, Array, Vector2
        pos.to_ary
      else
        raise( TypeError, "Invalid pos (expected Array or Rect, " +
               "got #{pos.inspect})" )
      end

    blit_rect = SDL::Rect.new([blit_x, blit_y, src_w, src_h])

    SDL.BlitSurface( @struct, src_rect, target.struct, blit_rect )

    return Rubygame::Rect.new( blit_rect.to_ary )
  end


  # Fill all or part of a Surface with a color.
  #
  # This method takes these arguments:
  # color:: color to fill with, in the form +[r,g,b]+ or +[r,g,b,a]+ (for
  #         partially transparent fills).
  # rect::  a Rubygame::Rect representing the area of the surface to fill
  #         with color. Omit to fill the entire surface.
  #
  def fill( color, rect=nil )
    raise "can't modify frozen object" if frozen?

    unless rect.nil? or rect.kind_of? Array
      raise TypeError, "invalid fill Rect: #{rect.inspect}"
    end

    color = _map_sdl_color( color )
    rect = SDL::Rect.new( rect.to_ary ) unless rect.nil?
    SDL.FillRect( @struct, rect, color )
    return self
  end


  # Return a Rect with the same width and height as the Surface,
  # with topleft = [0,0].
  #
  def make_rect()
    return Rubygame::Rect.new( 0, 0, self.w, self.h )
  end


  # call-seq:
  #    get_at( [x,y] )
  #    get_at( x,y )
  #
  # Return the color [r,g,b,a] (0-255) of the pixel at [x,y]. If the
  # Surface does not have a per-pixel alpha channel (i.e. not #flat?),
  # alpha will always be 255. The Surface's #opacity does not affect
  # the returned alpha value.
  #
  # Raises IndexError if the coordinates are out of bounds.
  #
  def get_at( *args )
    x,y = case args.length
          when 1; args[0].to_ary.collect { |n| n.round }
          when 2; [args[0].round, args[1].round]
          else
            raise( ArgumentError,
                   "wrong number of arguments (#{args.length} for 1)" )
          end

    if( x < 0 or x >= @struct.w or y < 0 or y >= @struct.h)
      raise( IndexError, "point [%d,%d] is out of bounds for %dx%d Surface"%\
             [x, y, @struct.w, @struct.h] )
    end

    SDL.LockSurface(@struct)

    bpp = @struct.format.BytesPerPixel
    ptr = @struct.pixels + (y * @struct.pitch + x * bpp)

    pixel =
      case bpp
      when 1
        ptr.get_uint8(0)
      when 2
        ptr.get_uint16(0)
      when 3
        if( FFI::Platform::BYTE_ORDER == FFI::Platform::BIG_ENDIAN )
          (ptr.get_uint8(0) << 16)|(ptr.get_uint8(1) << 8)|ptr.get_uint8(2)
        else
          ptr.get_uint8(0)|(ptr.get_uint8(1) << 8)|(ptr.get_uint8(2) << 16)
        end
      when 4
        ptr.get_uint32(0)
      end

    SDL.UnlockSurface(@struct)

    return SDL::GetRGBA(pixel, @struct.format) 
  end


  # call-seq:
  #     set_at( [x,y], color )
  #
  # Set the color of the pixel at [x,y]. If no alpha value is given,
  # or if the Surface does not have a per-pixel alpha channel (i.e.
  # not #flat?), the pixel will be set at full opacity.
  #
  # color can be one of:
  # * an Array, [r,g,b] or [r,g,b,a] with each component in 0-255.
  # * an instance of Rubygame::ColorRGB, Rubygame::ColorHSV, etc.
  # * the name of a color in Rubygame::Color, as a Symbol or String
  #
  # Raises IndexError if the coordinates are out of bounds.
  #
  def set_at( pos, color )
    raise "can't modify frozen object" if frozen?

    x,y = pos.to_ary.collect { |n| n.round }

    if( x < 0 or x >= @struct.w or y < 0 or y >= @struct.h)
      raise( IndexError, "point [%d,%d] is out of bounds for %dx%d Surface"%\
             [x, y, @struct.w, @struct.h] )
    end

    color = _map_sdl_color( color )

    SDL.LockSurface(@struct)

    bpp = @struct.format.BytesPerPixel
    ptr = @struct.pixels + (y * @struct.pitch + x * bpp)

    case bpp
    when 1
      ptr.put_uint8(0, color)
    when 2
      ptr.put_uint16(0, color)
    when 3
      if( FFI::Platform::BYTE_ORDER == FFI::Platform::BIG_ENDIAN )
        ptr.put_uint8(0, (color >> 16) & 0xff)
        ptr.put_uint8(1, (color >> 8)  & 0xff)
        ptr.put_uint8(2, color & 0xff)
      else
        ptr.put_uint8(0, color & 0xff)
        ptr.put_uint8(1, (color >> 8)  & 0xff)
        ptr.put_uint8(2, (color >> 16) & 0xff)
      end
    when 4
      ptr.put_uint32(0, color)
    end

    SDL.UnlockSurface(@struct)

    return
  end


  # Return a string of pixel data for the Surface. Most users will not
  # need to use this method. If you want to convert a Surface into an
  # OpenGL texture, pass the returned string to the TexImage2D method
  # of the ruby-opengl library. (See samples/demo_gl_tex.rb for an
  # example.)
  #
  # (Please note that the dimensions of OpenGL textures must be powers
  # of 2 (e.g. 64x128, 512x512), so if you want to use a Surface as an
  # OpenGL texture, the Surface's dimensions must also be powers of
  # 2!)
  #
  def pixels
    len = @struct.pitch * @struct.h
    SDL.LockSurface(@struct)
    pix = @struct.pixels.get_bytes(0, len)
    SDL.UnlockSurface(@struct)
    return pix
  end


  # Overwrite the Surface's pixel data from a string (like #pixels).
  # The pixel data must exactly match the length and format of the
  # Surface.
  #
  def pixels=( new_pixels )
    raise "can't modify frozen object" if frozen?

    expected = @struct.pitch * @struct.h
    unless new_pixels.length == expected
      raise "Invalid data length (got %d, expected %d)"%[new_pixels.length,
                                                         expected]
    end
    SDL.LockSurface(@struct)
    @struct.pixels.put_bytes(0, new_pixels)
    SDL.UnlockSurface(@struct)
  end


  # Returns a hash with pixel data and format information that you can
  # use to create an OpenGL texture from this Surface.
  # 
  # If the Surface has an alpha channel (i.e. is not #flat?), and/or
  # has a #colorkey, and/or #opacity is less than 1.0, the pixel data
  # will be in 32-bit RGBA format. Otherwise, it will be in 24-bit RGB
  # format.
  # 
  # The hash returned by this method has 3 keys:
  # 
  # :data::   A string containing the raw pixel data.
  # :format:: An integer constant indicating the pixel format.
  #           Currently, this will be GL_RGB (6407) or GL_RGBA (6408).
  # :type::   An integer constant indicating the data storage type.
  #           Currently, this is always GL_UNSIGNED_BYTE (5121).
  # 
  # You can use the information in the hash to create an OpenGL
  # texture, like so:
  # 
  #   params = surf.to_opengl
  #   glTexImage2D( GL_TEXTURE_2D, 0, params[:format],
  #                 surf.width, surf.height, 0, params[:format],
  #                 params[:type], params[:data] )
  # 
  # Note: glTexImage2D and GL_TEXTURE_2D may be different depending on
  # which OpenGL library you use (e.g. ruby-opengl or ffi-opengl).
  # 
  def to_opengl
    result = {
      :type   => 5121, # GL_UNSIGNED_BYTE
    }

    if (not flat?) or (colorkey) or (opacity < 1.0)
      result[:format] = 6408 # GL_RGBA
      depth = 32
      shifts = [0, 8, 16, 24]
      flags = SDL::SRCALPHA
    else
      result[:format] = 6407 # GL_RGB
      depth = 24
      shifts = [0, 8, 16]
      flags = 0
    end

    masks = shifts.map{ |i| 0xff << i }

    format = SDL::PixelFormat.new( :BitsPerPixel  => depth,
                                   :BytesPerPixel => depth/8,
                                   :Rshift        => shifts[0],
                                   :Gshift        => shifts[1],
                                   :Bshift        => shifts[2],
                                   :Ashift        => shifts[3] || 0,
                                   :Rmask         => masks[0],
                                   :Gmask         => masks[1],
                                   :Bmask         => masks[2],
                                   :Amask         => masks[3] || 0,
                                   :alpha         => 255,
                                   :colorkey      => 0 )

    new_struct = SDL.ConvertSurface( @struct, format, flags )

    if( new_struct.nil? or new_struct.pointer.null? )
      raise( Rubygame::SDLError,
             "Could not convert to OpenGL: #{SDL.GetError()}" )
    end

    len = new_struct.pitch * new_struct.h
    result[:data] = new_struct.pixels.get_bytes(0, len)

    result
  end


  # Return the clipping area for this Surface. See also #clip=.
  #
  # The clipping area of a Surface is the only part which can be drawn
  # upon by other Surface's #blits. By default, the clipping area is
  # the entire area of the Surface.
  #
  def clip
    Rubygame::Rect.new( SDL.GetClipRect(@struct).to_ary )
  end


  # Set the current clipping area of the Surface. See also #clip.
  #
  # The clipping area of a Surface is the only part which can be drawn
  # upon by other Surface's #blits. The clipping area will be clipped
  # to the edges of the surface so that the clipping area for a
  # Surface can never fall outside the edges of the Surface.
  #
  # By default, the clipping area is the entire area of the Surface.
  # You may set clip to +nil+, which will reset the clipping area to
  # cover the entire Surface.
  #
  def clip=( newclip )
    raise "can't modify frozen object" if frozen?

    newclip = case newclip
              when nil, SDL::Rect
                newclip         # no change
              when Rubygame::Rect
                newclip.to_sdl
              when Array
                Rubygame::Rect.new(newclip).to_sdl
              end

    SDL.SetClipRect(@struct, newclip)
    return self
  end



  # Copies the Surface to a new Surface with the pixel format of
  # another Surface, for fast blitting. May raise SDLError if a
  # problem occurs.
  #
  # This method takes these arguments:
  # other::  The Surface to match pixel format against. If +nil+, the
  #          display surface (i.e. Screen) is used, if available; if
  #          no display surface is available, raises SDLError.
  # flags::  An array of flags to pass when the new Surface is created.
  #          See Surface#new.
  #
  def convert( other=nil, flags=nil )

    # If you update this code, update Screen#convert too.

    if other.nil?
      begin
        other = Rubygame::Screen.get_surface
      rescue Rubygame::SDLError
        raise( Rubygame::SDLError, "Cannot convert Surface with no target " +
               "given and no Screen made: #{SDL.GetError()}" )
      end
    end

    flags = Rubygame.collapse_flags(flags)

    newsurf =
      if( Rubygame.init_video_system() == 0 )
        SDL.ConvertSurface( @struct, other.struct.format, flags )
      else
        nil
      end

    if( newsurf.nil? or newsurf.pointer.null?)
      raise( Rubygame::SDLError,
             "Could not convert the Surface: #{SDL.GetError()}" )
    end

    # Wrap it
    return self.class.new( newsurf )
  end



  # Returns a copy of this Surface, converted to the Screen's pixel
  # format (to make blitting to the Screen more efficient).
  # May raise SDLError if a problem occurs.
  #
  # The new Surface returned by this method will be flat (see #flat?).
  # You can use #to_display_alpha to convert to the Screen's pixel
  # format without losing the alpha channel
  #
  def to_display
    newsurf =
      if( Rubygame.init_video_system() == 0 )
        SDL.DisplayFormat( @struct )
      else
        nil
      end

    if( newsurf.nil? or newsurf.pointer.null?)
      raise( Rubygame::SDLError,
             "Could not convert the Surface to display format: %s"%\
             SDL.GetError() )
    end

    # Wrap it
    return self.class.new( newsurf )
  end


  # Like #to_display except the new Surface will have a per-pixel
  # alpha channel (i.e. it will not be #flat?). May raise SDLError if
  # a problem occurs.
  #
  # If this Surface has a #colorkey, but does NOT already have an
  # alpha channel, pixels matching the colorkey will become totally
  # transparent in the new copy. If this Surface already has an alpha
  # channel, the colorkey is ignored. This is a limitation of SDL.
  #
  def to_display_alpha
    newsurf =
      if( Rubygame.init_video_system() == 0 )
        SDL.DisplayFormatAlpha( @struct )
      else
        nil
      end

    if( newsurf.nil? or newsurf.pointer.null?)
      raise( Rubygame::SDLError,
             "Could not convert the Surface to display format "+
             "with alpha channel: #{SDL.GetError()}" )
    end

    # Wrap it
    return self.class.new( newsurf )
  end


  # Returns true if the Surface does NOT have a per-pixel alpha
  # channel.
  # 
  # See also #flatten and #unflatten.
  # 
  def flat?
    (@struct.format.Amask == 0)
  end


  # Returns a copy of this Surface with no per-pixel alpha channel. If
  # this Surface already has no alpha channel, returns a copy anyway.
  # 
  # NOTE: This method only affects the per-pixel alpha channel, it
  # does not change the Surface's #opacity.
  # 
  # By default, the alpha channel is simply removed, without modifying
  # the RGB channels. But, if you give a color for +background+, the
  # Surface is blitted on top of a new Surface filled with that color.
  # 
  # See also #flat? and #unflatten.
  # 
  # May raise SDLError if a problem occurs.
  # 
  def flatten( background=nil )
    newformat = SDL::PixelFormat.new( @struct.format )
    newformat.Aloss  = 0
    newformat.Amask  = 0
    newformat.Ashift = 0

    # Strip out SRCALPHA flag
    newflags = @struct.flags & ~SDL::SRCALPHA

    newsurf = nil

    if( Rubygame.init_video_system() == 0 )

      if background
        # Create a new Surface with the desired format, fill it with
        # the background color, then blit the original on top.
        newsurf = SDL.CreateRGBSurface( flags, @struct.w, @struct.h, 
                                        newformat.BitsPerPixel,
                                        newformat.Rmask, newformat.Gmask,
                                        newformat.Bmask, newformat.Amask )
        unless( newsurf.pointer.null? )
          SDL.FillRect( newsurf, nil, _map_sdl_color(background) )
          SDL.BlitSurface( @struct, nil, newsurf, nil )
        end
      else
        # Just remove the alpha channel.
        newsurf = SDL.ConvertSurface( @struct, newformat, newflags )
      end

    end

    if( newsurf.nil? or newsurf.pointer.null? )
      raise( Rubygame::SDLError,
             "Could not flatten Surface: #{SDL.GetError()}" )
    end

    # Wrap it
    return self.class.new( newsurf )
  end


  # Returns a copy of this Surface with a per-pixel alpha channel. If
  # this Surface already has an alpha channel, returns a copy anyway.
  # The color depth of the copy may be different than the original,
  # if the original color depth does not support alpha channels.
  # 
  # This method is very similar to #to_display_alpha, except that if
  # the Surface already has an alpha channel, this method will never
  # change the underlying pixel format (i.e. masks).
  # 
  # If this Surface has a #colorkey, but does NOT already have an
  # alpha channel, pixels matching the colorkey will become totally
  # transparent in the new copy. If this Surface already has an alpha
  # channel, the colorkey is ignored. This is a limitation of SDL.
  # 
  # NOTE: This method only affects the per-pixel alpha channel, it
  # does not change the Surface's #opacity. (But, be aware that
  # #opacity is ignored for Surfaces with a per-pixel alpha channel.
  # This is a limitation of SDL.)
  # 
  # See also #flat? and #flatten.
  # 
  # May raise SDLError if a problem occurs.
  # 
  def unflatten
    return dup if not flat?

    newsurf =
      if( Rubygame.init_video_system() == 0 )
        SDL.DisplayFormatAlpha( @struct )
      else
        nil
      end

    if( newsurf.nil? or newsurf.pointer.null?)
      raise( Rubygame::SDLError,
             "Could not unflatten Surface: #{SDL.GetError()}" )
    end

    # Wrap it
    return self.class.new( newsurf )
  end


  # Save the Surface as a Windows Bitmap (BMP) file with the given filename.
  # May raise SDLError if a problem occurs.
  #
  def savebmp( filename )
    result = SDL.SaveBMP( @struct, filename.to_s )
    if(result != 0)
      raise( Rubygame::SDLError, "Couldn't save surface to file %s: %s"%\
             [filename, SDL.GetError()] )
    end
    nil
  end


  def to_s
    "#<%s:%#.x>"%[self.class.name, self.object_id]
  end

  alias :inspect :to_s



  # Used by Marshal.dump(). Counterpart to #marshal_load.
  def marshal_dump              # :nodoc:
    SDL.LockSurface(@struct)

    m = masks

    dump = {
      :flags    => @struct.flags,
      :width    => @struct.w,
      :height   => @struct.h,
      :pitch    => @struct.pitch,
      :depth    => depth,
      :rmask    => m[0],
      :gmask    => m[1],
      :bmask    => m[2],
      :amask    => m[3],
      :pixels   => pixels,
      :opacity  => opacity,
      :colorkey => colorkey,
      :palette  => palette,
      :clip     => SDL.GetClipRect(@struct).to_ary,
      :tainted  => tainted?,
      :frozen   => frozen?,
    }

    SDL.UnlockSurface(@struct)

    return dump
  end


  # Used by Marshal.load(). Counterpart to #marshal_dump.
  def marshal_load( dump )      # :nodoc:
    # Create a new surface similar to the original, but empty.
    @struct = SDL.CreateRGBSurface( dump[:flags],
                                    dump[:width], dump[:height],
                                    dump[:depth],
                                    dump[:rmask], dump[:gmask],
                                    dump[:bmask], dump[:amask] )
    SDL.LockSurface(@struct)

    # Overwrite the pixel data.
    self.pixels = dump[:pixels]
    
    if dump[:colorkey]
      set_colorkey( dump[:colorkey],
                    dump[:flags] & (SDL::SRCCOLORKEY|SDL::RLEACCEL) )
    end

    if dump[:opacity]
      self.opacity = dump[:opacity]
    end

    if dump[:palette]
      set_palette( dump[:palette] )
    end

    self.clip = dump[:clip] if dump[:clip]

    SDL.UnlockSurface(@struct)

    if dump[:tainted]
      self.taint
    end

    if dump[:frozen]
      self.freeze
    end
  end


  private

  def _map_sdl_color( color ) # :nodoc:
    SDL.MapRGBA( @struct.format, *Rubygame::Color.make_sdl_rgba(color) )
  end

end
