=begin
== Time
--- Time.wait( milliseconds )
    Wait approximately the given time (the accuracy depends upon processor 
    scheduling, but 10ms is common). Returns the actual delay time, in 
    milliseconds. This uses less CPU time than ((<Time.delay>)), but is less 
    accurate.
        * ((|milliseconds|)): the number of milliseconds to wait.

--- Time.delay( milliseconds )
    Use the CPU to more accurately wait for the given time. Returns the actual
    delay time, in milliseconds. This is more accurate than ((<Time.wait>)), 
    but is also more CPU-intensive.
        * ((|milliseconds|)): the number of milliseconds to delay.


=== Clock
--- Clock.new
    Initialize a new instance of Clock.

--- Clock#fps
    Return the frames per second for the Clock. In order for this to be 
    accurate, you must call ((<Clock.tick>)) exactly once every frame.

--- Clock#tick( fps_limit )
    You should call this once every frame (that is, every iteration of the main
    game loop). It serves three purposes: it accurately (for the most part) 
    returns the number of milliseconds that have been passed since the last 
    time it was called; it allows you to accurately retrieve the fps of the 
    running game at any time (by using ((<Clock.fps>))); and it allows you to 
    limit the fps of the game. To do the third (limitting the fps), pass the 
    maximum fps you want to the function.
        * ((|fps_limit|)): the maximum desired number of frames per second.
=end
