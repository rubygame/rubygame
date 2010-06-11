# Hotspot, a mixin module to extend an object with custom, named, relative 
# position offsets.
#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2007  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++


Rubygame.deprecated("Rubygame::Hotspot", "3.0")


module Rubygame

  # *NOTE*: Hotspot is DEPRECATED and will be removed in Rubygame 3.0!
  # 
  # *NOTE*: you must require 'rubygame/hotspot' manually to gain access to
  # Rubygame::Hotspot. It is not imported with Rubygame by default!
  # 
  # Hotspot is a mixin module to extend an object with "hotspots": custom,
  # named, relative position offsets. Hotspots can be defined relative to the
  # origin, to another hotspot, or to the results of a method (via a 
  # 'smart' hotspot).
  # 
  # There are two types of hotspots, simple and 'smart'.
  # 
  # Simple hotspots are an Array of three values, an x offset, a y offset,
  # and the label of another hotspot relative to which this hotspot is defined.
  # If the last argument is omitted or nil, the hotspot is defined relative
  # to the true origin (i.e. (0,0), the top-left corner of the Screen).
  # See #new_hotspot.
  # 
  # Smart hotspots, or 'smartspots' for short, act as a proxy to the object's
  # methods. Each time a smartspot is evaluated, it calls the object's method
  # of the same name as the smartspot, and uses the results of the method as
  # x and y offsets. Therefore, smartspots only work for methods which:
  #  1. take no arguments
  #  2. return an Array with 2 Numeric values (or something else that responds
  #     to #[]
  #
  # By adding a smartspot to a Rect, for example, you could define simple 
  # hotspots relative to its Rect#center; then, even if the Rect moves or
  # changes size, the smartspot will always to evaluate to its true center.
  # See #new_smartspot.
  # 
  #--
  # ((Old documentation/brainstorming))
  # As an example, consider an object which represents a person's face: eyes, 
  # ears, nose, mouth, etc. You might make a face and define several hotspots
  # like so:
  # 
  #  myface = Face.new()                # Create a new face, with no hotspots.
  #  myface.extend(Hotspot)             # Extend myface with hotspot ability.
  #  myface.new_hotspot \               # Define some new hotspots: ...
  #   :nose => [10,5, :center],        # the nose, relative to face's center,
  #   :left_eye => [-5,-2, :nose],     # the left eye, left and above the nose,
  #   :left_brow => [0,-5, :left_eye], # the left eye-brow, above the left eye.
  # 
  # Please note that +:center+ is a "virtual" hotspot. When the coordinates of
  # +:center+ are requested, +myface+'s #center method is called* and the
  # results used as the coordinates. (* Technically, +myface+ is sent
  # +:center+, which is not exactly the same as calling #center.)
  # 
  # Now, suppose we want to find out where :left_brow is, in absolute
  # coordinates (i.e. relative to the origin). We can do this, even if +myface+
  # has moved, or the hotspots have been changed:
  # 
  #  myface.left_brow                   # => [5,-2]
  #  myface.move(20,-12)                # moves the face right and up
  #  myface.left_brow                   # => [25,-14]
  #  myface.new_hotspot \
  #    :left_eye => [-10,3]             # redefine the left_eye hotspot
  #  myface.left_brow                   # => [20,-9]
  # 
  # Where do [5,-2], [25,-24], and [20,-9] come from? They are the vector sums
  # of each hotspot in the chain: left_brow, left_eye, nose, and center. See
  # #hotspot for more information.
  #++
  # 
  module Hotspot
    # :call-seq: def_hotspot label => [x,y,parent]
    # 
    # Define +label+ as a simple hotspot, a custom reference coordinate 
    # point +x+ pixels to the right and +y+ pixels below the hotspot whose
    # label is +parent+.
    # You may omit +parent+, in which case the hotspot will evaluate relative
    # to the origin, i.e. the top-left corner of the Screen.
    # 
    # See also #def_smartspot to create a 'smart hotspot'.
    # 
    # +label+ must be usable as a key in a Hash table. Additionally, if you
    # want <code>myobject.{label}</code> to work like 
    # <code>myobject.hotspot({label})</code>, +label+ must be a :symbol.
    # 
    # *IMPORTANT*: Do NOT create circular hotspot chains (e.g. a -> b -> a).
    # Doing so will raise SystemStackError when #hotspot is asked to evaluate
    # any hotspot in that chain. Hotspots are not yet smart enough to detect
    # circular chains.
    # 
    # Hotspots can be defined in any order, as long as you define all the
    # hotspots in a chain before that chain is evaluated with #hotspot.
    #
    # You may define multiple hotspots simultaneously by separating the 
    # definitions by commas. For example:
    # 
    #   def_hotspot label => [x,y,parent], label2 => [x,y,parent]
    # 
    # Users of the Rake library will recognize this style of syntax.
    # It is simply constructing a Hash object and passing it as the
    # only argument to #new_hotspot. The above code is equivalent to:
    # 
    #   def_hotspot( { label => [x,y,parent], label2 => [x,y,parent] } )
    def def_hotspot(dfn)
      @hotspots.update(dfn)
    rescue NoMethodError => e
      unless defined? @hotspots
        @hotspots = Hash.new
        retry
      else raise e
      end
    end

    # Remove all simple hotspots whose label is included in +*labels+.
    def undef_hotspot(*labels)
      labels.flatten.each do |l|
        @hotspots.delete(l)
      end
    end

    # True if +label+ has been defined as a simple hotspot.
    def defined_hotspot?(label)
      @hotspots.include? label
    rescue NoMethodError => e
      unless defined? @hotspots
        false
      else raise e
      end
    end

    # :call-seq: hotspot(label)
    # 
    # Returns the absolute coordinates represented by the hotspot +label+.
    # Will return nil if the hotspot (or one of its ancestors) does not exist.
    # 
    # This method will recursively evaluate the hotspot, it's parent hotspot
    # (if any), and so on, until a parent-less hotspot or a smartspot is found.
    # 
    # (*NOTE*: this means that a circular chains (e.g. a -> b -> a)
    # will keep going around and around until the ruby interpreter
    # raises SystemStackError!)
    #
    # The final value returned by this method will be the vector component sum
    # of all the hotspots in the chain. For example, if you have this chain:
    # 
    #   :a => [1, 2, :b]
    #   :b => [4, 8, :c]
    #   :c => [16,32]
    # 
    # the value returned for +:a+ would be [21,42], i.e. [1+4+16, 2+8+32]
    #--
    # The x and y arguments are used for recursive accumulation, although
    # I suppose you could use them to create a temporary offset by giving
    # something besides zero when you look up a hotspot.
    #++
    def hotspot(label,x=0,y=0)
      a = @hotspots[label]
      if a[2].nil?              # has no parent
        [x+a[0],y+a[1]]
      else                      # has a parent
        hotspot(a[2],x+a[0],y+a[1])
      end
    rescue NoMethodError => e
      if not(defined? @hotspots)
        return nil
      elsif a.nil?
        smartspot(label,x,y)
      else raise e
      end
    end

    # Define each label in +*labels+ as a smartspot ('smart hotspot').
    # 
    # To prevent outside objects from abusing hotspots to call arbitrary 
    # methods, a smartspot must be defined for each method before it can be 
    # used as a parent to a hotspot.
    # 
    # The label must be a :symbol, and it must be identical to the name of the
    # method to be called.
    def def_smartspot(*labels)
      @smartspots += labels.flatten
      @smartspots.uniq!
    rescue NoMethodError => e
      unless defined? @smartspots
        @smartspots = Array.new
        retry
      else raise e
      end
    end

    # Remove all smartspots whose label is included in +*labels+.
    def undef_smartspot(*labels)
      @smartspots -= labels.flatten
    end

    # True if +label+ has been defined as a smartspot.
    def defined_smartspot?(label)
      @smartspots.include? label
    rescue NoMethodError => e
      unless defined? @smartspots
        false
      else raise e
      end
    end

    # :call-seq: smartspot(label)
    # 
    # Evaluate the smartspot +label+, calling the method of the same name as
    # +label+. Will return nil if no such smartspot has been defined.
    #--
    # The x and y arguments are used for recursive accumulation.
    #++
    def smartspot(label,x=0,y=0)
      if @smartspots.include? label
        a = self.send(label)
        [x+a[0],y+a[1]]
      else
        nil
      end
    rescue NoMethodError => e
      unless defined? @smartspots
        nil
      else raise e
      end
    end

    #--
    # 
    # TODO:
    # Methods for changing the position of the object indirectly, 
    # by saying where the hotspot should be.
    # You could do this: my_object.foot = [5,3], and if foot was defined
    # relative to, say, #center, it would set center = [5-x_offset, 3-y_offset]
    # 
    # It should be recursive to work with chains of hotspots too.
    # 
    #++ 

    alias :old_method_missing :method_missing

    def method_missing(symbol,*args)
      if have_hotspot?(symbol) 
        hotspot(symbol)
      else old_method_missing(symbol,*args)
      end
    end
    
  end
end
