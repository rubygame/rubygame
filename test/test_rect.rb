#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 
 
# This is a unit test suite for Rubygame Rects.
# However. it is BY NO MEANS COMPREHENSIVE.
#
# If you have the time and motivation, please consider contributing
# a few more tests to improve this suite.
# 
# The following methods (of Rect if unspecified) have NO TESTS:
#  new_from_object
#  clip
#  clip!
#  collide_hash
#  collide_hash_all
#  collide_array
#  collide_array_all
#  collide_point?
#  collide_rect?
#  contain?
#  inflate!
#  move
#  move!
#  normalize
#  normalize!
#  union
#  union!
#  union_all
#  union_all!
#  Surface#make_rect
# 
# The following methods (of Rect if unspecified) have INSUFFICIENT TESTS:
#  (no methods)
# 
# The following methods (of Rect if unspecified) have SUFFICIENT TESTS:
#  initialize
#  to_s
#  inspect
#  []
#  []=
#  x
#  y
#  w
#  h
#  width
#  height
#  size
#  left
#  top
#  right
#  bottom
#  center
#  centerx
#  centery
#  topleft
#  topright
#  bottomleft
#  bottomright
#  midleft
#  midtop
#  midright
#  midbottomX
#

# --
# Table of Contents:
#  INITIALIZATION
#  CONVERSION
#  PRIMARY ATTRIBUTES
#  SIDES
#  CENTERS
#  CORNERS
#  MIDPOINTS
#  CLAMP
#  INFLATE
# ++


require "test/unit"
require "rubygame"
Rect = Rubygame::Rect

# A class to test Rect.new_from_object()'s ability to extract a Rect from
# an object which responds to :rect
class RectParent
	attr_reader :rect
	def initialize(r)
		@rect = r
	end
end


class TC_Rect < Test::Unit::TestCase

	# --
	# INITALIZATION
	# ++

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

	# Test #new_from_object with a Rect
	def test_nfo_rect
		rect = Rect.new_from_object(Rect.new(3,5,20,40))
		assert_equal([3,5,20,40],rect)
		assert_kind_of(Rect,rect)
	end

	# Test #new_from_object with an Array
	def test_nfo_rect
		rect = Rect.new_from_object([3,5,20,40])
		assert_equal([3,5,20,40],rect)
		assert_kind_of(Rect,rect)
	end

	# Test #new_from_object with a .rect attribute which is a Rect
	def test_nfo_rect_attr_rect

		rect = Rect.new_from_object(RectParent.new(Rect.new(3,5,20,40)))
		assert_equal([3,5,20,40],rect)
		assert_kind_of(Rect,rect)
	end

	# Test #new_from_object with a .rect attribute which is an Array
	def test_nfo_rect_attr_rect
		rect = Rect.new_from_object(RectParent.new([3,5,20,40]))
		assert_equal([3,5,20,40],rect)
		assert_kind_of(Rect,rect)
	end

	# --
	# CONVERSION
	# ++

	# Test that output from #to_s is proper with a Rect of Integers
	def test_to_s_int
		rect = Rect.new(3,5,20,40)
		assert_equal("#<Rect [3,5,20,40]>",rect.to_s)
	end

	# Test that output from #to_s is proper with a Rect of Floats
	def test_to_s_float
		rect = Rect.new(3.15,5.2,20.3,40.5)
		assert_equal("#<Rect [3.15,5.2,20.3,40.5]>",rect.to_s)
	end

	# Test that output from #inspect is proper with a Rect of Integers
	def test_inspect_int
		rect = Rect.new(3,5,20,40)
		assert_equal("#<Rect:#{rect.object_id} [3,5,20,40]>",rect.inspect)
	end

	# Test that output from #inspect is proper with a Rect of Floats
	def test_inspect_float
		rect = Rect.new(3.15,5.2,20.3,40.5)
		assert_equal("#<Rect:#{rect.object_id} [3.15,5.2,20.3,40.5]>",rect.inspect)
	end

	# --
	# PRIMARY ATTRIBUTES
	# ++

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

	# --
	# SIDES
	# ++

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


	# --
	# CLAMP
	# ++

	# Clamp a rect that fits.
	def test_clamp_fits
		rect_a = Rect.new(0,0,20,20)
		rect_b = Rect.new(40,10,6,6)
		assert_equal([14,10,6,6],rect_b.clamp(rect_a))
	end

	# Clamp a rect that fits, but is already contained (no effect)
	def test_clamp_contained
		rect_a = Rect.new(0,0,20,20)
		rect_b = Rect.new(10,10,6,6)
		assert_equal([10,10,6,6],rect_b.clamp(rect_a))
	end

	# Clamp a rect that is too wide.
	def test_clamp_wide
		rect_a = Rect.new(0,0,20,20)
		rect_b = Rect.new(40,10,30,6)
		assert_equal([-5,10,30,6],rect_b.clamp(rect_a))
	end

	# Clamp a rect that is too tall.
	def test_clamp_tall
		rect_a = Rect.new(0,0,20,20)
		rect_b = Rect.new(10,40,6,30)
		assert_equal([10,-5,6,30],rect_b.clamp(rect_a))
	end

	# Clamp a rect that is both too wide and too tall.
	def test_clamp_nofit
		rect_a = Rect.new(0,0,20,20)
		rect_b = Rect.new(10,40,30,30)
		assert_equal([-5,-5,30,30],rect_b.clamp(rect_a))
	end


	# --
	# INFLATE
	# ++

	# Inflate a rect by zero on x and y
	def test_inflate_zero_x_zero_y
		assert_equal([0,0,20,20],
								 Rect.new(0,0,20,20).inflate(0,0))
	end

	# Inflate a rect by an even positive integer on x and y
	def test_inflate_evenposint_x_evenposint_y
		assert_equal([-2,-3,24,26],
								 Rect.new(0,0,20,20).inflate(4,6))
	end

	# Inflate a rect by an odd negative integer on x and y
	# NOTE: Pygame would give a result of [-1,-3,23,25].
	def test_inflate_oddposint_x_oddposint_y
		assert_equal([-1,-2,23,25],
								 Rect.new(0,0,20,20).inflate(3,5))
	end

	# Inflate a rect by an even negative integer on x and y
	def test_inflate_evennegint_x_evennegint_y
		assert_equal([2,3,16,14],
								 Rect.new(0,0,20,20).inflate(-4,-6))
	end

	# Inflate a rect by an odd negative integer on x and y
	# NOTE: Pygame would give a result of [1,2,17,15].
	def test_inflate_oddnegint_x_oddnegint_y
		assert_equal([2,3,17,15],
								 Rect.new(0,0,20,20).inflate(-3,-5))
	end

	# --
	# COLLIDE_RECT
	# ++

	# Test collision between rects which do not collide on either axis.
	def test_collide_rect_nox_noy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(20,20,10,10)
		assert(!(r1.collide_rect?(r2)), "r1 should not collide with r2")
		assert(!(r2.collide_rect?(r1)), "r2 should not collide with r1")
	end

	# Test collision between rects which overlap on the X axis only
	# (i.e. they would intersect if they were at the same vertical position).
	def test_collide_rect_overlapx_noy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(5,30,10,10)
		assert(!(r1.collide_rect?(r2)), "r1 should not collide with r2")
		assert(!(r2.collide_rect?(r1)), "r2 should not collide with r1")
	end

	# Test collision between rects which overlap on the Y axis only
	# (i.e. they would intersect if they were at the same horizontal position).
	def test_collide_rect_nox_overlapy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(20,5,10,10)
		assert(!(r1.collide_rect?(r2)), "r1 should not collide with r2")
		assert(!(r2.collide_rect?(r1)), "r2 should not collide with r1")
	end

	# Test collision between rects which overlap on both axes.
	def test_collide_rect_overlapx_overlapy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(5,5,10,10)
		assert(r1.collide_rect?(r2), "r1 should collide with r2")
		assert(r2.collide_rect?(r1), "r2 should collide with r1")
	end

	# Test collision between rects, one containing the other on both axes.
	def test_collide_rect_conx_cony
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(5,5,4,4)
		assert(r1.collide_rect?(r2), "r1 should collide with r2")
		assert(r2.collide_rect?(r1), "r2 should collide with r1")
	end

	# Test collision between rects touching but not overlapping on X axis only.
	def test_collide_rect_touchx_noy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(10,0,10,10)
		assert(r1.collide_rect?(r2), "r1 should collide with r2")
		assert(r2.collide_rect?(r1), "r2 should collide with r1")
	end

	# Test collision between rects touching but not overlapping on Y axis only.
	def test_collide_rect_nox_touchy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(0,10,10,10)
		assert(r1.collide_rect?(r2), "r1 should collide with r2")
		assert(r2.collide_rect?(r1), "r2 should collide with r1")
	end

	# Test collision between rects touching but not overlapping on both axes.
	# (i.e. corners are touching)
	def test_collide_rect_touchx_touchy
		r1 = Rect.new(0,0,10,10)
		r2 = Rect.new(10,10,10,10)
		assert(r1.collide_rect?(r2), "r1 should collide with r2")
		assert(r2.collide_rect?(r1), "r2 should collide with r1")
	end

	# --
	# UNION
	# ++

  # Test union between two non-overlapping rects.
  def test_union_separate
    r1 = Rect.new([0,0,10,10])
    r2 = Rect.new([20,20,10,10])
    assert_equal([0,0,30,30], r1.union(r2))
    assert_equal([0,0,30,30], r2.union(r1))
    assert_equal(r1.union(r2), r2.union(r1))
  end

  # Test union between two overlapping rects.
  def test_union_overlap
    r1 = Rect.new([0,0,10,10])
    r2 = Rect.new([5,5,10,10])
    assert_equal([0,0,15,15], r1.union(r2))
    assert_equal([0,0,15,15], r2.union(r1))
  end

  # Test union between a rect and another rect which it contains.
  def test_union_contained
    r1 = Rect.new([0,0,20,20])
    r2 = Rect.new([5,5,10,10])
    assert_equal([0,0,20,20], r1.union(r2))
    assert_equal([0,0,20,20], r2.union(r1))
  end

  # Test union between two identical rects.
  def test_union_identical
    r1 = Rect.new([0,0,20,20])
    r2 = Rect.new([0,0,20,20])
    assert_equal([0,0,20,20], r1.union(r2))
    assert_equal([0,0,20,20], r2.union(r1))
  end

end
