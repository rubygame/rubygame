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



# Screen represents the display window for the game. The Screen is a
# special Surface that is displayed to the user. By changing and then
# updating the Screen many times per second, you can create the
# illusion of continous motion.
#
# Screen inherits most of the Surface methods, and can be passed to
# methods which expect a Surface, including Surface#blit. However, the
# Screen cannot have an alpha channel or a colorkey, so
# Surface#alpha=, Surface#set_alpha, Surface#colorkey=, and
# Surface#set_colorkey are not inherited.
#
# Please note that only one Screen can exist at a time, per
# application; this is a limitation of SDL. Use Screen.new (or its
# alias, Screen.open) to create or modify the Screen.
#
# Also note that no changes to the Screen will be seen until it is
# refreshed. See #update, #update_rects, and #flip for ways to refresh
# all or part of the Screen.
#
class Rubygame::Screen < Rubygame::Surface

  class << self
    # Inherited from Surface, but not applicable to Screen
    [ :[], :[]=, :autoload, :autoload_dirs=, :autoload_dirs,
      :basename, :exist?, :find_file, :load, :load_image
    ].each { |m|
      eval "undef #{m.inspect} if respond_to? #{m.inspect}"
    }
  end


  # Inherited from Surface, but not applicable to Screen
  [ :alpha=, :set_alpha, :colorkey=, :set_colorkey ].each { |m|
    eval "undef #{m.inspect} if respond_to? #{m.inspect}"
  }


  class << self

    alias :open :new

    # Deprecated alias for Screen.new. This method will be REMOVED in
    # Rubygame 3.0. You should use Screen.new (or its alias,
    # Screen.open) instead.
    # 
    def set_mode( size, depth=0, flags=[Rubygame::SWSURFACE] )
      Rubygame.deprecated("Rubygame::Screen.set_mode", "3.0")
      new( size, depth, flags )
    end

    # Deprecated alias for Screen.new. This method will be REMOVED in
    # Rubygame 3.0. You should use Screen.new (or its alias,
    # Screen.open) instead.
    # 
    def instance( size, depth=0, flags=[Rubygame::SWSURFACE] )
      Rubygame.deprecated("Rubygame::Screen.instance", "3.0")
      new( size, depth, flags )
    end

    # Close the Screen, making the Rubygame window disappear.
    # This method also exits from fullscreen mode, if needed.
    #
    # After calling this method, you should discard any references
    # to the old Screen surface, as it is no longer valid, even
    # if you call Screen.new again.
    #
    # (Note: You do not need to close the Screen to change its size
    # or flags, you can simply call Screen.new while already open.)
    #
    def close
      SDL.QuitSubSystem( SDL::INIT_VIDEO )
      nil
    end


    # True if there is an open Rubygame window.
    # See Screen.new and Screen.close.
    #
    def open?
      (not SDL.GetVideoSurface().pointer.null?)
    end


    # Returns the currently open Screen, or raises SDLError if it
    # fails to get it (for example, if it doesn't exist yet).
    #
    def get_surface
      s = SDL.GetVideoSurface()

      if s.pointer.null?
        raise( Rubygame::SDLError,
               "Couldn't get video surface: #{SDL.GetError()}" )
      end

      return self.new( s )
    end


    # Returns the pixel dimensions of the user's display (i.e. monitor).
    # (That is not the same as Screen#size, which only measures the
    # Rubygame window.) You can use this information to detect
    # how large of a Screen can fit on the user's display.
    #
    # This method can _only_ be used when there is no open Screen instance.
    # This method raises SDLError if there is a Screen instance (i.e.
    # you have done Screen.new before). This is a limitation of the SDL
    # function SDL_GetVideoInfo, which behaves differently when a Screen
    # is open than when it is closed.
    #
    # This method will also raise SDLError if it cannot get the display
    # size for some other reason.
    #
    def get_resolution
      if( Rubygame.init_video_system() != 0 )
        raise(Rubygame::SDLError, "Could not initialize SDL video subsystem.")
      end

      unless SDL.GetVideoSurface().pointer.null?
        raise( Rubygame::SDLError, "You cannot get resolution when there " +
               "is an open Screen. See the docs for the reason." )
      end

      info = SDL::GetVideoInfo()
      if( info.pointer.null? )
        raise Rubygame::SDLError, "Couldn't get video info: #{SDL.GetError()}"
      end

      return [info.current_w, info.current_h]
    end

  end



  # Create a new Rubygame window if there is none, or modify the
  # existing one. You cannot create more than one Screen; the existing
  # one will be replaced. (This is a limitation of SDL.)
  # 
  # Returns the resulting Screen.
  #
  # size::  requested window size (in pixels), in the form [width,height]
  # depth:: requested color depth (in bits per pixel). If 0 (default), the
  #         current system color depth.
  # flags:: an Array of zero or more of the following flags (located under the
  #         Rubygame module).
  #
  #         SWSURFACE::  Create the video surface in system memory.
  #         HWSURFACE::  Create the video surface in video memory.
  #         ASYNCBLIT::  Enables the use of asynchronous updates of the
  #                      display surface. This will usually slow down
  #                      blitting on single CPU machines, but may provide a
  #                      speed increase on SMP systems.
  #         ANYFORMAT::  Normally, if a video surface of the requested
  #                      bits-per-pixel (bpp) is not available, Rubygame
  #                      will emulate one with a shadow surface. Passing
  #                      +ANYFORMAT+ prevents this and causes Rubygame to
  #                      use the video surface regardless of its depth.
  #         DOUBLEBUF::  Enable hardware double buffering; only valid with
  #                      +HWSURFACE+. Calling #flip will flip the
  #                      buffers and update the screen. All drawing will
  #                      take place on the surface that is not displayed at
  #                      the moment. If double buffering could not be
  #                      enabled then #flip will just update the
  #                      entire screen.
  #         FULLSCREEN:: Rubygame will attempt to use a fullscreen mode. If
  #                      a hardware resolution change is not possible (for
  #                      whatever reason), the next higher resolution will
  #                      be used and the display window centered on a black
  #                      background.
  #         OPENGL::     Create an OpenGL rendering context. You must set
  #                      proper OpenGL video attributes with GL#set_attrib
  #                      before calling this method with this flag. You can
  #                      then use separate opengl libraries (for example rbogl)
  #                      to do all OpenGL-related functions.
  #                      Please note that you can't blit or draw regular SDL
  #                      Surfaces onto an OpenGL-mode screen; you must use
  #                      OpenGL functions.
  #         RESIZABLE::  Create a resizable window. When the window is
  #                      resized by the user, a ResizeEvent is
  #                      generated and this method can be called again
  #                      with the new size.
  #         NOFRAME::    If possible, create a window with no title bar or
  #                      frame decoration.
  #                      Fullscreen modes automatically have this flag set.
  #
  def initialize(  size, depth=0, flags=[Rubygame::SWSURFACE] )

    # Cheating a bit. First arg can be a SDL::Surface to wrap it.
    #
    if( size.kind_of? SDL::Surface )
      surf = size
      if( surf.pointer.null? )
        raise Rubygame::SDLError, "Screen cannot wrap NULL Surface!"
      elsif( surf.pointer != SDL.GetVideoSurface().pointer )
        raise Rubygame::SDLError, "Screen can only wrap the video Surface!"
      else
        @struct = surf
      end
      return
    end


    w,h = size
    flags = Rubygame.collapse_flags(flags)

    @struct = SDL.SetVideoMode( w, h, depth, flags )

    if( @struct.pointer.null? )
      @struct = nil
      raise( Rubygame::SDLError,
             "Couldn't set [%d x %d] %d bpp video mode: %s"%\
             [w, h, depth, SDL.GetError()] )
    end

  end



  # If the Rubygame display is double-buffered (see Screen.new), flips
  # the buffers and updates the whole screen. Otherwise, just updates
  # the whole screen.
  #
  def flip
    SDL.Flip( @struct )
    self
  end


  # call-seq:
  #   update
  #   update( rect )
  #   update( x,y,w,h )
  #
  # Updates (refreshes) all or part of the Rubygame window, revealing
  # to the user any changes that have been made since the last update.
  # If you're using a double-buffered display (see Screen.new), you
  # should use Screen#flip instead.
  #
  # rect:: a Rubygame::Rect representing the area of the screen to update.
  #        Can also be an length-4 Array, or given as 4 separate arguments.
  #        If omitted or nil, the entire screen is updated.
  #
  def update( *args )
    r = case args[0]
        when nil
          # Update the whole screen. Skip the stuff below.
          SDL.UpdateRect( @struct, 0, 0, 0, 0 );
          return self
        when SDL::Rect
          Rubygame::Rect.new( args[0].to_ary )
        when Array
          Rubygame::Rect.new( args[0] )
        when Numeric
          Rubygame::Rect.new( args[0,4] )
        else
          raise( ArgumentError,
                 "Invalid args for #{self.class}#update: #{args.inspect}" )
        end

    SDL.UpdateRect( @struct, *(r.clip!( self.make_rect ).to_sdl) );

    return self
  end



  # Updates (as Screen#update does) several areas of the screen.
  #
  # rects:: an Array containing any number of Rect objects, each
  #         rect representing a portion of the screen to update.
  #
  def update_rects( rects )
    my_rect = self.make_rect

    rects.collect! do |r|
      r = case r
          when SDL::Rect
            Rubygame::Rect.new( r.to_ary )
          when Array
            Rubygame::Rect.new( r )
          else
            raise( ArgumentError,
                   "Invalid rect for #{self.class}#update_rects: #{r.inspect}" )
          end

      r.clip!(my_rect).to_sdl
    end

    SDL.UpdateRects( @struct, rects )

    return self
  end



  # Sets the window icon for the Screen.
  #
  # icon:: a Rubygame::Surface to be displayed at the top of the Rubygame
  #        window (when not in fullscreen mode), and in other OS-specific
  #        areas (like the taskbar entry). If omitted or +nil+, no icon
  #        will be shown at all.
  #
  # NOTE: The SDL docs state that icons on Win32 systems must be 32x32
  # pixels. That may or may not be true anymore, but you might want to
  # consider it when creating games to run on Windows.
  #
  def icon=( surface )
    SDL.WM_SetIcon( surface.struct, nil )
    return self
  end



  # Returns true if the mouse cursor is shown, or false if hidden.
  # See also #show_cursor=
  #
  def show_cursor?
    return ( SDL.ShowCursor(SDL::QUERY) == 1 )
  end


  # Set whether the mouse cursor is displayed or not. If +value+ is
  # true, the cursor will be shown; if false, it will be hidden.
  # See also #show_cursor?
  #
  def show_cursor=( value )
    value = value ? SDL::ENABLE : SDL::DISABLE
    return ( SDL.ShowCursor(value) == SDL::ENABLE )
  end



  # Returns the current window title for the Screen.
  # The default is an empty string.
  #
  def title
    return SDL.WM_GetCaption()[0]
  end


  # Sets the window title for the Screen.
  #
  # newtitle:: a string, (usually) displayed at the top of the Rubygame
  #            window (when not in fullscreen mode). If omitted or +nil+,
  #            +title+ will be an empty string.
  #            How this string is displayed (if at all) is system-dependent.
  #
  def title=( newtitle )
    SDL.WM_SetCaption( newtitle, newtitle )
  end


end
