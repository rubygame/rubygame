=begin
== Rubygame::Display
--- Display.init
    Initialize the display (video) subsystem. If this fails, SDLError is 
    raised. Note that the display subsystem is initialized when 
    ((<Rubygame.init>)) is called, so you probably don't need to call this.

--- Display.set_mode( size, depth, flags )
    Create or change a ((<Screen|class Screen>)) instance. You should assign 
    this return value to a variable for later reference, and to keep the Screen
    from being garbage collected. 
    See ((<class Screen>)) for a description of Screens. 
    ((|size|)), ((|depth|)), and ((|flags|)) are covered in ((<Surface.new>)). 
    Screens have some special flags, covered in ((<Screen Constants>)).

    ((*NOTE*)): only one Screen instance (per application) exists at a time. 
    Calling this method again will change the previous Screen (its dimensions, 
    etc.). This is a limitation of SDL.

--- Display.get_surface
    Returns a previously-created Screen instance. Use this function if you need
    access to the Screen outside of the scope of the regular Screen instance. 
    This will not work if the regular Screen is not in memory somewhere, so 
    make sure you set the return value from ((<Display.set_mode>)) to a 
    variable so it won't be garbage collected.

=== Rubygame::Display::Screen
Screen is a special type of ((<Surface|class Surface>)). A Screen instance 
represents the display window (or the screen if running in fullscreen 
mode), and thus has extra methods. Screen also inherits all Surface methods
except ((<set_alpha|Surface#set_alpha>)) and 
((<set_colorkey|Surface#set_colorkey>)).

--- Screen#get_caption
    Get the window title and icon title as Strings in an Array.

--- Screen#set_caption( title, icon_title )
    Set the window title (and optionally, the icon title). 
        * ((|title|)): the normal title of the window
        * ((|icon_title|)): the title that is displayed on the taskbar, among
          other places. If no icon title is given, the icon will have the same 
          title as the window.

--- Screen#update( rectstyle ) -> self
    Updates (refreshes) part or all of the Screen. This is needed in order to 
    see any changes to the screen. 
        * ((|rectstyle|)) the area to be updated. Either a Rect, an length-4 
          Array, or 4 Numerics. If not given or all zeroes, the whole screen is 
          updated.

--- Screen#update_rects( rectstyle, ... ) -> self
    Updates the areas of the Screen given by multiple Rects.

--- Screen#flip
    On double-bufferred Screens, wait for a vertical retrace, then swaps the 
    video buffers. On non-double-bufferred Screens, this will just update the 
    whole Screen (the same as calling ((<Screen#update>)) with no arguments).
=end
