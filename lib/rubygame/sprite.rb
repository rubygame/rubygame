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
				if not defined? @groups
					@groups = Array.new
				end
			end

			def add(*groups)
				groups.flatten.each { |group|
					if not @groups.include? group
						@groups.push(group)
						group.add( self )
					end
				}
			end

			def remove(*groups)
				groups.flatten.each { |group|
					if @groups.include? group
						@groups.remove(group)
						group.remove(self)
					end
				}
			end

			def alive?
				return @groups.length > 0
			end

			def kill
				@groups.each { |group| group.remove(self) }
				@groups = []
			end

			def draw(destination)
				@image.blit(destination, @rect)
				return @rect
			end

			def update( *args )
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

			def collide(other)
				if other.class.included_modules.include? SpriteGroup
					return self.collide_group(other)
				elsif other.class.included_modules.include? Sprite
					return(self.collide_sprite?(other) and [other])
				end
			end

		end # module Sprite

		module SpriteGroup
			attr_reader :sprites

			def initialize
				if not defined? @sprites
					@sprites = Array.new
				end
			end
			
			def add(*sprites)
				sprites.flatten.each { |sprite|
					if not @sprites.include? sprite
						@sprites.push(sprite)
						sprite.add(self)
					end
				}
			end

			def remove(*sprites)
				sprites.flatten.each { |sprite|
					if @sprite.include? sprite
						@sprites.remove(sprite)
						sprite.remove(self)
					end
				}
			end

			def draw(dest)
				@sprites.each { |sprite| sprite.draw(dest) }
			end

			def clear
				@sprites.each { |sprite| sprite.remove(self) }
			end

			def empty?
				return @sprites.length == 0
			end

			def each
				if not block_given?
					raise(LocalJumpError,"no block given")
				end
				@sprites.each { |sprite|
					yield sprite
				}
			end
			
			def update(*args)
				@sprites.each { |sprite|
					sprite.update(*args)
				}
			end

			def call(symbol,*args)
				@sprites.each { |sprite|
					sprite.send(symbol,*args)
				}
			end

			def collide_sprite(sprite)
				sprite.collide_group(self)
			end

			def collide_group(group, killa=false, killb=false)
				sprites = {}
				@sprites.each { |sprite|
					sprites[sprite] = sprite.collide_group(group)
				}
				if killa
					sprites.each_key { |sprite| sprite.kill }
				end
				if killb
					sprites.each_value { |sprite| sprite.kill }
				end
			end
		end #module SpriteGroup

		class SpriteGroupClass
			include SpriteGroup
		end

		module UpdateGroup
			attr_accessor :dirty_rects

			def initialize
				super
				@dirty_rects = Array.new
			end

			def draw(dest)
				@sprites.each { |sprite| 
					@dirty_rects.push( sprite.draw(dest) ) 
				}
				rects = @dirty_rects.dup
				@dirty_rects = []
				return rects
			end

			def undraw(dest,background)
				@sprites.each { |sprite|
					background.blit(dest,sprite.rect,sprite.rect)
					@dirty_rects.push(sprite.rect)
				}
			end
		end # module UpdateGroup

		class UpdateGroupClass
			include SpriteGroup
			include UpdateGroup
		end

		# can hold at most N sprites, removes old ones to make room
		module LimitGroup
			def initialize(limit=1)
				@limit = limit
			end

			def add( *sprites )
				sprites.flatten.each { |sprite|
					if not @sprites.include? sprite
						@sprites.push(sprite)
						sprite.add(self)
						if @sprites.length > @limit
							@sprites.slice!(0)
						end
					end
				}
			end
		end # module LimitGroup

	end #module Sprite
end # module Rubygame
