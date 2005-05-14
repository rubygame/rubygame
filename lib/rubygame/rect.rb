#--
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004  John 'jacius' Croisant
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

#Table of Contents:
#
#Rubygame.rect_from_object
#
#class Rect
#	GENERAL:
#		initialize
#		to_s
#		to_a, to_ary
#		[]
#	ATTRIBUTES:
#		x, y, w, h [<- accessors]
#		width, height, size
#		left, top, right, bottom
#		center, centerx, centery
#		topleft, topright
#		bottomleft, bottomright
#		midleft, midtop, midright, midbottom
#	METHODS:
#		clamp, clamp!
#		clip, clip!
#		collide_hash, collide_hash_all
#		collide_array, collide_array_all
#		collide_point?
#		collide_rect?
#		contain?
#		inflate, inflate!
#		move, move!
#		normalize, normalize!
#		union, union!
#		union_all, union_all!

module Rubygame

	# Extract or generate a Rect from the given object, if possible, using the
	# following process:
	# 
	#  1. If it's a Rect already, return a duplicate Rect.
	#  2. Elsif it's an Array with at least 4 values, make a Rect from it.
	#  3. Elsif it has a rect attribute, repeat this process on that attribute.
	#  4. Otherwise, raise TypeError.
	# 
	def rect_from_object(object,recurse=0)
		case(rect.class)
		when Rect
			return self.dup
		when Array 
			if rect.length >= 4
				return Rect.new(object)
			else
				raise ArgumentError("Array does not have enough indices to be made into a Rect (%d for 4)."%rect.length )
			end
		else
			begin 
				if recurse < 1
					return rect_from_object(rect.rect, recurse+1)
				else
					raise TypeError("Object must be a Rect or Array [x,y,w,h], or have an attribute called 'rect'. (Got %s instance)."%rect.class)
				end
			rescue NoMethodError # if no rect.rect
				raise TypeError("Object must be a Rect or Array [x,y,w,h], or have an attribute called 'rect'. (Got %s instance.)"%rect.class)
			end
		end # case
	end

#--
# Maybe Rect should be based on Array? Haven't we been through this before?
# Or was that with Sprite::Group...
#++

# A Rect is a representation of a rectangle, with four core attributes
# (x offset, y offset, width, and height) and a variety of functions
# for manipulating and accessing these attributes.
# 
# Like all coordinates in Rubygame (and its base library, SDL), x and y
# offsets are measured from the top-left corner of the screen, with larger y
# offsets being lower. Thus, specifying the x and y offsets of the Rect is
# equivalent to setting the location of its top-left corner.
# 
# In Rubygame, Rects are used for collision detection and describing 
# the area of a Surface to operate on.
class Rect

	# Create a new Rect, attempting to extract its own information from 
	# the given arguments. The arguments must fall into one of these cases:
	# 
	#   - 4 integers, +(x, y, w, h)+.
	#   - 1 Array containing 4 integers, +([x, y, w, h])+.
	#   - 2 Arrays containing 2 integers each, +([x,y], [w,h])+.
	#   - 1 valid Rect object.
	#   - 1 object with a +rect+ attribute (such as a Sprite) which is valid 
	#     Rect object.
	# 
	# All rect core attributes (x,y,w,h) must be integers.
	# 
	def initialize(*argv)
		case argv.length
		when 1
			if argv[0].kind_of? Rect; @x,@y,@w,@h = argv[0].to_a;
			elsif argv[0].kind_of? Array; @x,@y,@w,@h = argv[0];
			elsif argv[0].respond_to? :rect; @x,@y,@w,@h=argv[0].rect.to_a;
			end
		when 2
			@x,@y = argv[0]
			@w,@h = argv[1]
		when 4
			@x,@y,@w,@h = argv
		end
		return self
	end

	# Print the Rect in the form "+Rect(x,y,w,h)+"
	def to_s; "Rect(%s,%s,%s,%s)"%[@x,@y,@w,@h]; end
	alias inspect to_s

	# Return an Array of the form +[x,y,w,h]+
	def to_a; [@x,@y,@w,@h]; end

	# Return the value of the Rect at the index as if it were an Array of the
	# form [x,y,w,h].
	def [](i); self.to_a[i]; end

	# Set the value of the Rect at the index as if it were an Array of the form
	# [x,y,w,h].
	def []=(i,value)
		case(i)
		when 0; @x = value
		when 1; @y = value
		when 2; @w = value
		when 3; @h = value
		end
		return value
	end

	# Convert the Rect and the other object to an Array (using #to_a) and
	# test equality.
	def ==(other)
		other.to_a == self.to_a
	end

	############################
	##### RECT  ATTRIBUTES #####
	############################

	# Core attributes (x offset, y offset, width, height)
	attr_accessor :x, :y, :w, :h

	alias width w
	alias width= w=;

	alias height h
	alias height= h=;

	# Return the width and height of the Rect.
	def size; [@w, @h]; end

	# Set the width and height of the Rect.
	def size=(size); @w, @h = size; return size; end

	alias left x
	alias left= x=;
	alias l x
	alias l= x=;

	alias top y
	alias top= y=;
	alias t y
	alias t= y=;

	# Return the x coordinate of the right side of the Rect.
	def right; @x+@w; end

	# Set the x coordinate of the right side of the Rect by translating the
	# Rect (adjusting the x offset).
	def right=(r); @x = r - @w; return r; end

	alias r right
	alias r= right=;

	# Return the y coordinate of the bottom side of the Rect.
	def bottom; @y+@h; end

	# Set the y coordinate of the bottom side of the Rect by translating the
	# Rect (adjusting the y offset).
	def bottom=(b); @y = b - @h; return b; end

	alias b bottom
	alias b= bottom=;

	# Return the x and y coordinates of the center of the Rect.
	def center; [@x+@w/2, @y+@h/2]; end

	# Set the x and y coordinates of the center of the Rect by translating the
	# Rect (adjusting the x and y offsets).
	def center=(center)
		@x, @y = center[0]-@w/2, center[1]-@h/2
		return center
	end
	alias c center
	alias c= center=;

	# Return the x coordinate of the center of the Rect
	def centerx; @x+@w/2; end

	# Set the x coordinate of the center of the Rect by translating the
	# Rect (adjusting the x offset).
	def centerx=(x); @x = x-@w/2; return x; end

	alias cx centerx
	alias cx= centerx=;

	# Return the y coordinate of the center of the Rect
	def centery; @y+@h/2; end

	# Set the y coordinate of the center of the Rect by translating the
	# Rect (adjusting the y offset).
	def centery=(y); @y = y-@h/2; return y; end

	alias cy centery
	alias cy= centery=;

	# Return the x and y coordinates of the top-left corner of the Rect
	def topleft; [@x,@y]; end

	# Set the x and y coordinates of the top-left corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def topleft=(topleft)
		@x, @y = *topleft
		return topleft
	end

	alias tl topleft
	alias tl= topleft=;

	# Return the x and y coordinates of the top-right corner of the Rect
	def topright; [@x+@w, @y]; end

	# Set the x and y coordinates of the top-right corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def topright=(topright)
		@x, @y = topright[0]-@w, topright[1]
		return topright
	end

	alias tr topright
	alias tr= topright=;

	# Return the x and y coordinates of the bottom-left corner of the Rect
	def bottomleft; [@x, @y+@h]; end

	# Set the x and y coordinates of the bottom-left corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def bottomleft=(bottomleft)
		@x, @y = bottomleft[0], bottomleft[1]-@h
		return bottomleft
	end

	alias bl bottomleft
	alias bl= bottomleft=;

	# Return the x and y coordinates of the bottom-right corner of the Rect
	def bottomright; [@x+@w, @y+@h]; end

	# Set the x and y coordinates of the bottom-right corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def bottomright=(bottomright)
		@x, @y = bottomright[0]-@w, bottomright[1]-@h
		return bottomright
	end

	alias br bottomright
	alias br= bottomright=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midleft; [@x, @y+@h/2]; end	

	# Set the x and y coordinates of the midpoint on the left side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midleft=(midleft)
		@x, @y = midleft[0], midleft[1]-@h/2
		return midleft
	end

	alias ml midleft
	alias ml= midleft=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midtop; [@x+@w/2, @y]; end	

	# Set the x and y coordinates of the midpoint on the top side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midtop=(top)
		@x, @y = midleft[0]-@w/2, midleft[1]
		return midtop
	end

	alias mt midtop
	alias mt= midtop=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midright; [@x+@w, @y+@h/2]; end	

	# Set the x and y coordinates of the midpoint on the right side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midright=(midleft)
		@x, @y = midleft[0]-@w, midleft[1]-@h/2
		return midright
	end

	alias mr midright
	alias mr= midright=;
	
	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midbottom; [@x+@w/2, @y+@h]; end	

	# Set the x and y coordinates of the midpoint on the bottom side of the
	# Rect by translating the Rect (adjusting the x and y offsets).
	def midbottom=(midbottom)
		@x, @y = midbottom[0]-@w/2, midbottom[1]-@h
		return midbottom
	end

	alias mb midbottom
	alias mb= midbottom=;

	#########################
	##### RECT  METHODS #####
	#########################


	# As #clamp!, but the original caller is not changed.
	def clamp(rect)
		self.dup.clamp!(rect)
	end

	# Translate the calling Rect to be entirely inside the given Rect. If the 
	# caller is too large along either axis to fit in the given rect, it is 
	# centered with respect to the given rect, along that axis.
	def clamp!(rect)
		nself = self.normalize
		rect = rect_from_object(rect)
		#If self is inside given, there is no need to move self
		if not rect.contains(nself)
			#If self is too wide:
			if nself.w >= rect.w
				@x = rect.centerx - nself.w/2
			#Else self is not too wide
			else
				#If self is to the left of arg
				if nself.x < rect.x
					@x = rect.x
				#If self is to the right of arg
				elsif nself.right > rect.right
					@x = rect.right - nself.w
				#Otherwise, leave x alone
				end
			end

			#If self is too tall:
			if nself.h >= rect.h
				@y = rect.centery - nself.h/2
			#Else self is not too tall
			else
				#If self is above arg
				if nself.y < rect.y
					@y = rect.y
				#If self below arg
				elsif nself.bottom > rect.bottom
					@y = rect.bottom - nself.h
				#Otherwise, leave y alone
				end
			end
		end # if not rect.contains(self)
		return self
	end

	# As #clip!, but the original caller is not changed.
	def clip(rect)
		self.dup.clip!(rect)
	end
	
	# Crop the calling Rect to be entirely inside the given Rect. If the caller
	# does not intersect the given Rect at all, its width and height are set
	# to zero, but its x and y offsets are not changed.
	# 
	# As a side effect, the Rect is normalized.
	def clip!(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		if self.collide_rect(rect)
			@x = min(nself.right, rect.right) - nself.x
			@h = min(nself.bottom, rect.bottom) - nself.y
			@x = max(nself.x, rect.x)
			@y = max(nself.y, rect.y)
		#if they do not intersect at all:
		else
			@x, @y = nself.topleft
			@w, @h = 0, 0
		end
		return self
	end

	# Iterate through all key/value pairs in the given hash table, and return
	# the first pair whose value is a Rect that collides with the caller.
	# 
	# Because a hash table is unordered, you should not expect any particular
	# Rect to be returned first, if more than one collides with the caller.
	def collide_hash(hash_rects)
		hash_rects.each { |key,value|
			if value.colliderect(self); return [key,value]; end
		}
		return nil
	end

	# Iterate through all key/value pairs in the given hash table, and return
	# an Array of every pair whose value is a Rect that collides with the 
	# caller.
	# 
	# Because a hash table is unordered, you should not expect the returned 
	# pairs to be in any particular order.
	def collide_hash_all(hash_rects)
		collection = []
		hash_rects.each { |key,value|
			if value.colliderect(self); collection += [key,value]; end
		}
		return collection
	end

	# Iterate through all elements in the given Array, and return
	# the *index* of the first element which is a Rect that collides with the 
	# caller.
	def collide_array(array_rects)
		for i in 0..(array_rects.length)
			if array_rects[i].colliderect(self)
				return i
			end
		end
		return nil
	end

	# Iterate through all elements in the given Array, and return
	# an Array containing the *indices* of every element that is a Rect that
	# collides with the caller.
	def collide_array_all(array_rects)
		indexes = []
		for i in 0..(array_rects.length)
			if array_rects[i].colliderect(self)
				indexes += [i]
			end
		end
		return indexes
	end

	# True if the point is inside (including on the border) of the caller.
	# The point can be given as either an Array or separate coordinates.
	def collide_point?(x,y=nil)
		begin
			if not y; x, y = x[0], x[1]; end
		rescue NoMethodError
			raise ArgumentError("You must pass either 2 Numerics or 1 Array.")
		end
		nself = self.normalize
		return ((nself.left..nself.right).include? x and
			(nself.top..nself.bottom).include? y)
	end

	# True if the caller and the given Rect overlap at all.
	def collide_rect?(rect)
		nself = self.normalize
		rect = Rubygame.rect_from_object(rect).normalize
		coll_horz = ((rect.left)..(rect.right)).include?(nself.left) or\
			((nself.left)..(nself.right)).include?(rect.left)
		coll_vert = ((rect.top)..(rect.bottom)).include?(nself.top) or\
			((nself.top)..(nself.bottom)).include?(rect.top)
		return (coll_horz and coll_vert)
	end

	# True if the given Rect is totally within the caller. Borders may touch.
	def contain?(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		return (nself.left <= rect.left and rect.right <= nself.right and
			nself.top <= rect.top and rect.bottom <= nself.bottom)
	end

	# As #inflate!, but the original caller is not changed.
	def inflate(x,y=nil)
		self.dup.inflate!(x,y)
	end

	# Increase the Rect's size is the x and y directions, while keeping the
	# same center point. For best results, expand by an even number.
	# X and y inflation can be given as an Array or as separate values.
	def inflate!(x,y=nil)
		begin
			if not y; x, y = x[0], x[1]; end
		rescue NoMethodError # x has no []
			raise ArgumentError("You must pass either 2 Numerics or 1 Array.")
		end
		@x, @y = (@x - x/2), (@y - y/2)
		#if we just did x/2 or y/2 again, we would inflate it 1 pixel too
		#few if x or y is an odd number, due to rounding.
		@w, @h = (@w + (x-x/2)), (@h + (y-y/2))
		return self
	end

	# As #move!, but the original caller is not changed.
	def move(x,y=nil)
		self.dup.move!(x,y)
	end

	# Translate the Rect by the given amounts in the x and y directions.
	# Positive values are rightward for x and downward for y.
	# X and y movement can be given as an Array or as separate values.
	def move!(x,y=nil)
		begin
			if not y; x, y = x[0], x[1]; end
		rescue NoMethodError # x has no []
			raise ArgumentError("You must pass either 2 Numerics or 1 Array.")
		end
		@x+=x; @y+=y
		return self
	end
		
 	# As #normalize!, but the original caller is not changed.
	def normalize
		self.dup.normalize!()
	end

	# Fix Rects that have negative width or height, without changing the area
	# it represents. Has no effect on Rects with non-negative width and height.
	# Some Rect methods will automatically normalize the Rect.
	def normalize!
		if @w < 0
			@x, @w = @x+@w, -@w
		end
		if @h < 0
			@y, @h = @y+@h, -@h
		end
		return self
	end

	# As #union!, but the original caller is not changed.
	def union(rect)
		self.dup.union!(rect)
	end

	# Expand the caller to also cover the given Rect. The Rect is still a 
	# rectangle,so it may also cover areas that neither of the original Rects
	# did, for example areas between the two Rects.
	def union!(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		@x = min(nself.x, rect.x)
		@y = min(nself.y, rect.y)
		@w = max(nself.w, rect.w)
		@h = max(nself.h, rect.h)
		return self
	end

	# As #union_all!, but the original caller is not changed.
	def union_all(array_rects)
		self.dup.union_all!(array_rects)
	end

	# Expand the caller to cover all of the given Rects. See also #union!
	def union_all!(array_rects)
		nself = self.normalize
		left = nself.left
		top = nself.top
		right = nself.right
		bottom = nself.bottom
		array_rects.each do |r|
			rect = rect_from_object(r).normalize
			left = min(left,rect.left)
			top = min(top,rect.top)
			right = min(right,rect.right)
			bottom = min(bottom,rect.bottom)
		end
		@x, @y = left, top
		@w, @h = right - left, bottom-top
		return self
	end
end # class Rect
end # module Rubygame
