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


# Don't override existing Rect class, e.g. from rect.rb.
unless defined? Rubygame::Rect


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

  class << self

    alias :[] :new

  end


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

    unless [@x,@y,@w,@h].all?{ |i| i.is_a? Numeric }
      raise( ArgumentError, "created invalid Rect: " + 
             "[#{@x.inspect},#{@y.inspect},#{@w.inspect},#{@h.inspect}]")
    end

    @x,@y,@w,@h = [@x,@y,@w,@h].collect{ |i| i.to_f }
  end


  def to_s
    "Rect[%s,%s,%s,%s]"%[@x,@y,@w,@h]
  end
  alias :inspect :to_s


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
    @x, @y, @w, @h = r.slice(0,4).collect{ |i| i.to_f }
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
      result.to_f
    }.slice(0,4)
  end
  alias :map!  :collect!


  def ==( other )
    to_ary == other.to_ary
  end


  #--
  # ATTRIBUTES
  #++

  attr_reader :x, :y, :w, :h

  def x=( x );  @x = x.to_f;  end
  def y=( y );  @y = y.to_f;  end
  def w=( w );  @w = w.to_f;  end
  def h=( h );  @h = h.to_f;  end

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
    @w, @h = size.collect{ |i| i.to_f }
  end


  # call-seq:
  #   align!( symbol => value, ... )
  #   align!( symbol, value, ... )
  # 
  # Aligns the Rect so that the given edge or point is at the new
  # value. Moves the Rect, but does not change its size.
  # Returns self.
  # 
  # This method accepts a hash of zero or more {symbol => value} pairs
  # of edges/points to align. Alternatively, you can provide the
  # symbols and values as ordered arguments to this method.
  #
  # NOTE: The changes are applied in the order received, but hashes
  # have no defined order in Ruby 1.8 and earlier. If the order of
  # changes is important to you, you should use the non-hash form.
  # 
  # symbol:: the name of a edge or point.
  #          Valid edge names are :left, :top, :right, :bottom,
  #          :centerx, :centery.
  #          Valid points are :center, :topleft, :topright,
  #          :bottomleft, :bottomright, :midleft, :midright, :midtop,
  #          :midbottom.
  #          See the methods of the same name for their meanings.
  # 
  # value::  the new position of the edge or point.
  #          If +symbol+ is an edge name, +value+ must be a single
  #          Numeric. If +symbol+ is a point name, +value+ must be a
  #          Vector2 or array-like of two Numerics, [x,y].
  # 
  # 
  # May raise:
  # * ArgumentError if an invalid edge or point name is given,
  # * TypeError if an invalid value is given.
  # 
  # Example:
  # 
  #   rect = Rubygame::Rect.new( 1, 2, 20, 30 )
  #   
  #   rect.left                              # => 1
  #   rect.top                               # => 2
  #   rect.align!( :left => 5, :top => 4 )   # => Rect[5,4,20,30]
  #   rect.left                              # => 5
  #   rect.top                               # => 4
  #   
  #   rect.center                            # => [15, 19]
  #   rect.align!( :center => [30,30] )      # => Rect[20,15,20,30]
  #   rect.center                            # => [30, 30]
  #   
  #   # Using Ruby 1.9 keyword-style syntax:
  #   rect.bottom                            # => 45
  #   rect.align!( bottom: 5 )               # => Rect[20,-25,20,30]
  #   rect.bottom                            # => 5
  #   
  #   # Non-hash form:
  #   rect.align!( :left, 10, :top, 5 )      # => Rect[10,5,20,30]
  #   rect.left                              # => 10
  #   rect.top                               # => 5
  # 
  def align!( *opts )
    if opts[0].is_a? Hash
      # Turn {:left => 1, :top => 2} into [:left, 1, :top, 2]
      temp = []
      opts[0].to_a.each{ |k,v| temp << k << v }
      opts = temp
    end

    opts.each_slice(2) do |sym,val|
      # Argument check:
      case sym
      when :left, :top, :right, :bottom, :centerx, :centery
        # These accept a single numeric value
        if val.is_a? Numeric
          val = val.to_f
        else
          raise( TypeError, "invalid value for #{sym.inspect} " +
                 "(expected Numeric, got #{val.inspect})")
        end
      when :center, :topleft, :topright, :bottomleft, :bottomright,
           :midleft, :midright, :midtop, :midbottom
        # These accept an array of 2 numerics
        begin
          val = val.to_ary
          if val.size == 2 and val.all?{ |v| v.is_a? Numeric }
            val = val.collect{ |i| i.to_f }
          else
            raise( TypeError, "invalid value for #{sym.inspect} " +
                   "(expected [x,y], got #{val.inspect})")
          end
        rescue NoMethodError
          raise( TypeError, "invalid value for #{sym.inspect} " +
                 "(expected [x,y], got #{val.inspect})")
        end
      else
        raise ArgumentError, "invalid point #{sym.inspect}"
      end

      case sym
      when :left;          @x = val
      when :top;           @y = val
      when :right;         @x = val - @w
      when :bottom;        @y = val - @h
      when :centerx;       @x = val - @w/2.0
      when :centery;       @y = val - @h/2.0
      when :center;        @x = val[0] - @w/2.0;    @y = val[1] - @h/2.0
      when :topleft;       @x = val[0];             @y = val[1]
      when :topright;      @x = val[0] - @w;        @y = val[1]
      when :bottomleft;    @x = val[0];             @y = val[1] - @h
      when :bottomright;   @x = val[0] - @w;        @y = val[1] - @h
      when :midleft;       @x = val[0];             @y = val[1] - @h/2.0
      when :midright;      @x = val[0] - @w;        @y = val[1] - @h/2.0
      when :midtop;        @x = val[0] - @w/2.0;    @y = val[1]
      when :midbottom;     @x = val[0] - @w/2.0;    @y = val[1] - @h
      end
    end

    self
  end

  # call-seq:
  #   align( symbol => value, ... )
  #   align( symbol, value, ... )
  # 
  # Like #align!, but makes a new Rect instead of changing this Rect.
  def align( *opts )
    dup.align!( *opts )
  end


  # Returns the x coordinate of the left side of the Rect.
  def left
    @x
  end

  # Returns the y coordinate of the top side of the Rect.
  def top
    @y
  end

  # Returns the x coordinate of the right side of the Rect.
  def right
    @x + @w
  end

  # Returns the y coordinate of the bottom side of the Rect.
  def bottom
    @y + @h
  end

  # Returns the x coordinate of the center of the Rect
  def centerx
    @x + @w/2.0
  end

  # Returns the y coordinate of the center of the Rect
  def centery
    @y + @h/2.0
  end

  # Returns the x and y coordinates of the center of the Rect.
  def center
    Rubygame::Vector2.new(self.centerx, self.centery)
  end

  # Returns the x and y coordinates of the top-left corner of the Rect.
  def topleft
    Rubygame::Vector2.new(@x, @y)
  end

  # Returns the x and y coordinates of the top-right corner of the Rect
  def topright
    Rubygame::Vector2.new(right, @y)
  end

  # Returns the x and y coordinates of the bottom-left corner of the Rect
  def bottomleft
    Rubygame::Vector2.new(@x, bottom)
  end

  # Returns the x and y coordinates of the bottom-right corner of the Rect
  def bottomright
    Rubygame::Vector2.new(right, bottom)
  end

  # Returns the x and y coordinates of the midpoint on the left side
  # of the Rect.
  def midleft
    Rubygame::Vector2.new(@x, centery)
  end

  # Returns the x and y coordinates of the midpoint on the left side
  # of the Rect.
  def midtop
    Rubygame::Vector2.new(centerx, @y)
  end

  # Returns the x and y coordinates of the midpoint on the left side
  # of the Rect.
  def midright
    Rubygame::Vector2.new(right, centery)
  end

  # Returns the x and y coordinates of the midpoint on the left side
  # of the Rect.
  def midbottom
    Rubygame::Vector2.new(centerx, bottom)
  end


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

    other = begin 
              Rect.new(other)
            rescue ArgumentError
              raise ArgumentError, "invalid other rect: #{other.inspect}"
            end

    #If self is inside given, there is no need to move self
    unless other.contain?(self)

      #If self is too wide:
      if @w >= other.w
        align!(:centerx, other.centerx)
      #Else self is not too wide
      else
        #If self is to the left of arg
        if @x < other.x
          @x = other.x
        #If self is to the right of arg
        elsif right > other.right
          align!(:right, other.right)
        #Otherwise, leave x alone
        end
      end

      #If self is too tall:
      if @h >= other.h
        align!(:centery, other.centery)
      #Else self is not too tall
      else
        #If self is above arg
        if @y < other.y
          @y = other.y
        #If self below arg
        elsif bottom > other.bottom
          align!(:bottom, other.bottom)
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

    other = begin 
              Rect.new(other)
            rescue ArgumentError
              raise ArgumentError, "invalid other rect: #{other.inspect}"
            end
    other.normalize!

    if collide_rect?(other)
      x = [left,   other.left  ].max
      y = [top,    other.top   ].max
      w = [right,  other.right ].min - x
      h = [bottom, other.bottom].min - y
      @x,@y,@w,@h = x,y,w,h
    else
      #if they do not intersect at all, make size 0
      @w, @h = 0.0, 0.0
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

    other = begin 
              Rect.new(other)
            rescue ArgumentError
              raise ArgumentError, "invalid other rect: #{other.inspect}"
            end
    other.normalize!

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
    
    other = begin 
              Rect.new(other)
            rescue ArgumentError
              raise ArgumentError, "invalid other rect: #{other.inspect}"
            end
    other.normalize!

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
  #   r.inflate!(10, -8)   # => Rect[5,23,25,42]
  #   r.center             # => [17, 45]
  #   r.size               # => [25, 42]
  # 
  def inflate!(w,h)
    raise "can't modify frozen object" if frozen?

    w, h = w.to_f, h.to_f
    @x -= w/2.0
    @y -= h/2.0
    @w += w
    @h += h

    self
  end



  # call-seq:
  #   move!( [x,y] )
  #   move!( x,y )
  # 
  # Moves the Rect by the given x and y amounts.
  # A positive x moves the Rect to the right.
  # A positive y moves the Rect down.
  # 
  def move!(x,y)
    raise "can't modify frozen object" if frozen?
    if y.nil?
      a = x.to_ary
      @x += a[0]
      @y += a[1]
    else
      @x += x
      @y += y
    end
    self
  end

  # call-seq:
  #   move( [x,y] )
  #   move( x,y )
  # 
  # Like #move!, but makes a new Rect instead of changing this Rect.
  def move(x,y=nil)
    dup.move!(x,y)
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



  # call-seq:
  #   stretch!( symbol => value, ... )
  #   stretch!( symbol, value, ... )
  # 
  # Stretches the Rect so that the given edge or point is at the new
  # value. The opposite edge or point will remain stationary. For
  # example, if you stretch :topleft, :bottomright will not change.
  # Returns self.
  # 
  # This method accepts a hash of zero or more {symbol => value} pairs
  # of edges/points to stretch. Alternatively, you can provide the
  # symbols and values as ordered arguments to this method.
  #
  # NOTE: The changes are applied in the order received, but hashes
  # have no defined order in Ruby 1.8 and earlier. If the order of
  # changes is important to you, you should use the non-hash form.
  # 
  # symbol:: the name of a edge or point.
  #          Valid edge names are :left, :top, :right, :bottom.
  #          Valid points are :topleft, :topright, :bottomleft,
  #          :bottomright.
  #          See the methods of the same name for their meanings.
  # 
  # value::  the new position of the edge or point.
  #          If +symbol+ is an edge name, +value+ must be a single
  #          Numeric. If +symbol+ is a point name, +value+ must be a
  #          Vector2 or array-like of two Numerics, [x,y].
  # 
  # 
  # May raise:
  # * ArgumentError if an invalid edge or point name is given,
  # * TypeError if an invalid value is given.
  # 
  # Example:
  # 
  #   rect = Rubygame::Rect.new( 1, 2, 20, 30 )
  #   
  #   rect.topleft                           # => Vector2[1,2]
  #   rect.bottomright                       # => Vector2[21,32]
  #   rect.stretch!( :left => 5, :top => 4 ) # => Rect[5,4,16,28]
  #   rect.topleft                           # => Vector2[5,4]
  #   rect.bottomright                       # => Vector2[21,32]
  #   
  #   rect.topright                          # => Vector2[21, 4]
  #   rect.bottomleft                        # => Vector2[5,32]
  #   rect.stretch!( :topright => [20,10] )  # => Rect[5,10,15,22]
  #   rect.topright                          # => Vector2[30, 30]
  #   rect.bottomleft                        # => Vector2[5,32]
  #   
  #   # Using Ruby 1.9 keyword-style syntax:
  #   rect.stretch!( bottom: 12 )            # => Rect[5,10,15,2]
  #   rect.bottom                            # => 12
  #   
  #   # Non-hash form:
  #   rect.stretch!( :left, 10, :top, 5 )    # => Rect[10,5,10,7]
  #   rect.topleft                           # => Vector2[10,5]
  # 
  def stretch!( *opts )
    if opts[0].is_a? Hash
      # Turn {:left => 1, :top => 2} into [:left, 1, :top, 2]
      temp = []
      opts[0].to_a.each{ |k,v| temp << k << v }
      opts = temp
    end

    opts.each_slice(2) do |sym,val|
      # Argument check:
      case sym
      when :left, :top, :right, :bottom
        # These accept a single numeric value
        if val.is_a? Numeric
          val = val.to_f
        else
          raise( TypeError, "invalid value for #{sym.inspect} " +
                 "(expected Numeric, got #{val.inspect})")
        end
      when :topleft, :topright, :bottomleft, :bottomright
        # These accept an array of 2 numerics
        begin
          val = val.to_ary
          if val.size == 2 and val.all?{ |v| v.is_a? Numeric }
            val = val.collect{ |i| i.to_f }
          else
            raise( TypeError, "invalid value for #{sym.inspect} " +
                   "(expected [x,y], got #{val.inspect})")
          end
        rescue NoMethodError
          raise( TypeError, "invalid value for #{sym.inspect} " +
                 "(expected [x,y], got #{val.inspect})")
        end
      else
        raise ArgumentError, "invalid point #{sym.inspect}"
      end

      case sym
      when :left
        @w += @x - val
        @x = val
      when :right
        @w = val - @x
      when :top
        @h += @y - val
        @y = val
      when :bottom
        @h = val - @y
      when :topleft
        @w += @x - val[0]
        @h += @y - val[1]
        @x, @y = val
      when :topright
        @w = val[0] - @x
        @h += @y - val[1]
        @y = val[1]
      when :bottomleft
        @w += @x - val[0]
        @x = val[0]
        @h = val[1] - @y
      when :bottomright
        @w = val[0] - @x
        @h = val[1] - @y
      end
    end

    self
  end

  # call-seq:
  #   stretch( symbol => value, ... )
  #   stretch( symbol, value, ... )
  # 
  # Like #stretch!, but makes a new Rect instead of changing this Rect.
  def stretch( *opts )
    dup.stretch!( *opts )
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
    
    other = begin 
              Rect.new(other)
            rescue ArgumentError
              raise ArgumentError, "invalid other rect: #{other.inspect}"
            end
    other.normalize!

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


end # unless defined? Rubygame::Rect
