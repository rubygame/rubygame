=begin
== Rubygame::Joy
--- Joy.num_joysticks
    Return the number of joysticks that have been detected.

--- Joy.get_name( joy_num )
    Return the implementation-dependent name of the joystick.
        * ((|joy_num|)): the integer index number of the joystick. The first
          detected joystick will have an index of 0.

=== Rubygame::Joy::Joystick
--- Joystick.new( joy_num )
    Open an initialize a joystick. Safe to call even if the joystick has been
    opened already. Once a joystick has been created, events for the joystick
    will begin appearing on the event queue.
        * ((|joy_num|)): the integer index number of the joystick. The first
          detected joystick will have an index of 0.

--- Joystick#index
    Return the index number of the joystick. The first detected joystick will 
    have an index of 0.

--- Joystick#name
    Return the implementation-dependent name of the joystick.

--- Joystick#numaxes
    Return the number of axes (sing. axis) on the joystick.

--- Joystick#numballs
    Return the number of trackballs on the joystick.

--- Joystick#numhats
    Return the number of POV hats on the joystick.

--- Joystick#numbuttons
    Return the number of buttons on the joystick.
=end
