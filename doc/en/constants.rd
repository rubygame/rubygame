=begin
== Rubygame Constants
All constants are under the Rubygame module. That is, where it says (for 
example) (({FULLSCREEN})), the actual constant is accessed with
(({Rubygame::FULLSCREEN})).

=== Surface Flags
    :SWSURFACE
        Create the video surface in system memory. This is the default.
    :HWSURFACE
        Create the video surface in video (hardware) memory, if hardware (like 
        a graphics card) is available.
    :SRCCOLORKEY 
        Request a colorkeyed surface. ((<Surface#set_colorkey>)) will also 
        enable colorkey. See ((<Surface#set_colorkey>)) for a description of 
        colorkeys.
    :SRCALPHA
        Request an alpha channel. ((<Surface#set_alpha>)) will also enable 
        alpha. See ((<Surface#alpha>)) for a description of alpha.

=== Screen Flags
    :ASYNCBLIT
        Enables the use of asynchronous updates of the display surface. This 
        will usually slow down blitting on single CPU machines, but may provide
        a speed increase on SMP systems (systems with multiple CPUs).
    :ANYFORMAT
        Normally, if a video surface of the requested color depth is 
        not available, Rubygame will emulate one with a shadow surface. Passing 
        this flag prevents this and causes Rubygame to use the video surface, 
        regardless of its pixel depth.
    :HWPALETTE
        Give SDL exclusive palette access. This is untested in Rubygame.
    :DOUBLEBUF
        Enable hardware double buffering; only valid with 
        ((<HWSURFACE|Rubygame::HWSURFACE>)). Calling ((<Screen#flip>)) will 
        flip the buffers and update the screen. All drawing will take place on 
        the surface that is not displayed at the moment. If double buffering 
        could not be enabled then ((<Screen#flip>)) will just perform 
        ((<Screen#update>)) on the entire screen.
    :FULLSCREEN
        Enable fullscreen mode
    :OPENGL
        Create an OpenGL rendering context. 
        OpenGL has not been tested with Rubygame yet, use with caution.
    :OPENGLBLIT
        Create an OpenGL rendering context, like above, but allow normal 
        blitting operations.
        OpenGL has not been tested with Rubygame yet, use with caution.
    :RESIZABLE
        Create a resizable window. When the window is resized by the user a 
        ((<Rubygame::ResizeEvent>)) event is generated on the event queue.
    :HWACCEL
    :RLEACCELOK
    :RLEACCEL
    :PREALLOC


=== Keyboard Constants
<<< key_constants

=== Joystick Constants
One of these constants will be reported as (({value})) by a JoyHatEvent. They
indicate the direction the POV hat is pointed.
    :HAT_CENTERED
    :HAT_UP
    :HAT_RIGHT
    :HAT_DOWN
    :HAT_LEFT
    :HAT_RIGHTUP
    :HAT_RIGHTDOWN
    :HAT_LEFTUP
    :HAT_LEFTDOWN

=end
