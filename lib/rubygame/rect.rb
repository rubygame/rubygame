#
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
#

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

	def rect_from_object(object,recurse=0)
		case(rect.class)
			when Rect
				return self.dup
			when Array 
				if rect.length >= 4
					return Rect.new(object)
				else
					raise ArgumentError(
						"Array does not have enough indexes to be made"+
						"into a Rect (%d for 4)."%rect.length )
				end
			else
				begin 
					if recurse < 1
						return Rubygame.rect_from_object(rect.rect,recurse+1)
					else
						raise TypeError("Object must be a Rect or Array [x,y,w,h], or have an attribute called 'rect'. Got %s instance."%rect.class)
					end
				rescue NoMethodError # if no rect.rect
					raise TypeError("Object must be a Rect or Array [x,y,w,h], or have an attribute called 'rect'. Got %s instance."%rect.class)
				end
		end # case
	end # def

class Rect
	# All rect values must be integers
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

	def to_s; "Rect(%s,%s,%s,%s)"%[@x,@y,@w,@h]; end
	alias inspect to_s

	def to_a; [@x,@y,@w,@h]; end
	#alias to_ary to_a  # causes problems with puts

	def [](i); self.to_a[i]; end
	def []=(i,value)
		case(i)
			when 0; @x = value
			when 1; @y = value
			when 2; @w = value
			when 3; @h = value
			return i
		end
	end

	def ==(other)
		other.to_a == self.to_a
	end


	#########################
	#### RECT ATTRIBUTES ####
	#########################

	attr_accessor :x, :y, :w, :h

	#Width -- expanded text of "w"
	alias width w
	alias width= w=

	#Height -- expanded text of "h"
	alias height h
	alias height= h=

	#Size
	def size; [@w, @h]; end
	def size=(size); @w, @h = size; return size; end

	#Left
	alias left x
	alias left= x=
	alias l left
	alias l= left=

	#Top
	alias top y
	alias top= y=
	alias t top
	alias t= top=

	#Right
	def right; @x+@w; end
	def right=(r); @x = r - @w; return r; end
	alias r right
	alias r= right=

	#Bottom
	def bottom; @y+@h; end
	def bottom=(b); @y = b - @h; return b; end
	alias b bottom
	alias b= bottom=

	#Center
	def center; [@x+@w/2, @y+@h/2]; end
	def center=(center)
		@x, @y = center[0]-@w/2, center[1]-@h/2
		return center
	end
	alias c center
	alias c= center=

	#Centerx
	def centerx; @x+@w/2; end
	def centerx=(x); @x = x-@w/2; return x; end
	alias cx centerx
	alias cx= centerx=

	#Centery
	def centery; @y+@h/2; end
	def centery=(y); @y = y-@h/2; return y; end
	alias cy centery
	alias cy= centery=

	#TopLeft
	def topleft; [@x,@y]; end
	def topleft=(topleft)
		@x, @y = *topleft
		return topleft
	end
	alias tl topleft
	alias tl= topleft=

	#TopRight
	def topright; [@x+@w, @y]; end
	def topright=(topright)
		@x, @y = topright[0]-@w, topright[1]
		return topright
	end
	alias tr topright
	alias tr= topright=

	#BottomLeft
	def bottomleft; [@x, @y+@h]; end
	def bottomleft=(bottomleft)
		@x, @y = bottomleft[0], bottomleft[1]-@h
		return bottomleft
	end
	alias bl bottomleft
	alias bl= bottomleft=

	#BottomRight
	def bottomright; [@x+@w, @y+@h]; end
	def bottomright=(bottomright)
		@x, @y = bottomright[0]-@w, bottomright[1]-@h
		return bottomright
	end
	alias br bottomright
	alias br= bottomright=

	#MidLeft
	def midleft; [@x, @y+@h/2]; end	
	def midleft=(midleft)
		@x, @y = midleft[0], midleft[1]-@h/2
		return midleft
	end
	alias ml midleft
	alias ml= midleft=

	#MidTop
	def midtop; [@x+@w/2, @y]; end	
	def midtop=(top)
		@x, @y = midleft[0]-@w/2, midleft[1]
		return midtop
	end
	alias mt midtop
	alias mt= midtop=

	#MidRight
	def midright; [@x+@w, @y+@h/2]; end	
	def midright=(midleft)
		@x, @y = midleft[0]-@w, midleft[1]-@h/2
		return midright
	end
	alias mr midright
	alias mr= midright=
	
	#MidBottom
	def midbottom; [@x+@w/2, @y+@h]; end	
	def midbottom=(midbottom)
		@x, @y = midbottom[0]-@w/2, midbottom[1]-@h
		return midbottom
	end
	alias mb midbottom
	alias mb= midbottom=

	#########################
	##### RECT  METHODS #####
	#########################

	def clamp(rect)
		self.dup.clamp!(rect)
	end

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

	def clip(rect)
		self.dup.clip!(rect)
	end
	
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

	def collide_hash(hash_rects)
		hash_rects.each { |key,value|
			if value.colliderect(self); return [key,value]; end
		}
		return nil
	end

	def collide_hash_all(hash_rects)
		collection = []
		hash_rects.each { |key,value|
			if value.colliderect(self); collection += [key,value]; end
		}
		return collection
	end

	def collide_array(array_rects)
		for i in 0..(array_rects.length)
			if array_rects[i].colliderect(self)
				return i
			end
		end
		return nil
	end

	def collide_array_all(array_rects)
		indexes = []
		for i in 0..(array_rects.length)
			if array_rects[i].colliderect(self)
				indexes += [i]
			end
		end
		return indexes
	end

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

	def collide_rect?(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		coll_horz = ((rect.left)..(rect.right)).include?(nself.left) or\
			((nself.left)..(nself.right)).include?(rect.left)
		coll_vert = ((rect.top)..(rect.bottom)).include?(nself.top) or\
			((nself.top)..(nself.bottom)).include?(rect.top)
		return (coll_horz and coll_vert)
	end

	def contain?(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		return (nself.left <= rect.left and rect.right <= nself.right and
			nself.top <= rect.top and rect.bottom <= nself.bottom)
	end

	def inflate(x,y=nil)
		self.dup.inflate(x,y)
	end

	def inflate!(x,y=nil)
		begin
			if not y; x, y = x[0], x[1]; end
		rescue NoMethodError # x has no []
			raise ArgumentError("You must pass either 2 Numerics or 1 Array.")
		end
		@x, @y = (@x - x/2), (@y - y/2)
		#if we just did x/2 or y/2 again, we would inflate it 1 pixel too
		#few if x or y is an odd number, due to rounding.
		@w, @h = (@w + (x-x/2)), (@w + (y-y/2))
		return self
	end
		
	def move(x,y=nil)
		self.dup.move!(x,y)
	end

	def move!(x,y=nil)
		begin
			if not y; x, y = x[0], x[1]; end
		rescue NoMethodError # x has no []
			raise ArgumentError("You must pass either 2 Numerics or 1 Array.")
		end
		@x+=x; @y+=y
		return self
	end
		
	def normalize
		self.dup.normalize()
	end

	def normalize!
		if @w < 0
			@x, @w = @x+@w, -@w
		end
		if @h < 0
			@y, @h = @y+@h, -@h
		end
		return self
	end

	def union(rect)
		self.dup.union!(rect)
	end

	def union!(rect)
		nself = self.normalize
		rect = rect_from_object(rect).normalize
		@x = min(nself.x, rect.x)
		@y = min(nself.y, rect.y)
		@w = max(nself.w, rect.w)
		@h = max(nself.h, rect.h)
		return self
	end

	def union_all(array_rects)
		self.dup.union_all!(array_rects)
	end

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
