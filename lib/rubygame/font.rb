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
module Font
	class SFont
		@@default_glyphs = [\
			"!",'"',"#","$","%","&","'","(",")","*","+",",","-",".","/","0",
			"1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@",
			"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
			"Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`",
			"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
			"q","r","s","t","u","v","w","x","y","z","{","|","}","~"]

		def SFont.default_glyphs
			@@default_glyphs
		end

		def initialize(filename,glyphs=nil,space_width=nil)
			# load the surface containing all the glyphs
			surface = Rubygame::Image.load(filename)
			@height = surface.height
			colorkey = surface.get_at([0,@height-1])

			# set colorkey if "transparent" color is not actually transparent
			if colorkey[3] != 0
				surface.set_colorkey(colorkey[0..2])
			end

			@glyphs = {}
			@skip = surface.get_at([0,0])[0..2]

			# split the glyphs into separate surfaces
			glyphs = (glyphs or @@default_glyphs)
			start_x = 2
			glyphs.each{ |glyph| start_x = load_glyph(surface,glyph,start_x) }

			if not glyphs.include?(" ")
				if space_width == nil
					space_width = @glyphs['"'].width
				elsif space_width.kind_of? Numeric
					space_width = space_width.to_i
				elsif space_width.kind_of? String
					if glyphs.include? space_width
						space_width = @glyphs[space_width].width
					else
						space_width = @glyphs['"'].width
					end
				else
					raise(ArgumentError,"space_width must be Numeric, String, \
or nil (got %s)"%[space_width.class])
				end
				@glyphs[" "] = Rubygame::Surface.new([space_width,@height])
			end
		end

		attr_reader :height

		def load_glyph(surface,glyph,start_x)
			# find where this glyph starts
			begin
				while(surface.get_at([start_x,0])[0..2] == @skip)
					start_x += 1
				end
			rescue IndexError
				return -1
			end
				end_x = start_x
			# find how wide this glyph is
			begin
				while(surface.get_at([end_x,0])[0..2] != @skip)
					end_x += 1
				end
			rescue IndexError
				return -1
			end

			# make a new surface for the glyph and blit the image onto it
			rect = [start_x,0,end_x-start_x,surface.h]
			@glyphs[glyph] = Rubygame::Surface.new(rect[2..3])
			surface.blit(@glyphs[glyph],[0,0],rect)
			
			return end_x+1
		end
		private :load_glyph

		def blit_glyph(glyph,surface,pos)
			@glyphs[glyph].blit(surface,pos)
		end
		private :blit_glyph

		def string_width(string)
			w = 0
			string.each_byte { |glyph| w += @glyphs["%c"%[glyph]].width }
			return w
		end

		def render(string)
			size = [self.string_width(string),self.height]
			render = Rubygame::Surface.new(size)
			x = 0
			string.each_byte { |glyph| 
				blit_glyph("%c"%[glyph],render,[x,0])
				x += @glyphs["%c"%[glyph]].width
			}
			return render
		end
	end # class SFont
end # module Font
end # module Rubygame
