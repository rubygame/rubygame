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

module Rubygame
	module Sprite
		module Sprite
			attr_reader :groups
			attr_accessor :image, :rect
	
			def initialize
				@groups = []
			end

			def add(*groups)
				groups.each { |group|
					unless @groups.include? group
						@groups.push(group)
						group.push(self)
					end
				}
			end

			def alive?
				return @groups.length > 0
			end

			attr_writer :col_rect
			def col_rect
				if defined? @col_rect 
					return (@col_rect or rect)
				else
					return rect
				end
			end

			def collide(other)
				if other.class.is_a? Group
					return collide_group(other)
				elsif other.class.included_modules.include? Sprite and\
					collide_sprite?(other)
					return [other]
				end
			end

			def collide_group(group)
				sprites = []
				group.each { |sprite|
					if self.rect.collide_rect?(sprite.rect)
						if not sprites.include? sprite
							sprites.push(sprite)
						end
					end
				}
				return sprites
			end

			def collide_sprite?(sprite)
				return self.rect.collide_rect?(sprite.rect)
			end

			def draw(destination)
				self.image.blit(destination, self.rect)
				return self.rect
			end

			def kill
				@groups.each { |group| group.delete(self) }
				@groups = []
			end

			def remove(*groups)
				groups.each { |group|
					if @groups.include? group
						@groups.delete(group)
						group.delete(self)
					end
				}
			end

			def update( *args )
			end


		end # module Sprite

		class Group < Array
			def <<(sprite)
				unless self.include? sprite
					super(sprite)
					sprite.add(self)
				end
				return self
			end

			def call(symbol,*args)
				self.each { |sprite|
					sprite.send(symbol,*args)
				}
			end

			def clear
				self.each { |sprite| sprite.remove(self) }
			end

			def collide_sprite(sprite)
				sprite.collide_group(self)
			end

			def collide_group(group, killa=false, killb=false)
				sprites = {}
				self.each { |sprite|
					sprites[sprite] = sprite.collide_group(group)
				}
				if killa
					sprites.each_key { |sprite| sprite.kill }
				end
				if killb
					sprites.each_value { |sprite| sprite.kill }
				end
			end

			def delete(*sprites)
				sprites.each { |sprite|
					if self.include? sprite
						super(sprite)
						sprite.remove(self)
					end
				}
				return self
			end

			def draw(dest)
				self.each { |sprite| sprite.draw(dest) }
			end

			def push(*sprites)
				sprites.each { |sprite|
					self << sprite
				}
				return self
			end

			def update(*args)
				self.each { |sprite|
					sprite.update(*args)
				}
			end

		end #class Group

		module UpdateGroup
			attr_accessor :dirty_rects
			def UpdateGroup.extend_object(obj)
				super
				obj.dirty_rects = []
			end

			def initialize
				super
				@dirty_rects = []
			end

			def draw(dest)
				self.each { |sprite| 
					@dirty_rects.push( sprite.draw(dest) ) 
				}
				rects = @dirty_rects.dup
				@dirty_rects = []
				return rects
			end

			def undraw(dest,background)
				self.each { |sprite|
					background.blit(dest,sprite.rect,sprite.rect)
					@dirty_rects.push(sprite.rect)
				}
			end
		end # module UpdateGroup

		# can hold at most N sprites, removes old ones to make room
		module LimitGroup
			attr_accessor :limit
			def LimitGroup.extend_object(obj)
				super
				obj.limit = 1
			end

			def initialize(limit=1)
				@limit = limit
			end

			def push(*sprites )
				sprites.each { |sprite|
					if not include? sprite
						super(sprite)
						if length > @limit
							self.slice!(0)
						end
					else # move sprite to the back of the queue
						self.delete(sprite)
						super(sprite)
					end
				}
			end
		end # module LimitGroup

	end #module Sprite
end # module Rubygame
