== Sprite
=== Sprite
You can include Rubygame::Sprite::Sprite in a class to make instances of the
class be sprites. In order to work correctly, each sprite needs two methods:
    * ((|image|)): return a Surface containing the sprite's image. Required for
      the default ((<Sprite#draw>)) method to work properly.
    * ((|rect|)): return a Rect of the sprite's location/size. Required for the
      default ((<Sprite#draw>)), ((<Sprite#collide_group>)), and 
      ((<Sprite#collide_sprite>)) methods to work properly.
Additionally, each sprite has a ((|@groups|)) attribute (and corresponding
accessor), which is created when you call ((<Sprite#initialize>)). Use
((<Sprite#add>)) and ((<Sprite#remove>)) to cleanly modify ((|@groups|)).
	* ((|@groups|)): an Array of the groups of which the sprite is a member.

--- Sprite#initialize
    Should be called (e.g. using super) when a sprite is initialized. Creates
    ((|@groups|)).

--- Sprite#add( group, ... )
    Add the sprite to the given group(s), if the sprite is not in the groups.
        * ((|group|)): a ((<SpriteGroup>)) or list of groups.

--- Sprite#alive?
    Returns true if the sprite is in any groups.

--- Sprite#col_rect
--- Sprite#col_rect=( rect )
    By default, accessors to ((|@col_rect|)), an optional rect which will be
    used for the purposes of collision detection only (not drawing). If
    ((|@col_rect|)) has not been set, attempting to read it will return the
    value of ((<Sprite#rect>)) automatically.

--- Sprite#collide_group( group )
    Return an array of all sprites in the given group that collide with the
    sprite.
        * ((|group|)): the group to check collision with.

--- Sprite#collide_sprite?( other_sprite )
    Return true if the sprite collides with the given sprite.
        * ((|other_sprite|)): the sprite to check collision with.

--- Sprite#draw( dest )
    Blit the sprite's image onto the given surface at the sprite's location.
    Used by ((<RenderGroup>)) to draw the sprites. You may override this as
    needed.
        * ((|dest|)): the destination surface to blit to.

--- Sprite#image
--- Sprite#image=
    By default, an accessor to ((|@image|)), which should be a Surface of the
    sprite's image. You can override this method to do other things, but it
    should ((*always*)) return a Surface. Required for the sprite to be drawn.

--- Sprite#kill
    Remove the sprite from all groups.

--- Sprite#rect
--- Sprite#rect=
    By default, an accessor to ((|@rect|)), which should be a Rect of the 
    sprite's location/size. You can override this method to do other things, 
    but it should ((*always*)) return a Rect. Required for the sprite to be
    drawn or collision detected (unless ((<col_rect|Sprite#col_rect>)) is
    present).

--- Sprite#remove( *groups )
    Remove the sprite from the given group(s), if the sprite is in the groups.
        * ((|groups|)): one or more ((<SpriteGroup>)) or list of groups.

--- Sprite#update( *args )
    Does nothing. Should be overridden to update the sprite's state (e.g. 
    location, image, etc.) in a meaningful way.

=== Group
A Group is a subclass of Array, used to manage sets of sprites. The sprites can
be drawn, updated, and check collision with other sprites or groups. A Group
can only include a Sprite once (no duplicates).

--- Group#<<( sprite )
    Append the given sprite to the Group. If the Sprite is already in the
    group, it will not be added.

--- Group#call( symbol, *args )
    A shortcut to call a method on all sprites in the group.
        * ((|symbol|)): the method to call, as a (({:symbol})).
        * ((|args|)): the args to be passed to the sprites.

--- Group#clear
    Remove all sprites from ((|@sprites|)).

--- Group#collide_group( other_group, killa, killb )
    Check collision between all sprites in the group and all sprites in another
    group. Optionally kill colliding sprites from one or both groups.
        * ((|other_group|)): the group to check collision with.
        * ((|killa|)): give true to kill all sprites in the group that collide
          with sprites in the other group.
        * ((|killb|)): give true to kill all sprites in the other group that
          collide with sprites in the group.

--- Group#collide_sprite( sprite )
    Check collision between all sprites in the group and another sprite. This
    is equivalent to calling ((<Sprite#collide_group>))( group ).
        * ((|sprite|)): the sprite to check collision with.

--- Group#delete( *sprites )
    Remove the given sprites from the Group.

--- Group#draw( dest )
    Calls ((<draw|Sprite#draw>)) for each sprite, with the destination surface 
    as the argument. The sprite is responsible for actually blitting to the 
    destination surface.

--- Group#push( *sprites )
    Add the given sprite(s) to the Group. If any sprite is given that is 
    already in the group, that sprite will not be added.

--- Group#update( *args )
    A shortcut to call ((<update|Sprite#update>)) on all the sprites in the
    group with the given arguments. Note that the default ((<Sprite#update>))
    does nothing, and should be overridden to provide meaningful behavior.


=== UpdateGroup
Include Rubygame::Sprite::UpdateGroup to add the ((<UpdateGroup#undraw>)) 
method to a group. By calling this, updating the sprites (with 
((<Group#update>))), calling the new ((<draw|UpdateGroup#draw>)) method,
and then passing the returned list of Rects to ((<Screen#update>)), you can 
update only the part of the screen that has changed, which is more efficient 
than updating the entire thing.

To facilitate this new functionality, the group has a new attribute (and 
corresponding accessor), ((|@dirty_rects|)), which is created when you call
((<UpdateGroup#initialize>)).
    * ((|@dirty_rects|)): an Array to hold the rects which need to be re-drawn.

--- UpdateGroup#initialize
    Should be called (e.g. using (({super}))) when a group is initialized.
    Calls (({super})) and creates ((|@dirty_rects|)).

--- UpdateGroup#draw( dest )
    The same as ((<Group#draw>)), but returns a list of all the Rects
    which need to be updated on the Screen, including the Rects from 
    ((<UpdateGroup#undraw>)). The list should be passed to ((<Screen#update>)).

--- UpdateGroup#undraw( dest, background )
    Visually remove the sprite from the destination surface by blitting over it
    with the corresponding part of the background surface.
        * ((|dest|)): the destination surface to blit to.
        * ((|background|)): the background surface to cover up the sprite with.
          The sprite's ((|@rect|)) is used as a source rect for the blit. This
          surface should be about the same size as ((|dest|)) to look right.

--- LimitGroup
Include Rubygame::Sprite::LimitGroup to limit a sprite group to a certain 
number of sprites. If any further sprites are added, older sprites will be 
removed on a "first in, first out" basis.

To facilitate this new functionality, the group has a new attribute (and 
corresponding accessor), ((|@limit|)), which is created when you call
((<LimitGroup#initialize>)).
    * ((|@limit|)): the maximum number of sprites the group can hold.

--- LimitGroup#initialize( limit=1 )
    Should be called (e.g. using super) when a group is initialized. Calls
    (({super})) and creates ((|@limit|)).
        * ((|limit|)): the maximum number of sprites which can be in the group.
          The default is 1.

--- LimitGroup#add( *sprites )
    The same as ((<SpriteGroup#add>)), but enforces the limit.
=end
