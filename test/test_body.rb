#!/usr/bin/env ruby
require 'rubygame_body'
include Rubygame::Body

require 'test/unit'
class TestBody < Test::Unit::TestCase
	def test_raise
		assert_raises(ArgumentError) { Vector2[20,20].collide?("foo") }
	end
	
	def collisions(a,collide,no_coll)
		collide.each_with_index { |b,i|
			assert(a.collide?(b), should(i,a,b))
			assert(b.collide?(a), should(i,b,a))
		}
		no_coll.each_with_index { |b,i|
			assert(!a.collide?(b), should_not(i,a,b))
			assert(!b.collide?(a), should_not(i,b,a))
		}
	end
	
	def should(i,a,b)
		"+#{i}: #{a.inspect} should collide with #{b.inspect}"
	end
	def should_not(i,a,b)
		"-#{i}: #{a.inspect} should not collide with #{b.inspect}"
	end

	def test_ftor_ftor_collision
		assert(Vector2[20,20].collide?(Vector2[20,20]))
		assert(!Vector2[20,20].collide?(Vector2[0,0]))
		assert(!Vector2[20,20].collide?(Vector2[20,0]))
		assert(!Vector2[20,20].collide?(Vector2[0,20]))
	end
	
	def test_ftor_segment_collision
		seg = Segment.points(0,0,20,20)
		collide = [Vector2[0,0], Vector2[10,10], Vector2[20,20]]
		no_coll = [Vector2[1,0], Vector2[21,21], Vector2[-1,-1]]
		collisions(seg,collide,no_coll)
	end
	
	def test_ftor_rect_collision
		r = Rect.rect(0,0,20,20)
		collide = [Vector2[11,9], Vector2[20,20], Vector2[20,10], Vector2[0,20]]
		no_coll = [Vector2[0,30], Vector2[30,0]]
		collisions(r,collide,no_coll)
	end

	def test_ftor_circle_collision
		c       = Circle.new(Vector2[2,4],5)
		collide = [[2,4],[4,4],[2,6],[7,4],[2,9]].map{|e| e===Vector2 ? e : Vector2[*e]}
		no_coll = [Vector2[0,30], Vector2[30,0]]
		collisions(c,collide,no_coll)
		20.times {
			ftor = Vector2[2,9].rotated_around(Vector2[2,4],rand*2*Math::PI)
			assert(ftor.collide?(c), should("rand",ftor,c))
		}
		20.times {
			ftor = Vector2[2,10].rotated_around(Vector2[2,4],rand*2*Math::PI)
			assert(!ftor.collide?(c), should_not("rand",ftor,c))
		}
	end

	def test_segment_segment_collision
		a       = Segment.points(0,0,20,20)
		collide = [Segment.points(20,0,0,20), Segment.points(0,20,20,0)]
		no_coll = [Segment.points(21,21,22,22), Segment.points(1,0,21,20)]
		collisions(a,collide,no_coll)
	end
	
	def test_segment_rect_collision
		a = Rect.rect(5,7,15,23) # 20, 30 are bottom, right
		collide = [[6,8,25,32]].map{|s|Segment===s ? s : Segment.points(*s)}
		no_coll = [[0,0,4,32], [0,5,55,5]].map{|s|Segment===s ? s : Segment.points(*s)}
		collisions(a,collide,no_coll)
	end

	def test_segment_circle_collision
		c = Circle.new(Vector2[5,7],15)
		collide = [[5,8,40,28],[20,12,20,-10]].map{|s|Segment===s ? s : Segment.points(*s)}
		no_coll = [[40,40,42,42]].map{|s|Segment===s ? s : Segment.points(*s)}
		collisions(c,collide,no_coll)
	end
end

__END__
