== Sprite
=== Sprite
You can include Rubygame::Sprite::Sprite in a class to make instances of the
class be sprites. In order to work correctly, each sprite needs two attributes
(accessors for these attributes are available):
    * ((|@image|)): a Surface containing the sprite's image. Required for the
      default ((<Sprite#draw>)) method to work properly.
    * ((|@rect|)): a Rect of the sprite's location/size. Required for the
      default ((<Sprite#draw>)), ((<Sprite#collide_group>)), and 
      ((<Sprite#collide_sprite>)) methods to work properly.
Additionally, each sprite has a ((|@groups|)) attribute (and corresponding
accessor), which is created when you call ((<Sprite#initialize>)). Use
((<Sprite#add>)) and ((<Sprite#remove>)) to cleanly modify ((|@groups|)).
	* ((|@groups|)): an Array of all the groups of which the sprite is a member.

--- Sprite#initialize
    Should be called (e.g. using super) when a sprite is initialized. Creates
    ((|@groups|)).

--- Sprite#add( group, ... )
    Add the sprite to the given group(s), if the sprite is not in the groups.
        * ((|group|)): a ((<SpriteGroup>)) or list of groups.

--- Sprite#alive?
    Returns true if the sprite is in any groups.

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

--- Sprite#kill
    Remove the sprite from all groups.

--- Sprite#remove( *groups )
    Remove the sprite from the given group(s), if the sprite is in the groups.
        * ((|groups|)): one or more ((<SpriteGroup>)) or list of groups.

--- Sprite#update( *args )
    Does nothing. Should be overridden to update the sprite's state (e.g. 
    location, image, etc.) in a meaningful way.

=== SpriteGroup
You can include Rubygame::Sprite::SpriteGroup in a class to make instances of
the class be SpriteGroups. Alternatively, you can create an instance of
((<SpriteGroupClass>)), which includes this module.

A SpriteGroup has a list of member sprites, ((|@sprites|)), (and corresponding
accessor) which is created by ((<SpriteGroup#initialize>)). It uses this list 
to draw and check collision, among other things. Use ((<SpriteGroup#add>)) and 
((<SpriteGroup#remove>)) to cleanly modify ((|@sprites|)).
	* ((|@sprites|)): an Array of all the sprites which are a member of the 
      group.

--- SpriteGroup#initialize
    Should be called (e.g. using super) when a group is initialized. Creates
    ((|@sprites|)).

--- SpriteGroup#add( *sprites )
    Add the given sprite(s) to the group, if the sprites are not in the group.

--- SpriteGroup#call( symbol, *args )
    A shortcut to call a method on all sprites in the group.
        * ((|symbol|)): the method to call, as a (({:symbol})).
        * ((|args|)): the args to be passed to the sprites.

--- SpriteGroup#clear
    Remove all sprites from ((|@sprites|)).

--- SpriteGroup#collide_group( other_group, killa, killb )
    Check collision between all sprites in the group and all sprites in another
    group. Optionally kill colliding sprites from one or both groups.
        * ((|other_group|)): the group to check collision with.
        * ((|killa|)): give true to kill all sprites in the group that collide
          with sprites in the other group.
        * ((|killb|)): give true to kill all sprites in the other group that
          collide with sprites in the group.

--- SpriteGroup#collide_sprite( sprite )
    Check collision between all sprites in the group and another sprite. This
    is equivalent to calling ((<Sprite#collide_group>))( group ).
        * ((|sprite|)): the sprite to check collision with.

--- SpriteGroup#draw( dest )
    Calls ((<draw|Sprite#draw>)) for each sprite, with the destination surface 
    as the argument. The sprite is responsible for actually blitting to the 
    destination surface.

--- SpriteGroup#each { |sprite| ... }
    Iterate over all sprites in ((|@sprite|)).

--- SpriteGroup#empty?
    True if there are no sprites in the group.

--- SpriteGroup#update( *args )
    A shortcut to call ((<update|Sprite#update>)) on all the sprites in the
    group with the given arguments. Note that the default ((<Sprite#update>))
    does nothing, and should be overridden to provide meaningful behavior.

=== SpriteGroupClass
A simple class which includes the ((<SpriteGroup>)) module.

=== UpdateGroup
Adds one feature to the ((<SpriteGroup|SpriteGroup mixin>)) (both should be
included in a class): the ((<UpdateGroup#undraw>)) method. By calling this,
updating the sprites (with ((<SpriteGroup#update>))), and then calling the new
((<draw|UpdateGroup#draw>)) method, and then passing the returned list of Rects
to ((<Screen#update>)), you can update only the part of the screen that has
changed, which is more efficient than re-drawing the entire thing.

To facilitate this new functionality, the group has a new attribute (and 
corresponding accessor), ((|@dirty_rects|)), which is created by
((<UpdateGroup#initialize>)).
    * ((|@dirty_rects|)): an Array to hold the rects which need to be re-drawn.

--- UpdateGroup#initialize
    Should be called (e.g. using super) when a group is initialized. Creates
    ((|@dirty_rects|)) and calls super.

--- UpdateGroup#draw( dest )
    The same as ((<SpriteGroup#draw>)), but returns a list of all the Rects
    which need to be updated on the Screen, including the Rects from 
    ((<UpdateGroup#undraw>)). The list should be passed to ((<Screen#update>)).

--- UpdateGroup#undraw( dest, background )
    Visually remove the sprite from the destination surface by blitting over it
    with the corresponding part of the background surface.
        * ((|dest|)): the destination surface to blit to.
        * ((|background|)): the background surface to cover up the sprite with.
          The sprite's ((|@rect|)) is used as a source rect for the blit. This
          surface should be about the same size as ((|dest|)) to look right.

=== UpdateGroupClass
A simple class which includes the ((<UpdateGroup>)) and 
((<SpriteGroup>)) modules.

--- LimitGroup
Limits a sprite group to a certain number of sprites. If any further sprites
are added, older sprites will be removed on a FIFO (first in, first out) basis.

To facilitate this new functionality, the group has a new attribute (and 
corresponding accessor), ((|@limit|)), which is created by
((<LimitGroup#initialize>)).

--- LimitGroup#initialize( limit=1 )
    Should be called (e.g. using super) when a group is initialized. Creates
    ((|@limit|)) and calls super.
        * ((|limit|)): the maximum number of sprites which can be in the group.
          The default is 1.

--- LimitGroup#add( *sprites )
    The same as ((<SpriteGroup#add>)), but enforces the limit.
=end
