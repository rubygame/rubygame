=begin
== Event classes
    * ((<Event|Rubygame::Event>))
    * ((<ActiveEvent|Rubygame::ActiveEvent>))
    * ((<KeyDownEvent|Rubygame::KeyDownEvent>))
    * ((<KeyUpEvent|Rubygame::KeyUpEvent>))
    * ((<MouseMotionEvent|Rubygame::MouseMotionEvent>))
    * ((<MouseDownEvent|Rubygame::MouseDownEvent>))
    * ((<MouseUpEvent|Rubygame::MouseUpEvent>))
    * ((<JoyAxisEvent|Rubygame::JoyAxisEvent>))
    * ((<JoyBallEvent|Rubygame::JoyBallEvent>))
    * ((<JoyHatEvent|Rubygame::JoyHatEvent>))
    * ((<JoyDownEvent|Rubygame::JoyDownEvent>))
    * ((<JoyUpEvent|Rubygame::JoyUpEvent>))
    * ((<ResizeEvent|Rubygame::ResizeEvent>))
    * ((<QuitEvent|Rubygame::QuitEvent>))

=== Event Classes Introduction
Events are used by Rubygame to learn about things that have happened,
such as mouse movement, keyboard presses, focus changes, and joystick movement.
Events are generally created and posted to the event 
((<Queue|Rubygame::Queue>)) by the system automatically, but it is possible for 
a program to create and post new events, and even to create new kinds of 
events, based off of the ((<Event class|Rubygame::Event>)).

Each type of event, in addition to having a class (which indicates what kind
of event happened) has data (which indicate the specifics about what happened).
This data is accessed via attributes.

Each event type is described below. Generally, the arguments to (({new})) have 
the same name as the attributes, in which case they are only listed once. In a 
few cases, the arguments and attributes do not directly correspond, in which 
case both the arguments and the attributes are listed and described separately

=== Rubygame::Event
Base class for all Rubygame event classes.
    * [No attributes or methods.]

=== Rubygame::ActiveEvent
Signals that the Rubygame display window has either lost or gained focus.
--- ActiveEvent.new(gain,state)
    Create a new instance of ActiveEvent
    * ((|gain|)): true if the window gained focus, false if it lost it
    * ((|state|)): The type of focus change. Equal to one of the following:
        * "mouse" -- The cursor is over the window.
        * "keyboard" -- The window is receiving keyboard input.
        * "active" -- The window is selected.

=== Rubygame::KeyDownEvent
Signals that a keyboard key has been pressed. This event will only occur if
the display window has keyboard focus (see ((<Rubygame::ActiveEvent>))).
    * ((|key|)): an integer keysym (this works for even non-printable 
      keys). The keysyms are defined as constants under the Rubygame 
      module, in the form of K_*, like K_SPACE or K_A. See 
      ((<Keyboard Constants>)) for a full list.
    * ((|mods|)): an Array of keysyms for the modifier keys that are 
      pressed, like K_LCTRL, K_RSHIFT, or K_LMETA. See 
      ((<Keyboard Constants>)) for a full list.
    * ((|string|)): an ASCII representation of the key, suitable to be 
      printed. This is (({nil})) except for keys which normally produce a 
      character: letter keys, number keys, punctuation, space bar (" "), 
      tab ("\t"), and enter/return ("\n"). The output from letter keys will
      always be lower-case, and punctuation will be non-shifted (these may 
      change in the future).
--- KeyDownEvent.new( key_string, mods )
    Create a new instance of ActiveEvent
    * ((|key_string|)): Either an integer keysym or a string (See
      ((<Keyboard Constants>)) for a list of both keysyms and corresponding
      strings). Integers are assigned to ((|key|)), strings to ((|string|));
      the value that wasn't given is automatically retrived from a Hash.

=== Rubygame::KeyUpEvent 
The same as ((<KeyDownEvent|Rubygame::KeyDownEvents>)), but signals that 
a key has been released, rather than pressed.

=== Rubygame::MouseMotionEvent
Signals that the mouse cursor has been moved.
    * ((|buttons|)): the mouse buttons that were being held down during
      the move, in the form of (({[MOUSE_*, ...]})). See 
      ((<Constants|URL:constants.html>)) for a full list of MOUSE_* syms.
    * ((|pos|)): the new location of the mouse cursor, in the form 
      (({[x,y]})).
    * ((|rel|)): the relative motion of the cursor (how much it moved by),
      in the form (({[x,y]})).

=== Rubygame::MouseDownEvent
Signals that a mouse button has been pressed.
    * ((|button|)): the button that was pressed, in the form of 
      ((<MOUSE_*|Mouse Constants>)).
    * ((|pos|)): the location of the cursor when the button was pressed,
      in the form of (({[x,y]}))
    * ((|string|)): a string representation of the button that was pressed,
      out of: (({"left"})), (({"middle"})), or (({"right"})).

=== Rubygame::MouseUpEvent
The same as ((<MouseDownEvent|Rubygame::MouseDownEvent>)), but signals that a 
mouse button has been released, not pressed.

=== Rubygame::JoyAxisEvent
Signals that a joystick axis has been moved. A joystick must be initialized
(using ((<Joystick.new>))) before events for that joystick will appear on
the event queue.
    * ((|axis|)): the number identifier of the axis which was moved.
    * ((|joynum|)): the number identifier for the joystick which had the
      event. The first detected joystick (even if it is not initialized) 
      has an identifier of 0.
    * ((|value|)): the new value of the axis (between -32767 and 32767)

=== Rubygame::JoyBallEvent
Signals that a joystick trackball has been moved. A joystick must be 
initialized (using ((<Joystick.new>))) before events for that joystick will
appear on the event queue.
    * ((|ball|)): the number identifier of the trackball axis which was 
      moved.
    * ((|joynum|)): the number identifier for the joystick which had the
      event. The first detected joystick (even if it is not initialized) 
      has an identifier of 0.
    * ((|value|)): the new value of the trackball axis (between -32767 and 
      32767)

=== Rubygame::JoyHatEvent
Signals that a joystick POV hat has been moved. A joystick must be 
initialized (using ((<Joystick.new>))) before events for that joystick will
appear on the event queue.
    * ((|hat|)): the number identifier of the POV hat which was moved.
    * ((|joynum|)): the number identifier for the joystick which had the
      event. The first detected joystick (even if it is not initialized) 
      has an identifier of 0.
    * ((|value|)): the new value of the POV hat, in the form (({HAT_*}))
      (see ((<Joystick Constants>)) for the full list.

=== Rubygame::JoyDownEvent
Signals that a joystick button has been pressed. A joystick must be
initialized (using ((<Joystick.new>))) before events for that joystick will
appear on the event queue.
    * ((|button|)): the number identifier for the button which was pressed.
      The first button has an identifier of 0.
    * ((|joynum|)): the number identifier for the joystick which had the
      event. The first detected joystick (even if it is not initialized) 
      has an identifier of 0.

=== Rubygame::JoyUpEvent
The same as ((<JoyDownEvent|Rubygame::JoyDownEvent>)), but signals that a 
joystick button has been released, not pressed.

=== Rubygame::ResizeEvent
Signals that the ((<Screen>)) has been resized. This should only happen
when ((<Display.set_mode>)) has been called with the ((<RESIZABLE|
Screen Constants>)) flag.
    * ((|size|)): the new size of the window, in the form (({[w,h]})).

=== Rubygame::QuitEvent
Signals that the user has requested that the program quit. A common way to
do this is by clicking the "Close" ("X") button on the titlebar.
    * [No attributes or methods]
    
== Rubygame::Queue
Queue represents the event queue which holds all the events that have happened.
There are several methods to allow you to access and limit the kinds of events
which appear on the queue.

--- Queue#allow( event_class_array, ... )
    Takes in any combination, any number of: 
        * Event Classes
        * Instances of Event Classes
        * Arrays (of any recursion level) of the above
    Adds the given Classes (or the classes of the given instances) to the list 
    of allowed classes of events. Returns a list of the Classes that were 
    added, which were not allowed prior to calling the method. See 
    ((<Queue#get>)) for details on what allowing a class means.

--- Queue#allowed
    Returns the list of allowed event classes.

--- Queue#allowed=( event_class_array, ... )
    Takes in any combination, any number of: 
        * Event Classes
        * Instances of Event Classes
        * Arrays (of any recursion level) of the above
    Allows the given Classes (or the classes of the given instances), and no 
    others. Returns a list of the Classes that were added, which were not 
    allowed prior to calling the method. See ((<Queue#get>)) for details on 
    what allowing a class means.

    ((*NOTE*)): If no arguments are specified, ((*no*)) event classes will be 
    allowed!!

--- Queue#block( event_class_array, ... )
    As ((<Queue#allow>)), but removes the given Classes (or the classes of the 
    given instances) from the list allowed classes of events instead of adding.
    Returns a list of the Classes that were removed, which were allowed prior 
    to calling the method. See ((<Queue#get>)) for details on what allowing a 
    class means.

--- Queue#blocked
    Returns the list of all non-allowed event classes.

--- Queue#blocked=( event_class_array, ... )
    As ((<Queue#allowed=>)), but allows all event classes ((*except*)) those 
    given. Returns a list of all classes that were removed, which were allowed 
    prior to calling the method.

    ((*NOTE*)): If no arguments are specified, ((*all*)) event classes will be 
    allowed.

--- Queue#get( event_class_array, ... )
    Takes in any combination, any number of: 
        * Event classes
        * Instances of Event classes
        * Arrays (of any recursion level) of the above
    Returns all events of the given classes (or the classes of the given 
    instances) in an Array. If no classes are specified, all events of the 
    classes in the list of allowed classes are returned.

--- Queue#get_sdl
    ((*For internal use only!*)) Get events from SDL's event queue, 
    and convert them to Rubygame events. Returns an Array of all the events.

--- Queue#post( event, ... )
    Add the given events to the end of the event queue, in the order they are 
    given. Returns a list of all the given objects which were not an instance 
    of either class Event or one of its subclasses, and were therefor not 
    added to the Queue.

    Note that posting an event to the Queue does ((*not*)) cause the 
    corresponding event to happen; for example, you cannot move the cursor by 
    posting a MouseMotionEvent.

--- Queue#update_pending
    ((*For internal use only!*)) Get converted SDL events, and post 
    them to the list of pending events.


=end
