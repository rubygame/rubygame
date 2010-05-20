#--
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2010  John Croisant
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++



module Rubygame

# A Rect is a representation of a rectangle, with four core attributes
# (x offset, y offset, width, and height) and a variety of functions
# for manipulating and accessing these attributes.
#
# Like all coordinates in Rubygame (and its base library, SDL), x and y
# offsets are measured from the top-left corner of the screen, with greater
# y offsets being lower. Thus, specifying the x and y offsets of the Rect
# is equivalent to setting the location of its top-left corner.
#
# In Rubygame, Rects are used for collision detection and describing
# the area of a Surface to operate on.
#
class Rect

  require 'enumerator'
  include Enumerable

  #--
  # GENERAL
  #++

  # Create a new Rect, attempting to extract its own information from
  # the given arguments. The arguments must fall into one of these cases:
  #
  #   - 4 integers +(x, y, w, h)+.
  #   - 1 Rect or Array containing 4 integers +([x, y, w, h])+.
  #   - 2 Arrays containing 2 integers each +([x,y], [w,h])+.
  #   - 1 object with a +rect+ attribute which is a valid Rect object.
  #
  # All rect core attributes (x,y,w,h) must be integers.
  #
  def initialize(x, y=nil, w=nil, h=nil)
    if y.nil?
      if x.respond_to? :to_ary
        @x,@y,@w,@h = x.to_ary[0,4]
      elsif x.respond_to? :rect
        @x,@y,@w,@h = x.rect.to_ary[0,4]
      end
    elsif h.nil?
      @x,@y = x[0,2]
      @w,@h = y[0,2]
    else
      @x,@y,@w,@h = x, y, w, h
    end
  end

  # Extract or generate a Rect from the given object, if possible, using the
  # following process:
  #
  #  1. If it's a Rect already, return a duplicate Rect.
  #  2. Elsif it's an Array with at least 4 values, make a Rect from it.
  #  3. Elsif it has a +rect+ attribute., perform (1) and (2) on that.
  #  4. Otherwise, raise TypeError.
  #
  # See also Surface#make_rect()
  # 
  def Rect.new_from_object(object)
    case(object)
    when Rect
      return object.dup
    when Array
      if object.length >= 4
        return Rect.new(object)
      else
        raise( ArgumentError,
               "Array is too short to create a Rect: #{object.inspect}" )
      end
    else
      begin
        case(object.rect)
        when Rect
          return object.rect.dup
        when Array
          if object.rect.length >= 4
            return Rect.new(object.rect)
          else
            raise( ArgumentError, "#{object.inspect} .rect is too short " +
                   "to create a Rect: #{object.rect.inspect}" )
          end
        end
      rescue NoMethodError
        raise( TypeError, "Object must be a Rect or Array [x,y,w,h], " +
               "or have an attribute called 'rect'. (Got #{object.inspect})" )
      end
    end
  end


  def to_s
    "#<Rect [%d,%d,%d,%d]>"%[@x,@y,@w,@h]
  end

  def inspect
    "#<Rect:%#.x [%s,%s,%s,%s]>"%[object_id,@x,@y,@w,@h]
  end


  # Returns an SDL::Rect version of this Rect. Float values are
  # rounded to the nearest integer.
  #
  def to_sdl                    # :nodoc:
    SDL::Rect.new( normalize.collect{|n| n.round } )
  end


  # Returns the Rect as an Array: [x,y,w,h]
  def to_ary
    [@x,@y,@w,@h]
  end
  alias :to_a  :to_ary

  # Returns the length of the Rect (which is always 4). This is
  # useless, but kept for backwards compatibility.
  # 
  def length
    4
  end
  alias :size  :length

  # Return the value of the Rect at that index, as if it were an
  # [x,y,w,h] array.
  # 
  def at(index)
    to_ary.at(index)
  end

  def [](*args)
    to_ary[*args]
  end

  def []=(*args)
    r = to_ary
    r.[]=(*args)
    @x, @y, @w, @h = r.slice(0,4)
  end

  # Iterate over [x,y,w,h], yielding each to the block.
  def each( &block )
    to_ary.each(&block)
  end

  # Iterate over [x,y,w,h], yielding each to the block, then storing
  # the result back in the Rect. May raise TypeError if the block
  # returns a non-numeric result.
  # 
  def collect!( &block )
    @x, @y, @w, @h = to_ary.collect{ |i|
      result = block.call(i)
      unless result.is_a? Numeric
        raise TypeError, "Block returned a non-numeric result: #{i.inspect}"
      end
      result
    }.slice(0,4)
  end
  alias :map!  :collect!


  def ==( other )
    to_ary == other.to_ary
  end


  #--
  # ATTRIBUTES
  #++

  attr_accessor :x, :y, :w, :h

  alias :left     :x
  alias :left=    :x=
  alias :l        :x
  alias :l=       :x=

  alias :top      :y
  alias :top=     :y=
  alias :t        :y
  alias :t=       :y=

  alias :width    :w
  alias :width=   :w=

  alias :height   :h
  alias :height=  :h=


  # Return the width and height of the Rect.
  def size
    [@w, @h]
  end

  # Set the width and height of the Rect.
  def size=(size)
    if size.size != 2
      raise ArgumentError, "Expected [width, height], got #{size.inspect}."
    end
    @w, @h = size
  end



  # Return the x coordinate of the right side of the Rect.
  def right
    @x + @w
  end

  # Set the x coordinate of the right side of the Rect by translating the
  # Rect (adjusting the x offset).
  def right=(r)
    @x = r - @w
  end

  alias :r   :right
  alias :r=  :right=



  # Return the y coordinate of the bottom side of the Rect.
  def bottom
    @y + @h
  end

  # Set the y coordinate of the bottom side of the Rect by translating the
  # Rect (adjusting the y offset).
  def bottom=(b)
    @y = b - @h
  end

  alias :b   :bottom
  alias :b=  :bottom=



  # Return the x and y coordinates of the center of the Rect.
  def center
    [self.centerx, self.centery]
  end

  # Set the x and y coordinates of the center of the Rect by translating the
  # Rect (adjusting the x and y offsets).
  def center=(center)
    if center.size != 2
      raise ArgumentError, "Expected [x, y], got #{center.inspect}."
    end
    self.centerx, self.centery = center
  end

  alias :c   :center
  alias :c=  :center=



  # Return the x coordinate of the center of the Rect
  def centerx
    @x + @w.div(2)
  end

  # Set the x coordinate of the center of the Rect by translating the
  # Rect (adjusting the x offset).
  def centerx=(x)
    @x = x - @w.div(2)
  end

  alias :cx   :centerx
  alias :cx=  :centerx=



  # Return the y coordinate of the center of the Rect
  def centery
    @y + @h.div(2)
  end

  # Set the y coordinate of the center of the Rect by translating the
  # Rect (adjusting the y offset).
  def centery=(y)
    @y = y - @h.div(2)
  end

  alias :cy   :centery
  alias :cy=  :centery=



  # Return the x and y coordinates of the top-left corner of the Rect.
  def topleft
    [@x, @y]
  end

  # Set the x and y coordinates of the top-left corner of the Rect by
  # translating the Rect (adjusting the x and y offsets).
  def topleft=(topleft)
    if topleft.size != 2
      raise ArgumentError, "Expected [x, y], got #{topleft.inspect}."
    end
    @x, @y = topleft
  end

  alias :tl   :topleft
  alias :tl=  :topleft=



  # Return the x and y coordinates of the top-right corner of the Rect
  def topright
    [right, @y]
  end

  # Set the x and y coordinates of the top-right corner of the Rect by
  # translating the Rect (adjusting the x and y offsets).
  def topright=(topright)
    if topright.size != 2
      raise ArgumentError, "Expected [x, y], got #{topright.inspect}."
    end
    self.right, @y = topright
  end

  alias :tr   :topright
  alias :tr=  :topright=



  # Return the x and y coordinates of the bottom-left corner of the Rect
  def bottomleft
    [@x, bottom]
  end

  # Set the x and y coordinates of the bottom-left corner of the Rect by
  # translating the Rect (adjusting the x and y offsets).
  def bottomleft=(bottomleft)
    if bottomleft.size != 2
      raise ArgumentError, "Expected [x, y], got #{bottomleft.inspect}."
    end
    @x, self.bottom = bottomleft
  end

  alias :bl   :bottomleft
  alias :bl=  :bottomleft=



  # Return the x and y coordinates of the bottom-right corner of the Rect
  def bottomright
    [right, bottom]
  end

  # Set the x and y coordinates of the bottom-right corner of the Rect by
  # translating the Rect (adjusting the x and y offsets).
  def bottomright=(bottomright)
    if bottomright.size != 2
      raise ArgumentError, "Expected [x, y], got #{bottomright.inspect}."
    end
    self.right, self.bottom = bottomright
  end

  alias :br   :bottomright
  alias :br=  :bottomright=



  # Return the x and y coordinates of the midpoint on the left side of the
  # Rect.
  def midleft
    [@x, centery]
  end

  # Set the x and y coordinates of the midpoint on the left side of the Rect
  # by translating the Rect (adjusting the x and y offsets).
  def midleft=(midleft)
    if midleft.size != 2
      raise ArgumentError, "Expected [x, y], got #{midleft.inspect}."
    end
    @x, self.centery = midleft
  end

  alias :ml   :midleft
  alias :ml=  :midleft=



  # Return the x and y coordinates of the midpoint on the left side of the
  # Rect.
  def midtop
    [centerx, @y]
  end

  # Set the x and y coordinates of the midpoint on the top side of the Rect
  # by translating the Rect (adjusting the x and y offsets).
  def midtop=(midtop)
    if midtop.size != 2
      raise ArgumentError, "Expected [x, y], got #{midtop.inspect}."
    end
    self.centerx, @y = midtop
  end

  alias :mt   :midtop
  alias :mt=  :midtop=



  # Return the x and y coordinates of the midpoint on the left side of the
  # Rect.
  def midright
    [right, centery]
  end

  # Set the x and y coordinates of the midpoint on the right side of the Rect
  # by translating the Rect (adjusting the x and y offsets).
  def midright=(midright)
    if midright.size != 2
      raise ArgumentError, "Expected [x, y], got #{midright.inspect}."
    end
    self.right, self.centery = midright
  end

  alias :mr   :midright
  alias :mr=  :midright=



  # Return the x and y coordinates of the midpoint on the left side of the
  # Rect.
  def midbottom
    [centerx, bottom]
  end

  # Set the x and y coordinates of the midpoint on the bottom side of the
  # Rect by translating the Rect (adjusting the x and y offsets).
  def midbottom=(midbottom)
    if midbottom.size != 2
      raise ArgumentError, "Expected [x, y], got #{midbottom.inspect}."
    end
    self.centerx, self.bottom = midbottom
  end

  alias :mb   :midbottom
  alias :mb=  :midbottom=



  #--
  # UTILITY METHODS
  #++


  # Like #clamp!, but makes a new Rect instead of changing this Rect.
  def clamp(other)
    dup.clamp!(other)
  end

  # Move the calling Rect to be entirely inside the given Rect. If the
  # caller is too large along either axis to fit in the given rect, it
  # is centered with respect to the given rect, along that axis.
  def clamp!(other)
    raise "can't modify frozen object" if frozen?

    normalize!
    other = Rect.new_from_object(other)
    #If self is inside given, there is no need to move self
    unless other.contain?(self)

      #If self is too wide:
      if @w >= other.w
        self.centerx = other.centerx
      #Else self is not too wide
      else
        #If self is to the left of arg
        if @x < other.x
          @x = other.x
        #If self is to the right of arg
        elsif right > other.right
          self.right = other.right
        #Otherwise, leave x alone
        end
      end

      #If self is too tall:
      if @h >= other.h
        self.centery = other.centery
      #Else self is not too tall
      else
        #If self is above arg
        if @y < other.y
          @y = other.y
        #If self below arg
        elsif bottom > other.bottom
          self.bottom = other.bottom
        #Otherwise, leave y alone
        end
      end
    end

    self
  end



  # Like #clip!, but makes a new Rect instead of changing this Rect.
  def clip(other)
    dup.clip!(other)
  end

  # Crop the calling Rect to be entirely inside the given Rect. If the
  # caller does not intersect the given Rect at all, its width and
  # height are set to zero, but its x and y offsets are not changed.
  #
  # As a side effect, the Rect is normalized.
  def clip!(other)
    raise "can't modify frozen object" if frozen?

    normalize!
    other = Rect.new_from_object(other).normalize!

    if collide_rect?(other)
      x = [left,   other.left  ].max
      y = [top,    other.top   ].max
      w = [right,  other.right ].min - x
      h = [bottom, other.bottom].min - y
      @x,@y,@w,@h = x,y,w,h
    else
      #if they do not intersect at all, make size 0
      @w, @h = 0, 0
    end

    self
  end



  # Iterate through all key/value pairs in the given hash, and return
  # the first pair whose value is a Rect that collides with the
  # caller.
  #
  # Because a hash table is unordered (in Ruby 1.8), you should not
  # expect any particular Rect to be returned first.
  #
  def collide_hash(hash_rects)
    hash_rects.find{ |key,value| collide_rect? value }
  end

  # Iterate through all key/value pairs in the given hash table, and
  # return an Array of every pair whose value is a Rect that collides
  # the caller.
  #
  # Because a hash table is unordered (in Ruby 1.8), you should not
  # expect the returned pairs to be in any particular order.
  def collide_hash_all(hash_rects)
    hash_rects.find_all{ |key,value| collide_rect? value }
  end



  # Returns the index of the first Rect in the array that collides
  # with this Rect.
  # 
  def collide_array(array_rects)
    array_rects.each_with_index{ |i, rect|
      return i if collide_rect?(rect)
    }
    nil
  end

  # Return the indices of every Rect in the array that collides with
  # this Rect.
  # 
  def collide_array_all(array_rects)
    array_rects.to_enum(:each_with_index).collect{ |i, rect|
      i if collide_rect?(rect)
    }.compact
  end



  # True if the point is inside (including on the border) this Rect.
  def collide_point?(x,y)
    nself = normalize

    ( x.between?(nself.left, nself.right) and
      y.between?(nself.top,  nself.bottom) )
  end



  # True if this Rect and the other Rect overlap (or touch) at all.
  def collide_rect?(other)
    nself = normalize
    other = Rect.new_from_object(other).normalize!

    ( nself.left.between?(other.left, other.right) or
      other.left.between?(nself.left, nself.right) ) and
      ( nself.top.between?(other.top, other.bottom) or
        other.top.between?(nself.top, nself.bottom) )
  end



  # True if the other Rect is totally within this Rect. Borders may
  # overlap.
  # 
  def contain?(other)
    nself = normalize
    other = Rect.new_from_object(other).normalize!

    ( nself.left     <= other.left   ) and
      ( other.right  <= nself.right  ) and
      ( nself.top    <= other.top    ) and
      ( other.bottom <= nself.bottom )
  end



  # Like #inflate!, but makes a new Rect instead of changing this Rect.
  def inflate(x,y)
    dup.inflate!(x,y)
  end

  # Increase this Rect's width and height by certain amounts, while
  # keeping (approximately) the same center point. Negative numbers
  # decrease the width and height.
  # 
  # For best results, always use even numbers. If you use an odd
  # number, the center point may move slightly due to rounding.
  # 
  # Example:
  # 
  #   r = Rubygame::Rect.new(10, 20, 15, 50)
  #   r.center             # => [17, 45]
  #   r.size               # => [15, 50]
  # 
  #   r.inflate!(10, -8)   # => #<Rect [5,23,25,42]>
  #   r.center             # => [17, 45]
  #   r.size               # => [25, 42]
  # 
  def inflate!(w,h)
    raise "can't modify frozen object" if frozen?

    @x -= w.div(2)
    @y -= h.div(2)
    @w += w
    @h += h

    self
  end



  # Like #move!, but makes a new Rect instead of changing this Rect.
  def move(x,y)
    dup.move!(x,y)
  end

  # Move (translate) this Rect by the given amounts (in pixels).
  # A positive x moves the Rect to the right.
  # A positive y moves the Rect down.
  # 
  def move!(x,y)
    raise "can't modify frozen object" if frozen?

    @x += x
    @y += y

    self
  end



  # Like #normalize!, but makes a new Rect instead of changing this Rect.
  def normalize
    dup.normalize!
  end

  # Fix Rects that have negative width or height, without changing the
  # area it represents. Has no effect on Rects with non-negative width
  # and height. Some Rect methods will automatically normalize the Rect.
  # 
  def normalize!
    raise "can't modify frozen object" if frozen?

    if @w < 0
      @x, @w = (@x+@w), -@w
    end
    if @h < 0
      @y, @h = (@y+@h), -@h
    end

    self
  end



  # Like #union!, but makes a new Rect instead of changing this Rect.
  def union(other)
    dup.union!(other)
  end

  # Expand this Rect so it also contains the other Rect. It may also
  # contain areas that neither of the original Rects did, for example
  # areas between the two Rects.
  # 
  def union!(other)
    raise "can't modify frozen object" if frozen?

    normalize!
    other = Rect.new_from_object(other).normalize!

    l = [left,   other.left  ].min
    t = [top,    other.top   ].min
    r = [right,  other.right ].max
    b = [bottom, other.bottom].max

    @x,@y,@w,@h = l, t, (r - l), (b - t)

    self
  end



  # Like #union_all!, but makes a new Rect instead of changing this Rect.
  def union_all(array_rects)
    dup.union_all!(array_rects)
  end

  # Expand the caller to cover all of the given Rects. See also #union!
  def union_all!(array_rects)
    raise "can't modify frozen object" if frozen?

    array_rects.each{ |rect| union!(rect) }

    self
  end


end # class Rect

end # module Rubygame
