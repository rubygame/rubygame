
#--
#
# TODO:
#
#  colorkey, colorkey=, set_colorkey
#  get_at, set_at
#  flip
#  load, etc.
#
#++

class Rubygame::SurfaceFFI

  include Rubygame::NamedResource

  class << self

    # Searches each directory in Surface.autoload_dirs for a file with
    # the given filename. If it finds that file, loads it and returns
    # a Surface instance. If it doesn't find the file, returns nil.
    #
    # See Rubygame::NamedResource for more information about this
    # functionality.
    #
    def autoload( name )
      path = find_file( name )

      if( path )
        return load( path )
      else
        return nil
      end
    end


    # Load an image file from the disk to a Surface. If the image has an alpha
    # channel (e.g. PNG with transparency), the Surface will as well. If the
    # image cannot be loaded (for example if the image format is unsupported),
    # will raise SDLError.
    #
    # This method is only usable if Rubygame was compiled with the SDL_image
    # library; you can check Rubygame::VERSIONS[:sdl_image] to see if it was.
    #
    # This method takes this argument:
    # filename:: a string containing the relative or absolute path to the
    #            image file. The file must have the proper file extension,
    #            as it is used to determine image format.
    #
    # These formats may be supported, but some may not be available on a
    # particular system.
    # BMP:: "Windows Bitmap" format.
    # GIF:: "Graphics Interchange Format."
    # JPG:: "Independent JPEG Group" format.
    # LBM:: "Linear Bitmap" format (?)
    # PCX:: "PC Paintbrush" format
    # PNG:: "Portable Network Graphics" format.
    # PNM:: "Portable Any Map" format. (i.e., PPM, PGM, or PBM)
    # TGA:: "Truevision TARGA" format.
    # TIF:: "Tagged Image File Format"
    # XCF:: "eXperimental Computing Facility" (GIMP native format).
    # XPM:: "XPixMap" format.
    # 
    def load( filename )
      surf = SDL::Image.Load( filename )

      if( surf.pointer.null? )
        raise( Rubygame::SDLError, "Couldn't load image \"%s\": %s",
               filename, SDL.GetError() )
      end

      return self.new(surf)
    end


    # Deprecated. Use Surface.load instead!
    def load_image( filename )
      Rubygame.deprecated( "Rubygame::Surface.load_image", "3.0" )
      load( filename )
    end


#     # Load an image file from memory (in the form of the given data)
#     # to a Surface. If the image has an alpha channel (e.g. PNG with
#     # transparency), the Surface will as well. If the image cannot be
#     # loaded (for example if the image format is unsupported), will
#     # raise SDLError.
#     # 
#     # This method is only usable if Rubygame was compiled with the
#     # SDL_image library; you can check Rubygame::VERSIONS[:sdl_image]
#     # to see if it was.
#     # 
#     # This method takes these arguments:
#     # data:: a string containing the data for the image, such as
#     #        IO::read would return.
#     # type:: The type of file that the image is (i.e. 'TGA'). Case is
#     #        not important. If absent, the library will try to
#     #        automatically detect the type.
#     # 
#     # See Surface.load for a list of possible supported file types.
#     # 
#     def load_from_string( data, type=nil )
#     end

  end

  attr_reader :struct           # :nodoc:


  # Create and initialize a new Surface object.
  #
  # A Surface is a grid of image data which you blit (i.e. copy) onto other
  # Surfaces. Since the Rubygame display is also a Surface (see the Screen
  # class), Surfaces can be blit to the screen; this is the most common way
  # to display images on the screen.
  #
  # This method may raise SDLError if the SDL video subsystem could
  # not be initialized for some reason.
  #
  # This function takes these arguments:
  # size::  requested surface size; an array of the form [width, height].
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
  def initialize( size, depth=0, flags=[] )

    # Cheating a bit. First arg can be a SDL::Surface to wrap it.
    #
    if( size.kind_of? SDL::Surface )
      surf = size
      if( surf.pointer.null? )
        raise Rubygame::SDLError, "Surface cannot wrap NULL Surface!"
      else
        @struct = surf
      end
      return
    end


    pixformat = nil

    vs = SDL.GetVideoSurface()

    unless( vs.pointer.null? )
      # Pixel format is retrieved from the video surface.
      pixformat = vs.format
    else
      raise Rubygame::SDLError, "You have to open the Screen first, for now."

      # # We can only get the system color depth when the
      # # video system has been initialized.
      # if( Rubygame.init_video_system == 0 )
      #   pixformat = SDL.GetVideoInfo().vfmt
      # else
      #   raise(Rubygame::SDLError,
      #         "Could not initialize SDL video subsystem.")
      # end
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


  # Return the per-surface alpha (opacity; non-transparency) of the surface.
  # It can range from 0 (full transparent) to 255 (full opaque).
  #
  def alpha
    @struct.format.alpha
  end

  # Set the per-surface alpha (opacity; non-transparency) of the surface.
  # You can do the same thing with #alpha= if you don't care about flags.
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
    result = SDL.SetAlpha(@struct, flags, alpha.to_i)
    raise Rubygame::SDLError, SDL.GetError() unless result == 0
    return self
  end

  alias :alpha= :set_alpha


  # call-seq:
  #    colorkey  ->  [r,g,b]  or  nil
  #
  # Return the colorkey of the surface in the form [r,g,b] (or +nil+ if there
  # is no key). The colorkey of a surface is the exact color which will be
  # ignored when the surface is blitted, effectively turning that color
  # transparent. This is often used to make a blue (for example) background
  # on an image seem transparent.
  #
  def colorkey
    if( (@struct.flags & Rubygame::SRCCOLORKEY) == Rubygame::SRCCOLORKEY )
      SDL::GetRGB(@struct.format.colorkey, @struct.format)
    else
      nil
    end 
  end


  # Set the colorkey of the surface. See Surface#colorkey for a description
  # of colorkeys.
  #
  # This method takes these arguments:
  # color:: color to use as the key, in the form [r,g,b]. Can be +nil+ to
  #         un-set the colorkey.
  # flags:: 0 or Rubygame::SRCCOLORKEY (default) or
  #         Rubygame::SRCCOLORKEY|Rubygame::SDL_RLEACCEL. Most people will
  #         want the default, in which case this argument can be omitted. For
  #         advanced users: this flag affects the surface as described in the
  #         docs for the SDL C function, SDL_SetColorkey.
  #
  def set_colorkey( color, flags=Rubygame::SRCCOLORKEY )
    if color.nil?
      color, flags = 0, 0
    else
      color = SDL.MapRGBA( @struct.format, *Rubygame.make_sdl_rgba(color) )
    end

    result = SDL.SetColorKey(@struct, flags, color)
    raise Rubygame::SDLError, SDL.GetError() unless result == 0
    return self
  end

  alias :colorkey= :set_colorkey


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
    src_x, src_y, src_w, src_h =
      case src_rect
      when SDL::Rect
        [src_rect.x, src_rect.y, src_rect.w, src_rect.h]
      when Array
        src_rect
      when nil
        [0, 0] + self.size
      end

    src_rect  = SDL::Rect.new([src_x,  src_y,  src_w, src_h])
    blit_x, blit_y = pos
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
    color = SDL.MapRGBA( @struct.format, *Rubygame.make_sdl_rgba(color) )
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


#   # Return the color [r,g,b,a] of the pixel at the given coordinate.
#   #
#   # Raises IndexError if the coordinates are out of bounds.
#   #
#   def get_at( x,y )
#   end


#   # Set the color of the pixel at the given coordinate.
#   #
#   # color can be one of:
#   # * an Array, [r,g,b] or [r,g,b,a] with each component in 0-255
#   # * an instance of ColorRGB, ColorHSV, etc.
#   # * the name of a color in Rubygame::Color, as a Symbol or String
#   #
#   # Raises IndexError if the coordinates are out of bounds.
#   #
#   def set_at( [x,y], color )
#   end


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
    return @struct.pixels.get_bytes(0, len)
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

    if other.nil?
      begin
        other = Rubygame::ScreenFFI.get_surface
      rescue Rubygame::SDLError
        raise( Rubygame::SDLError, "Cannot convert Surface with no target " +
               "given and no Screen made: %s", SDL.GetError() )
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
             "Could not convert the Surface: %s", SDL.GetError() )
    end

    # Wrap it
    return self.class.new( newsurf )
  end



  # Copies the Surface to a new Surface with the pixel format of the
  # display, suitable for fast blitting to the display surface (i.e.
  # Screen). May raise SDLError if a problem occurs.
  #
  # If you want to take advantage of hardware colorkey or alpha blit
  # acceleration, you should set the colorkey and alpha value before
  # calling this function.
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
             "Could not convert the Surface to display format: %s",
             SDL.GetError() )
    end

    # Wrap it
    return self.class.new( newsurf )
  end



  # Like #to_display except the Surface has an extra channel for alpha
  # (i.e. opacity). May raise SDLError if a problem occurs.
  #
  # This function can be used to convert a colorkey to an alpha
  # channel, if the SRCCOLORKEY flag is set on the surface. The
  # generated surface will then be transparent (alpha=0) where the
  # pixels match the colorkey, and opaque (alpha=255) elsewhere.
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
             "with alpha channel: %s", SDL.GetError() )
    end

    # Wrap it
    return self.class.new( newsurf )
  end


  # Save the Surface as a Windows Bitmap (BMP) file with the given filename.
  # May raise SDLError if a problem occurs.
  #
  def savebmp( filename )
    result = SDL.SaveBMP( @struct, filename )
    if(result != 0)
      raise( Rubygame::SDLError, "Couldn't save surface to file %s: %s",
             filename, SDL.GetError() )
    end
    nil
  end


#   # Flips the source surface horizontally (if +horz+ is true), vertically
#   # (if +vert+ is true), or both (if both are true). This operation is
#   # non-destructive; the original image can be perfectly reconstructed by
#   # flipping the resultant image again.
#   #
#   # This operation does NOT require SDL_gfx.
#   #
#   # A similar effect can (supposedly) be achieved by giving X or Y zoom
#   # factors of -1 to #rotozoom (only if compiled with SDL_gfx 2.0.13 or
#   # greater). Your mileage may vary.
#   #
#   def flip( horz, vert )
#   end

end
