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

module Rubygame

	# The Sprites module provides classes and mix-in modules for managing
	# sprites. A Sprite is, fundamentally, a Surface with an associated
	# Rect which defines the position of that Surface on the Screen.
	# Additionally, sprites can have some behavior associated with them
	# via the Sprite#update method, including movement and collision detection;
	# because of this, sprites can be the foundation of most on-screen objects,
	# such as characters, items, missiles, and even user-interface elements.
	# 
	# There are several classes/modules under the Sprites module:
	# Sprite::      mix-in module to turn an individual object or class into
	#               a Sprite.
	# Group::       class for containing and manipulating many Sprite objects.
	# UpdateGroup:: mix-in module for Group to allow undrawing/redrawing of
	#               member Sprite objects.
	# LimitGroup::  mix-in module for Group to limit the number of Sprite objects
	#               the Group can hold at once.
	# 
	# More mix-in modules to extend the functionality of Group or Sprite are
	# planned for the future. Do not hesitate to change either (or both) Group
	# or Sprite within your application to fit your needs! That's what they are
	# here for!
	# 
	module Sprites

		# The Sprite mix-in module (not to be confused with its parent module,
		# Sprites) can be used to extend a class or object to behave as a
		# sprite. Specifically, a sprite can:
		# - #draw (blit) itself onto a Surface in its proper position
		# - detect bounding-box collision with Groups (#collide_group) and/or other
		#   sprites (#collide_sprite).
		# - #update its own state based on arbitrary rules.
		# 
		# A Sprite is, fundamentally, a Surface with an associated
		# Rect which defines the position of that Surface on the Screen.
		# Additionally, sprites can have some behavior associated with them
		# via the #update method, including movement and collision detection;
		# because of this, sprites can be the foundation of most on-screen objects,
		# such as characters, items, missiles, and even user-interface elements.
		# 
		# In order to work properly as a Sprite, the extended object or class must
		# have two methods defined (by default, these are defined as accessors to
		# attributes of the same names):
		# image:: return a Surface with the sprite's image.
		# rect::  returns a Rect with the position and dimensions of the sprite.
		# 
		# Normally, the value returned by rect is used to draw the sprite
		# onto a Surface as well as to detect collision between sprites. However,
		# if @col_rect will be used for collision detection instead, if it is
		# defined. See also #col_rect.
		#
		# Additionally, if you are extending an already-existing instance (rather
		# than a class), that instance must have an attribute @groups, which is
		# an Array containing all Groups to which the sprite belongs.
		# 
		# 
		module Sprite
			attr_reader :groups
			attr_accessor :image, :rect, :depth
	
			# Initialize the Sprite, defining @groups and @depth.
			def initialize
				@groups = []
				@depth = 0
			end

			# Add the Sprite to each given Group.
			def add(*groups)
				groups.each { |group|
					unless @groups.include? group
						@groups.push(group)
						group.push(self)
					end
				}
			end

			# call-seq: alive?  ->  true or false
			# 
			# True if the Sprite belongs to at least one Group.
			def alive?
				return @groups.length > 0
			end

			# Set an alternative Rect to use for collision detection. If undefined or
			# set to nil, the Sprite's #rect is used instead.
			attr_writer :col_rect

			# call-seq: col_rect  ->  Rect
			# 
			# Returns @col_rect if it is defined, otherwise calls #rect.
			# This method is used by #collide, #collide_group, and #collide_sprite
			# to get the bounding box for collision detection.
			def col_rect
				if defined? @col_rect 
					return (@col_rect or rect)
				else
					return rect
				end
			end

			# call-seq: collide(other)  ->  Array
			# 
			# Check collision between the caller and a Group or another Sprite. See
			# also #collide_group and #collide_sprite. This method uses the value
			# of #col_rect as the bounding box when detecting collision.
			# 
			# If +other+ is a Group, returns an Array of every Sprite in that
			# Group that collides with the caller. If +other+ is a Sprite, returns
			# an Array containing +other+ if it collides with the caller. Otherwise,
			# returns an empty Array.
			def collide(other)
				if other.class.is_a? Group
					return collide_group(other)
				elsif collide_sprite?(other)
					return [other]
				else
					return []
				end
			end

			# call-seq: collide_group(group)  ->  Array
			# 
			# Check collision between the caller and all members of a Group. This
			# method uses the value of #col_rect as the bounding box when detecting
			# collision.
			# 
			# Returns an Array of every Sprite in +group+ that collides with the 
			# caller. If none collide, returns an empty Array.
			def collide_group(group)
				sprites = []
				group.each { |sprite|
					if self.collide_sprite?(sprite) and (not sprites.include?(sprite))
						sprites.push(sprite)
					end
				}
				return sprites
			end

			# call-seq: collide_sprite?(sprite)  ->  true or false or nil
			# 
			# Check collision between the caller and another Sprite. This method uses
			# the value of #col_rect as the bounding box when detecting collision.
			# Returns true if +sprite+ collides with the caller, false if they do 
			# not, or nil if +sprite+ does not respond to either :col_rect or :rect
			# (meaning it was not possible to detect collision).
			def collide_sprite?(sprite)
				if sprite.respond_to?(:col_rect)
					return self.col_rect.collide_rect?(sprite.col_rect)
				elsif sprite.respond_to?(:rect)
					return self.col_rect.collide_rect?(sprite.rect)
				else
					return nil
				end
			end

			# call-seq: draw(surface)  ->  Rect
			# 
			# Blit the Surface returned by #image onto +surface+ at the position
			# given by the Rect returned by #rect. Returns a Rect representing
			# the area of +surface+ which was affected by the draw.
			def draw(destination)
				self.image.blit(destination, self.rect)
			end

			# Remove the caller from every Group that it belongs to.
			def kill
				@groups.each { |group| group.delete(self) }
				@groups = []
			end

			# Remove the caller from each given Group.
			def remove(*groups)
				groups.each { |group|
					if @groups.include? group
						@groups.delete(group)
						group.delete(self)
					end
				}
			end


			# call-seq: undraw(surface, background)  ->  Rect
			# 
			# 'Erase' the sprite from +surface+ by drawing over it with part of
			# +background+. For best results, +background+ should be the same size
			# as +surface+.
			# 
			# Returns a Rect representing the area of +surface+ which was affected.
			# 
			def undraw(dest, background)
				background.blit(dest, @rect, @rect)
			end			
			
			# This method is meant to be overwritten by Sprite-based classes to
			# define meaningful behavior. It can take any number of arguments you
			# want, be called however often you want, and do whatever you want.
			# It may return something, but Group#update will not (by default) use,
			# or even collect, return values from this method.
			# 
			# An example definition might take the amount of time that has passed
			# since the last update; the Sprite could then update its position
			# accordingly. Game logic, collision detection, and animation would also
			# fit in here, if appropriate to your class.
			def update( *args )
				super
			end

		end # module Sprite

		# The Group class is a special container, based on Array, with supplemental
		# methods for handling multiple Sprite objects. Group can draw, update,
		# and check collision for all its member sprites with one call.
		# 
		# All members of a Group must be unique (duplicates will be refused), and
		# should be a Sprite (or functionally equivalent).
		class Group < Array

			# Add +sprite+ to the Group. +sprite+ is notified so that it can
			# add this Group to its list of parent Groups. See also #push.
			def <<(sprite)
				unless self.include? sprite
					super(sprite)
					sprite.add(self)
				end
				return self
			end

			# Call the method represented by +symbol+ for every member sprite,
			# giving +args+ as the arguments to the method. This method uses
			# Object#send, which does not hesitate to call private methods, so
			# use this wisely! See also #draw and #update.
			def call(symbol,*args)
				self.each { |sprite|
					sprite.send(symbol,*args)
				}
			end

			# Remove every member sprite from the Group. Each sprite is notified
			# so that it can remove this Group from its list of parent Groups.
			# See also #delete.
			def clear
				self.dup.each { |sprite| sprite.remove(self) }
			end

			# call-seq: collide_sprite(sprite)  ->  Array
			# 
			# Check collision between each member of the Group and +sprite+. Returns
			# an Array of all member sprites that collided with +sprite+. If none
			# collided, returns an empty Array.
			def collide_sprite(sprite)
				sprite.collide_group(self)
			end

			# call-seq:
			#    collide_group(group, &block)  ->  Hash
			#    collide_group(group, killa=false, killb=false) -> Hash # deprecated
			# 
			# Check collision between each member of the calling Group and each 
			# member of +group+. Returns a Hash table with each member of the calling
			# Group as a key, and as a value an Array of all members of +group+ that
			# it collided with.
			# 
			# If a block is given, that block is executed for every pair of colliding
			# sprites. For example, if a1 collides with b1 and b2, the block will
			# be called twice: once with [ a1, b1 ] and once with [ a1, b2 ].
			# 
			# Example: 
			# 
			#     # 'kills' both sprites when they collide
			# 
			#     groupA,collide_group(groupB) do |a, b|
			#       a.kill
			#       b.kill
			#     end
			# 
			# *NOTE*: +killa+ and +killb+ are deprecated and will be removed in the future.
			# It is highly recommended that you use the block argument instead.
			# 
			# *IMPORTANT*: +killa+ and +killb+ will be ignored if a block is given!
			# 
			# If +killa+ is true and a sprite in group A collides with a sprite in group B,
			# the sprite in group A will have its #kill method called; the same goes for
			# +killb+ and group B.
			# 
			def collide_group(group, killa=false, killb=false, &block)
				sprites = {}
				self.each { |sprite|
					col = sprite.collide_group(group)
					sprites[sprite] = col if col.length > 0
				}
				
				if block_given?
					sprites.each_pair do |a, bs|
						bs.each { |b| yield(a, b) }
					end
				else
					# killa and killb only work if no block is given
					if killa
						sprites.each_key { |sprite| sprite.kill }
					end
					if killb
						sprites.each_value do |array|
							array.each { |sprite| sprite.kill }
						end
					end
				end
				
				return sprites
			end

			# Remove each sprite in +sprites+ from the Group. Each sprite is notified
			# so that it can remove this Group from its list of parent Groups.
			# Note that this will not work correctly if fed a list of its
			# own sprites (use Array.dup if you want correct behavior)
			def delete(*sprites)
				sprites.each { |sprite|
					if self.include? sprite
						super(sprite)
						sprite.remove(self)
					end
				}
				return self
			end

			# Draw every sprite on Surface +dest+. Calls Sprite#draw for every member
			# sprite, passing +dest+ as the argument. See also #call and #update.
			def draw(dest)
				self.each { |sprite| sprite.draw(dest) }
			end

			# Add each sprite in +sprites+ to the Group. Each sprite is notified so
			# that it can add this Group to its list of parent Groups. See also #<<.
			def push(*sprites)
				sprites.each { |sprite|
					self << sprite
				}
				return self
			end

			# Update every member sprite. Calls Sprite#update for every member
			# sprite, passing on all arguments. See also #call and #draw.
			def update(*args)
				self.each { |sprite|
					sprite.update(*args)
				}
			end

		end #class Group

		# UpdateGroup is a mix-in module that extends Group to allow it to "erase"
		# (i.e. draw over with a background Surface) and re-draw each sprite in its
		# new position. This eliminates the "trail" of images that sprites would
		# otherwise leave as they move around.
		# 
		# UpdateGroup adds a new attribute, @dirty_rects, which is an Array storing
		# all Rects which need to be updated, including the old positions of the
		# sprites. This attribute is returned when UpdateGroup#draw is called,
		# so that it can be used to update the parts of the Screen that have
		# changed.
		# 
		# The general order of calls each frame should be:
		# 1. #undraw; clear the old positions of the sprites.
		# 2. #update; update the sprites to their new positions.
		# 3. #draw; draw the sprites in their new positions.
		# 
		# This module can extend either a class or an already-existing Group
		# instance (either empty or with members) without any special preparation.
		module UpdateGroup
			attr_accessor :dirty_rects

			# Defines @dirty_rects when an existing object is extended.
			def UpdateGroup.extend_object(obj)
				super
				obj.dirty_rects = []
			end

			# Initialize the Group, calling +super+ and defining @dirty_rects.
			def initialize
				super
				@dirty_rects = []
			end

			# call-seq: draw(dest)  ->  Array
			# 
			# Draw every sprite on Surface +dest+. See Group#draw.
			# Returns an Array of Rects representing the portions of +dest+ which
			# were affected by the last #undraw and this #draw.
			def draw(dest)
				self.each { |sprite| 
					@dirty_rects.push( sprite.draw(dest) ) 
				}
				rects = @dirty_rects
				@dirty_rects = []
				return rects
			end

			# Draw over part of +dest+ with image data from the corresponding part
			# of +background+. For best results, +background+ should be at least as
			# big as +dest+ (or, rather, the part of +dest+ that will ever be drawn
			# over).
			def undraw(dest,background)
				self.each { |sprite|
					@dirty_rects.push( sprite.undraw(dest, background) )
				}
			end
		end # module UpdateGroup


		# LimitGroup is a mix-in module that extends Group to limit the number
		# of sprites it can contain. If the limit has been reached, each new sprite
		# will "push out" the oldest sprite, on a First-In-First-Out basis.
		# 
		# The limit can be set either when the LimitGroup is created, or
		# at any time during execution. However, if you reduce the limit,
		# excess sprites will not be removed until the next time a sprite is
		# added. (You can work around this by pushing the last sprite in the
		# group again; the duplicate will be removed.)
		# 
		# Please note that, because Group#push is defined in terms of Group#<<,
		# both LimitGroup#<< and LimitGroup#push work properly, even though only
		# LimitGroup#<< is defined.
		module LimitGroup
			attr_accessor :limit

			# Defines and sets @limit = 1 when an existing object is extended.
			def LimitGroup.extend_object(obj)
				super
				obj.limit = 1
			end

			# Initialize the LimitGroup and define @limit (as 1, by default).
			def initialize(limit=1)
				@limit = limit
			end

			# Add +sprite+ to the LimitGroup, removing the oldest member if
			# necessary to keep under the limit. If +sprite+ is already in
			# the LimitGroup, it will be moved to the top of the queue.
			def <<(sprite)
				if not include? sprite
					super(sprite)
					while length > @limit
						self.slice!(0)
					end
				else # move sprite to the back of the queue
					self.delete(sprite)
					super(sprite)
				end
			end
		end # module LimitGroup

		# DepthSortGroup is a mix-in module that extends Group to sort its
		# sprites by their @depth attribute, so that sprites with low depths
		# will appear on top of sprites with higher depths. A sprite's depth
		# can be any Numeric, or nil (which will be counted as 0).
		# 
		# If two sprites have exactly the same depth, there is no guarantee about
		# which one will be drawn on top of the other. (But, whichever one is on
		# top will stay on top, at least until the group is re-sorted.)
		# 
		# If a sprite's depth changes after it has been added to the group, you
		# must use the #sort_sprites method for the change to have any effect.
		# 
		module DepthSortGroup
			# Add a single sprite to the group. For efficiency reasons, this
			# method doesn't re-sort sprites afterwards. You should use #sort_sprites
			# after you're done adding sprites. Or, better yet, just use #push.
			def <<(sprite)
				super
			end
			
			# Add multiple sprites to the group, then re-sort all sprites.
			def push(*sprites)
				sprites.each { |sprite|
					self << sprite
				}
				sort_sprites()
				return self
			end
			
			# Sort sprites by depth, in descending order, so that sprites with low depths
			# will be drawn on top of sprites with high depths.
			# 
			# If a sprite has a depth of nil, it is sorted as if its depth were 0 (zero).
			def sort_sprites
				self.sort! { |a,b| (b.depth or 0) <=> (a.depth or 0) }
			end
		end
		
	end #module Sprite
end # module Rubygame
