=begin
== Rects
--- Rubygame.rect_from_object( object )
    Attempt to convert a rectstyle into an actual Rect. A rectstyle falls under
    one of these cases:
        * If the object itself is a rect, a copy (dup) of the object is 
          returned.
        * If the object itself is an Array of at least length 4, a new Rect is 
          made using the Array as a base. An ArgError is raised if the Array is
          not long enough to make a Rect from it.
        * If the above cases fail, attempts to extract a rectstyle from 
          object.rect.
        * If it does not fit one of the above cases, a Rect cannot be extracted
          and a TypeError is raised.

=== Rubygame::Rect
A Ruby representation of a rectangle. Note that wherever a Rect is required
as an argument to a function, an Array (({[x,y,w,h]})) can be substituted. 
For convenience, you also may substitue an object which has an attribute 
name "rect" which is a Rect. Together, any of these three options (a Rect, 
an Array, or an object with a rect attribute) are referred to as a 
"rectstyle".

Rects have 4 primary attributes; ((|x|)), ((|y|)), ((|w|)) (((|width|))), 
and ((|h|)) (((|height|))). ((|x|)) and ((|y|)) are the coordinates of the 
top-leftmost point of the Rect; ((|w|)) and ((|h|)) are the width and 
height of the Rect. These can be read or modified by name, for example 
(({Rect#x})) (((|w|)) and ((|width|)) are both valid; the same goes for 
((|h|)) and ((|height|))). You can also access these attributes with the 
((<[]|Rect#[]>)) operator: Rects are like fancy Arrays with extra methods.
Index 0 refers to ((|x|)), 1 to ((|y|)), 2 to ((|w|)), and 3 to ((|h|)).

((*(NOTE: because the top-left pixel, rather than the bottom-left pixel (as
on a mathematical graph) is the origin (the coordinate (0,0)), ((|y + 
height|)) appears LOWER on the screen than ((|y|)).)*))

In addition to these primary attributes, Rects have many "convenience" 
attributes, which can be used to indirectly read or modify the primary 
attributes. Note that, with the exception of ((|size|)), assigning to these 
attributes will NOT change ((|w|)) or ((|h|)); they will instead move the Rect 
while preserving its width and height.

Each attribute can have assigned to it the same sort of object that it 
returns. For example, if it returns (({[x,y]})), it will take a length-2
Array. If it returns (({x+w})), it takes one Numeric.

--- Rect#x
Returns ((|x|))

--- Rect#y
Returns ((|y|))

--- Rect#w
--- Rect#width
Returns ((|w|))

--- Rect#h
--- Rect#height
Returns ((|h|))

--- Rect#left
--- Rect#l
Returns ((|x|))

--- Rect#top
--- Rect#t
Returns ((|y|))

--- Rect#right
--- Rect#r
Returns ((|x+w|))

--- Rect#bottom
--- Rect#b
Returns ((|y+h|))

--- Rect#center
--- Rect#c
Returns ((|[x+w/2, y+h/2]|))

--- Rect#centerx
--- Rect#cx
Returns ((|x+w/2|))

--- Rect#centery
--- Rect#cy
Returns ((|y+h/2|))

--- Rect#topleft
--- Rect#tl
Returns ((|[x, y]|))

--- Rect#topright
--- Rect#tr
Returns ((|[x+w, y]|))

--- Rect#bottomleft
--- Rect#bl
Returns ((|[x, y+h]|))

--- Rect#bottomright
--- Rect#br
Returns ((|[x+w, y+h]|))

--- Rect#midleft
--- Rect#ml
Returns ((|[x, y+h/2]|))

--- Rect#midtop
--- Rect#mt
Returns ((|[x+w/2, y]|))

--- Rect#midright
--- Rect#mr
Returns ((|[x+w, y+h/2]|))

--- Rect#midbottom
--- Rect#mb
Returns ((|[x+w/2, y+h]|))

--- Rect.new( [x,y,w,h] )
--- Rect.new( rect )
    Create a new Rect with the given location and size. 
        * ((|x,y|)): the x and y locations of the top-left corner of the Rect
        * ((|w,h|)): the width and height of the new Rect
        * ((|rect|)): Instead of giving the location and size, you can give 
          a previously-created Rect. The new Rect will be a copy of the old.
    For convenience, ((|x,y,w,h|)) can be given as 4 separate arguments 
    instead of an Array.

--- Rect#to_s
--- inspect
    Return a string of the form "Rect(x,y,w,h)" representing the Rect.

--- Rect#to_a
    Return an Array of the form [x,y,w,h] representing the Rect.

--- Rect#[]( index )
    Return the index of the Rect as if it were an Array of the form [x,y,w,h].
--- Rect#[]=( index, value )
    Set the index of the Rect as if it were an Array of the form [x,y,w,h].

--- ==( other )
    Compare equality with another object. For this test, both self and other 
    are converted to Arrays (via each object's ((<to_a|Rect#to_a>)) method), 
    and then compared for equality. Thus, you can compare a Rect with another 
    Rect, or with an Array (or anything that can be converted into an Array).


--- Rect#clamp( rectstyle )
    Return a translated (moved) version of self that is inside the argument 
    rect. If self is too big on an axis to fit, it is centered along that axis.
    The returned Rect is normalized.

--- Rect#clamp!( rectstyle )
    Translate (move) self to be inside the argument rect. If self is too big on
    an axis to fit, it is centered along that axis. As a side effect, self is 
    normalized.

--- Rect#clip( rectstyle )
    Return a Rect that is the overlap between self and the given Rect. If they 
    do not overlap, the returned Rect will have a size of zero.

--- Rect#clip!( rectstyle )
    Resize self to cover only the area in which it overlaps with the given 
    Rect. If they do not overlap, self's width and height are set to zero.

--- Rect#collide_hash( hash of rectstyles )
    Return (({[key,value]})) for the first Rect value in the hash that collides
    with self. The hash must have Rects as values. If none of the Rects 
    collide, returns (({nil})). Because hashes are NOT ordered, don't expect 
    any particular Rect to be detected first, if there are other eligible 
    Rects.

--- Rect#collide_hash_all( hash of rectstyles )
    Return an Array of (({[key,value]})) pairs for all Rect values that collide
    with self. If none of the Rects collide with self, returns an empty Array.

--- Rect#collide_array( array of rectstyles )
    Return the integer index of the first rect in the given array which 
    collides with self. If none of the Rects collide with self, returns 
    (({nil})).

--- Rect#collide_array_all( array of rectstyles )
    Return an array of the indexes for each Rect that collides with self. If 
    none of the rects collide with self, and empty array will be returned. 

--- Rect#collide_point?( x,y )
    Return true if the given point is inside, or on the border of, self.

--- Rect#collide_rect?( rectstyle )
    Return true if self and the given rect overlap, or border, at all.

--- Rect#contain?( rectstyle )
    Return true if the given rect is entirely inside self (borders can touch).

--- Rect#inflate( x,y )
    Return a copy of self expanded by the given amounts on the x and y axes, 
    while remaining centered at the same spot.
    ((*NOTE*)): This may have unexpected results if self is not normalized 
    (that is, if it has negative width or height). The function will not 
    automatically normalize the rect before or after inflating.

--- Rect#inflate!( x,y )
    Expand self by the given amounts on the x and y axes, while remaining 
    centered at the same spot.
    ((*NOTE*)): This may have unexpected results if self is not normalized 
    (that is, if it has negative width or height). The function will not 
    automatically normalize the rect before or after inflating.

--- Rect#move( x,y )
    Return a copy of self translated (moved) by the given amounts on the x and 
    y axes.

--- Rect#move!( x,y )
    Tranlate (move) self by the given amount on the x and y axes.

--- Rect#normalize
    Return a normalized copy of self. That is, if Rect#w or Rect#h are 
    negative, they will be made positive and the self will be translated so 
    that it is in the same position as before. The normalized Rect occupies the
    same space as the non-normalized Rect, but is safer for use in functions.

--- Rect#normalize!
    Normalize self in place. That is, if self.w or self.h are negative, they 
    will be made positive and the self will be translated so that it is in the 
    same position as before. The normalized rect occupies the same space as its
    non-normalized version, but is safer for use in functions.

--- Rect#union( rectstyle )
    Return a Rect that includes the area of self and the given Rect.

--- Rect#union!( rectstyle )
    Resize self to include the area of self and the given Rect.

--- Rect#union_all( array of rectstyles )
    Return a Rect that includes the area of self and all the given Rects.

--- Rect#union_all!( array of rectstyles )
    Resize self to include the area of self and all the given Rects.
=end
