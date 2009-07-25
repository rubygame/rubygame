#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2007  John Croisant
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
	module Color

		# :enddoc:

		# The X11 module contains all the colors in the X11 palette
		# by symbol name, e.g. :alice_blue, :dark_olive_green, etc.
		# 
		# The list of colors is derived from
		# http://en.wikipedia.org/wiki/X11_color_names
		# as accessed on 2007-12-17.
		X11 = Palette.new({
			:alice_blue =>               ColorRGB.new( [0.94117, 0.97254, 1.00000] ),
			:antique_white =>            ColorRGB.new( [0.98039, 0.92156, 0.84313] ),
			:aqua =>                     ColorRGB.new( [0.00000, 1.00000, 1.00000] ),
			:aquamarine =>               ColorRGB.new( [0.49803, 1.00000, 0.83137] ),
			:azure =>                    ColorRGB.new( [0.94117, 1.00000, 1.00000] ),
			:beige =>                    ColorRGB.new( [0.96078, 0.96078, 0.86274] ),
			:bisque =>                   ColorRGB.new( [1.00000, 0.89411, 0.76862] ),
			:black =>                    ColorRGB.new( [0.00000, 0.00000, 0.00000] ),
			:blanched_almond =>          ColorRGB.new( [1.00000, 0.92156, 0.80392] ),
			:blue =>                     ColorRGB.new( [0.00000, 0.00000, 1.00000] ),
			:blue_violet =>              ColorRGB.new( [0.54117, 0.16862, 0.88627] ),
			:brown =>                    ColorRGB.new( [0.64705, 0.16470, 0.16470] ),
			:burly_wood =>               ColorRGB.new( [0.87058, 0.72156, 0.52941] ),
			:cadet_blue =>               ColorRGB.new( [0.37254, 0.61960, 0.62745] ),
			:chartreuse =>               ColorRGB.new( [0.49803, 1.00000, 0.00000] ),
			:chocolate =>                ColorRGB.new( [0.82352, 0.41176, 0.11764] ),
			:coral =>                    ColorRGB.new( [1.00000, 0.49803, 0.31372] ),
			:cornflower_blue =>          ColorRGB.new( [0.39215, 0.58431, 0.92941] ),
			:cornsilk =>                 ColorRGB.new( [1.00000, 0.97254, 0.86274] ),
			:crimson =>                  ColorRGB.new( [0.86274, 0.07843, 0.23529] ),
			:cyan =>                     ColorRGB.new( [0.00000, 1.00000, 1.00000] ),
			:dark_blue =>                ColorRGB.new( [0.00000, 0.00000, 0.54509] ),
			:dark_cyan =>                ColorRGB.new( [0.00000, 0.54509, 0.54509] ),
			:dark_goldenrod =>           ColorRGB.new( [0.72156, 0.52549, 0.04313] ),
			:dark_gray =>                ColorRGB.new( [0.66274, 0.66274, 0.66274] ),
			:dark_green =>               ColorRGB.new( [0.00000, 0.39215, 0.00000] ),
			:dark_khaki =>               ColorRGB.new( [0.74117, 0.71764, 0.41960] ),
			:dark_magenta =>             ColorRGB.new( [0.54509, 0.00000, 0.54509] ),
			:dark_olive_green =>         ColorRGB.new( [0.33333, 0.41960, 0.18431] ),
			:dark_orange =>              ColorRGB.new( [1.00000, 0.54901, 0.00000] ),
			:dark_orchid =>              ColorRGB.new( [0.60000, 0.19607, 0.80000] ),
			:dark_red =>                 ColorRGB.new( [0.54509, 0.00000, 0.00000] ),
			:dark_salmon =>              ColorRGB.new( [0.91372, 0.58823, 0.47843] ),
			:dark_sea_green =>           ColorRGB.new( [0.56078, 0.73725, 0.56078] ),
			:dark_slate_blue =>          ColorRGB.new( [0.28235, 0.23921, 0.54509] ),
			:dark_slate_gray =>          ColorRGB.new( [0.18431, 0.30980, 0.30980] ),
			:dark_turquoise =>           ColorRGB.new( [0.00000, 0.80784, 0.81960] ),
			:dark_violet =>              ColorRGB.new( [0.58039, 0.00000, 0.82745] ),
			:deep_pink =>                ColorRGB.new( [1.00000, 0.07843, 0.57647] ),
			:deep_sky_blue =>            ColorRGB.new( [0.00000, 0.74901, 1.00000] ),
			:dim_gray =>                 ColorRGB.new( [0.41176, 0.41176, 0.41176] ),
			:dodger_blue =>              ColorRGB.new( [0.11764, 0.56470, 1.00000] ),
			:fire_brick =>               ColorRGB.new( [0.69803, 0.13333, 0.13333] ),
			:floral_white =>             ColorRGB.new( [1.00000, 0.98039, 0.94117] ),
			:forest_green =>             ColorRGB.new( [0.13333, 0.54509, 0.13333] ),
			:fuchsia =>                  ColorRGB.new( [1.00000, 0.00000, 1.00000] ),
			:gainsboro =>                ColorRGB.new( [0.86274, 0.86274, 0.86274] ),
			:ghost_white =>              ColorRGB.new( [0.97254, 0.97254, 1.00000] ),
			:gold =>                     ColorRGB.new( [1.00000, 0.84313, 0.00000] ),
			:goldenrod =>                ColorRGB.new( [0.85490, 0.64705, 0.12549] ),
			:gray =>                     ColorRGB.new( [0.50196, 0.50196, 0.50196] ),
			:green =>                    ColorRGB.new( [0.00000, 0.50196, 0.00000] ),
			:green_yellow =>             ColorRGB.new( [0.67843, 1.00000, 0.18431] ),
			:honeydew =>                 ColorRGB.new( [0.94117, 1.00000, 0.94117] ),
			:hot_pink =>                 ColorRGB.new( [1.00000, 0.41176, 0.70588] ),
			:indian_red =>               ColorRGB.new( [0.80392, 0.36078, 0.36078] ),
			:indigo =>                   ColorRGB.new( [0.29411, 0.00000, 0.50980] ),
			:ivory =>                    ColorRGB.new( [1.00000, 1.00000, 0.94117] ),
			:khaki =>                    ColorRGB.new( [0.94117, 0.90196, 0.54901] ),
			:lavender =>                 ColorRGB.new( [0.90196, 0.90196, 0.98039] ),
			:lavender_blush =>           ColorRGB.new( [1.00000, 0.94117, 0.96078] ),
			:lawn_green =>               ColorRGB.new( [0.48627, 0.98823, 0.00000] ),
			:lemon_chiffon =>            ColorRGB.new( [1.00000, 0.98039, 0.80392] ),
			:light_blue =>               ColorRGB.new( [0.67843, 0.84705, 0.90196] ),
			:light_coral =>              ColorRGB.new( [0.94117, 0.50196, 0.50196] ),
			:light_cyan =>               ColorRGB.new( [0.87843, 1.00000, 1.00000] ),
			:light_goldenrod_yellow =>   ColorRGB.new( [0.98039, 0.98039, 0.82352] ),
			:light_green =>              ColorRGB.new( [0.56470, 0.93333, 0.56470] ),
			:light_grey =>               ColorRGB.new( [0.82745, 0.82745, 0.82745] ),
			:light_pink =>               ColorRGB.new( [1.00000, 0.71372, 0.75686] ),
			:light_salmon =>             ColorRGB.new( [1.00000, 0.62745, 0.47843] ),
			:light_sea_green =>          ColorRGB.new( [0.12549, 0.69803, 0.66666] ),
			:light_sky_blue =>           ColorRGB.new( [0.52941, 0.80784, 0.98039] ),
			:light_slate_gray =>         ColorRGB.new( [0.46666, 0.53333, 0.60000] ),
			:light_steel_blue =>         ColorRGB.new( [0.69019, 0.76862, 0.87058] ),
			:light_yellow =>             ColorRGB.new( [1.00000, 1.00000, 0.87843] ),
			:lime =>                     ColorRGB.new( [0.00000, 1.00000, 0.00000] ),
			:lime_green =>               ColorRGB.new( [0.19607, 0.80392, 0.19607] ),
			:linen =>                    ColorRGB.new( [0.98039, 0.94117, 0.90196] ),
			:magenta =>                  ColorRGB.new( [1.00000, 0.00000, 1.00000] ),
			:maroon =>                   ColorRGB.new( [0.50196, 0.00000, 0.00000] ),
			:medium_aquamarine =>        ColorRGB.new( [0.40000, 0.80392, 0.66666] ),
			:medium_blue =>              ColorRGB.new( [0.00000, 0.00000, 0.80392] ),
			:medium_orchid =>            ColorRGB.new( [0.72941, 0.33333, 0.82745] ),
			:medium_purple =>            ColorRGB.new( [0.57647, 0.43921, 0.85882] ),
			:medium_sea_green =>         ColorRGB.new( [0.23529, 0.70196, 0.44313] ),
			:medium_slate_blue =>        ColorRGB.new( [0.48235, 0.40784, 0.93333] ),
			:medium_spring_green =>      ColorRGB.new( [0.00000, 0.98039, 0.60392] ),
			:medium_turquoise =>         ColorRGB.new( [0.28235, 0.81960, 0.80000] ),
			:medium_violet_red =>        ColorRGB.new( [0.78039, 0.08235, 0.52156] ),
			:midnight_blue =>            ColorRGB.new( [0.09803, 0.09803, 0.43921] ),
			:mint_cream =>               ColorRGB.new( [0.96078, 1.00000, 0.98039] ),
			:misty_rose =>               ColorRGB.new( [1.00000, 0.89411, 0.88235] ),
			:moccasin =>                 ColorRGB.new( [1.00000, 0.89411, 0.70980] ),
			:navajo_white =>             ColorRGB.new( [1.00000, 0.87058, 0.67843] ),
			:navy =>                     ColorRGB.new( [0.00000, 0.00000, 0.50196] ),
			:old_lace =>                 ColorRGB.new( [0.99215, 0.96078, 0.90196] ),
			:olive =>                    ColorRGB.new( [0.50196, 0.50196, 0.00000] ),
			:olive_drab =>               ColorRGB.new( [0.41960, 0.55686, 0.13725] ),
			:orange =>                   ColorRGB.new( [1.00000, 0.64705, 0.00000] ),
			:orange_red =>               ColorRGB.new( [1.00000, 0.27058, 0.00000] ),
			:orchid =>                   ColorRGB.new( [0.85490, 0.43921, 0.83921] ),
			:pale_goldenrod =>           ColorRGB.new( [0.93333, 0.90980, 0.66666] ),
			:pale_green =>               ColorRGB.new( [0.59607, 0.98431, 0.59607] ),
			:pale_turquoise =>           ColorRGB.new( [0.68627, 0.93333, 0.93333] ),
			:pale_violet_red =>          ColorRGB.new( [0.85882, 0.43921, 0.57647] ),
			:papaya_whip =>              ColorRGB.new( [1.00000, 0.93725, 0.83529] ),
			:peach_puff =>               ColorRGB.new( [1.00000, 0.85490, 0.72549] ),
			:peru =>                     ColorRGB.new( [0.80392, 0.52156, 0.24705] ),
			:pink =>                     ColorRGB.new( [1.00000, 0.75294, 0.79607] ),
			:plum =>                     ColorRGB.new( [0.86666, 0.62745, 0.86666] ),
			:powder_blue =>              ColorRGB.new( [0.69019, 0.87843, 0.90196] ),
			:purple =>                   ColorRGB.new( [0.50196, 0.00000, 0.50196] ),
			:red =>                      ColorRGB.new( [1.00000, 0.00000, 0.00000] ),
			:rosy_brown =>               ColorRGB.new( [0.73725, 0.56078, 0.56078] ),
			:royal_blue =>               ColorRGB.new( [0.25490, 0.41176, 0.88235] ),
			:saddle_brown =>             ColorRGB.new( [0.54509, 0.27058, 0.07450] ),
			:salmon =>                   ColorRGB.new( [0.98039, 0.50196, 0.44705] ),
			:sandy_brown =>              ColorRGB.new( [0.95686, 0.64313, 0.37647] ),
			:sea_green =>                ColorRGB.new( [0.18039, 0.54509, 0.34117] ),
			:seashell =>                 ColorRGB.new( [1.00000, 0.96078, 0.93333] ),
			:sienna =>                   ColorRGB.new( [0.62745, 0.32156, 0.17647] ),
			:silver =>                   ColorRGB.new( [0.75294, 0.75294, 0.75294] ),
			:sky_blue =>                 ColorRGB.new( [0.52941, 0.80784, 0.92156] ),
			:slate_blue =>               ColorRGB.new( [0.41568, 0.35294, 0.80392] ),
			:slate_gray =>               ColorRGB.new( [0.43921, 0.50196, 0.56470] ),
			:snow =>                     ColorRGB.new( [1.00000, 0.98039, 0.98039] ),
			:spring_green =>             ColorRGB.new( [0.00000, 1.00000, 0.49803] ),
			:steel_blue =>               ColorRGB.new( [0.27450, 0.50980, 0.70588] ),
			:tan =>                      ColorRGB.new( [0.82352, 0.70588, 0.54901] ),
			:teal =>                     ColorRGB.new( [0.00000, 0.50196, 0.50196] ),
			:thistle =>                  ColorRGB.new( [0.84705, 0.74901, 0.84705] ),
			:tomato =>                   ColorRGB.new( [1.00000, 0.38823, 0.27843] ),
			:turquoise =>                ColorRGB.new( [0.25098, 0.87843, 0.81568] ),
			:violet =>                   ColorRGB.new( [0.93333, 0.50980, 0.93333] ),
			:wheat =>                    ColorRGB.new( [0.96078, 0.87058, 0.70196] ),
			:white =>                    ColorRGB.new( [1.00000, 1.00000, 1.00000] ),
			:white_smoke =>              ColorRGB.new( [0.96078, 0.96078, 0.96078] ),
			:yellow =>                   ColorRGB.new( [1.00000, 1.00000, 0.00000] ),
			:yellow_green =>             ColorRGB.new( [0.60392, 0.80392, 0.19607] )
		})
	end
end
