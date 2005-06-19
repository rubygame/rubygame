#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "test/unit"
require "rubygame"
Rect = Rubygame::Rect

class TC_Rect < Test::Unit::TestCase
	# Test init'n from 1 Array with 4 entries
	def test_new1_arr
		rect = Rect.new([3,5,20,40])
		assert_equal([3,5,20,40],rect)
	end

	# Test init'n from 1 Rect
	def test_new1_rect
		base = Rect.new([3,5,20,40])
		rect = Rect.new(base)
		assert_equal([3,5,20,40],rect)
	end

	# Test init'n from 2 Arrays with 2 entries each
	def test_new2
		rect = Rect.new([3,5],[20,40])
		assert_equal([3,5,20,40],rect)
	end

	# Test init'n from 4 Numerics
	def test_new4
		rect = Rect.new(3,5,20,40)
		assert_equal([3,5,20,40],rect)
	end

	# Test that output from #to_s is proper with a Rect of Integers
	def test_to_s_int
		rect = Rect.new(3,5,20,40)
		assert_equal("#<Rect [3,5,20,40]>",rect.to_s)
	end

	# Test that output from #to_s is proper with a Rect of Floats
	def test_to_s_float
		rect = Rect.new(3.1,5.2,20.3,40.5)
		assert_equal("#<Rect [3.1,5.2,20.3,40.5]>",rect.to_s)
	end

	def test_x
		rect = Rect.new(3,5,20,40)
		assert_equal(3,rect.x)
	end

	def test_set_x
		rect = Rect.new(3,5,20,40)
		rect.x=9
		assert_equal([9,5,20,40],rect)
	end

	def test_index_0
		rect = Rect.new(3,5,20,40)
		assert_equal(3,rect[0])
	end

	def test_set_index_0
		rect = Rect.new(3,5,20,40)
		rect[0]=9
		assert_equal([9,5,20,40],rect)
	end

	def test_y
		rect = Rect.new(3,5,20,40)
		assert_equal(5,rect.y)
	end

	def test_set_y
		rect = Rect.new(3,5,20,40)
		rect.y=23
		assert_equal([3,23,20,40],rect)
	end

	def test_index_1
		rect = Rect.new(3,5,20,40)
		assert_equal(5,rect[1])
	end

	def test_set_index_1
		rect = Rect.new(3,5,20,40)
		rect[1]=9
		assert_equal([3,9,20,40],rect)
	end

	def test_w
		rect = Rect.new(3,5,20,40)
		assert_equal(20,rect.w)
	end

	def test_set_w
		rect = Rect.new(3,5,20,40)
		rect.w=9
		assert_equal([3,5,9,40],rect)
	end

	def test_width
		rect = Rect.new(3,5,20,40)
		assert_equal(20,rect.width)
	end

	def test_set_width
		rect = Rect.new(3,5,20,40)
		rect.width=9
		assert_equal([3,5,9,40],rect)
	end

	def test_index_2
		rect = Rect.new(3,5,20,40)
		assert_equal(20,rect[2])
	end

	def test_set_index_2
		rect = Rect.new(3,5,20,40)
		rect[2]=9
		assert_equal([3,5,9,40],rect)
	end

	def test_h
		rect = Rect.new(3,5,20,40)
		assert_equal(40,rect.h)
	end

	def test_set_h
		rect = Rect.new(3,5,20,40)
		rect.h=11
		assert_equal([3,5,20,11],rect)
	end

	def test_height
		rect = Rect.new(3,5,20,40)
		assert_equal(40,rect.height)
	end

	def test_set_height
		rect = Rect.new(3,5,20,40)
		rect.height=9
		assert_equal([3,5,20,9],rect)
	end

	def test_size
		rect = Rect.new(3,5,20,40)
		assert_equal([20,40],rect.size)
	end

	def test_set_size
		rect = Rect.new(3,5,20,40)
		rect.size = [9,5]
		assert_equal([3,5,9,5],rect)
	end

	def test_left
		rect = Rect.new(3,5,20,40)
		assert_equal(3,rect.left)
	end

	def test_set_left
		rect = Rect.new(3,5,20,40)
		rect.left=9
		assert_equal([9,5,20,40],rect)
	end

	def test_top
		rect = Rect.new(3,5,20,40)
		assert_equal(5,rect.top)
	end

	def test_set_top
		rect = Rect.new(3,5,20,40)
		rect.top=9
		assert_equal([3,9,20,40],rect)
	end

	def test_right
		rect = Rect.new(3,5,20,40)
		assert_equal(23,rect.right)
	end

	def test_set_right
		rect = Rect.new(3,5,20,40)
		rect.right = 42
		assert_equal([22,5,20,40],rect)
	end

	def test_bottom
		rect = Rect.new(3,5,20,40)
		assert_equal(45,rect.bottom)
	end

	def test_set_bottom
		rect = Rect.new(3,5,20,40)
		rect.bottom = 42
		assert_equal([3,2,20,40],rect)
	end

	# --
	# CENTERS
	# ++

	def test_center
		rect = Rect.new(3,5,20,40)
		assert_equal([13,25],rect.center)
	end

	def test_set_center
		rect = Rect.new(3,5,20,40)
		rect.center = [16,42]
		assert_equal([6,22,20,40],rect)
	end

	def test_centerx
		rect = Rect.new(3,5,20,40)
		assert_equal(13,rect.centerx)
	end

	def test_set_centerx
		rect = Rect.new(3,5,20,40)
		rect.centerx = 16
		assert_equal([6,5,20,40],rect)
	end

	def test_centery
		rect = Rect.new(3,5,20,40)
		assert_equal(13,rect.centerx)
	end

	def test_set_centery
		rect = Rect.new(3,5,20,40)
		rect.centery = 43
		assert_equal([3,23,20,40],rect)
	end

	# --
	# CORNERS
	# ++

	def test_topleft
		rect = Rect.new(3,5,20,40)
		assert_equal([3,5],rect.topleft)
	end

	def test_set_topleft
		rect = Rect.new(3,5,20,40)
		rect.topleft = [6,2]
		assert_equal([6,2,20,40],rect)
	end

	def test_tl
		rect = Rect.new(3,5,20,40)
		assert_equal([3,5],rect.tl)
	end

	def test_set_tl
		rect = Rect.new(3,5,20,40)
		rect.tl = [6,2]
		assert_equal([6,2,20,40],rect)
	end


	def test_topright
		rect = Rect.new(3,5,20,40)
		assert_equal([23,5],rect.topright)
	end

	def test_set_topright
		rect = Rect.new(3,5,20,40)
		rect.topright = [26,2]
		assert_equal([6,2,20,40],rect)
	end

	def test_tr
		rect = Rect.new(3,5,20,40)
		assert_equal([23,5],rect.tr)
	end

	def test_set_tr
		rect = Rect.new(3,5,20,40)
		rect.tr = [26,2]
		assert_equal([6,2,20,40],rect)
	end


	def test_bottomright
		rect = Rect.new(3,5,20,40)
		assert_equal([23,45],rect.bottomright)
	end

	def test_set_bottomright
		rect = Rect.new(3,5,20,40)
		rect.bottomright = [26,42]
		assert_equal([6,2,20,40],rect)
	end

	def test_br
		rect = Rect.new(3,5,20,40)
		assert_equal([23,45],rect.br)
	end

	def test_set_br
		rect = Rect.new(3,5,20,40)
		rect.br = [26,42]
		assert_equal([6,2,20,40],rect)
	end


	def test_bottomleft
		rect = Rect.new(3,5,20,40)
		assert_equal([3,45],rect.bottomleft)
	end

	def test_set_bottomleft
		rect = Rect.new(3,5,20,40)
		rect.bottomleft = [6,42]
		assert_equal([6,2,20,40],rect)
	end

	def test_bl
		rect = Rect.new(3,5,20,40)
		assert_equal([3,45],rect.bl)
	end

	def test_set_bl
		rect = Rect.new(3,5,20,40)
		rect.bl = [6,42]
		assert_equal([6,2,20,40],rect)
	end

	# --
	# MIDPOINTS
	# ++

	def test_midleft
		rect = Rect.new(3,5,20,40)
		assert_equal([3,25],rect.midleft)
	end

	def test_set_midleft
		rect = Rect.new(3,5,20,40)
		rect.midleft = [6,22]
		assert_equal([6,2,20,40],rect)
	end

	def test_ml
		rect = Rect.new(3,5,20,40)
		assert_equal([3,25],rect.ml)
	end

	def test_set_ml
		rect = Rect.new(3,5,20,40)
		rect.ml = [6,22]
		assert_equal([6,2,20,40],rect)
	end


	def test_midtop
		rect = Rect.new(3,5,20,40)
		assert_equal([13,5],rect.midtop)
	end

	def test_set_midtop
		rect = Rect.new(3,5,20,40)
		rect.midtop = [16,2]
		assert_equal([6,2,20,40],rect)
	end

	def test_mt
		rect = Rect.new(3,5,20,40)
		assert_equal([13,5],rect.mt)
	end

	def test_set_mt
		rect = Rect.new(3,5,20,40)
		rect.mt = [16,2]
		assert_equal([6,2,20,40],rect)
	end


	def test_midright
		rect = Rect.new(3,5,20,40)
		assert_equal([23,25],rect.midright)
	end

	def test_set_midright
		rect = Rect.new(3,5,20,40)
		rect.midright = [26,22]
		assert_equal([6,2,20,40],rect)
	end

	def test_mr
		rect = Rect.new(3,5,20,40)
		assert_equal([23,25],rect.mr)
	end

	def test_set_mr
		rect = Rect.new(3,5,20,40)
		rect.mr = [26,22]
		assert_equal([6,2,20,40],rect)
	end


	def test_midbottom
		rect = Rect.new(3,5,20,40)
		assert_equal([13,45],rect.midbottom)
	end

	def test_set_midbottom
		rect = Rect.new(3,5,20,40)
		rect.midbottom = [16,42]
		assert_equal([6,2,20,40],rect)
	end

	def test_mb
		rect = Rect.new(3,5,20,40)
		assert_equal([13,45],rect.mb)
	end

	def test_set_mb
		rect = Rect.new(3,5,20,40)
		rect.mb = [16,42]
		assert_equal([6,2,20,40],rect)
	end
end
