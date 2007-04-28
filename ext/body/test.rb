require 'body'
include Rubygame::Body

require 'test/unit'
class TestBody < Test::Unit::TestCase
	def test_raise
		assert_raises(ArgumentError) { Ftor[20,20].collide?("foo") }
	end

	def test_ftor_ftor_collision
		assert(Ftor[20,20].collide?(Ftor[20,20]))
		assert(!Ftor[20,20].collide?(Ftor[0,0]))
		assert(!Ftor[20,20].collide?(Ftor[20,0]))
		assert(!Ftor[20,20].collide?(Ftor[0,20]))
	end
	
	def test_ftor_segment_collision
		seg = Segment.points(0,0,20,20)
		collide = [Ftor[0,0], Ftor[10,10], Ftor[20,20]]
		no_coll = [Ftor[1,0], Ftor[21,21], Ftor[-1,-1]]
		collide.each { |ftor|
			assert(seg.collide?(ftor))
			assert(ftor.collide?(seg))
		}
		no_coll.each { |ftor|
			assert(!seg.collide?(ftor))
			assert(!ftor.collide?(seg))
		}
	end
	
	def test_ftor_rect_collision
		r = Rect.rect(0,0,20,20)
		collide = [Ftor[11,9], Ftor[20,20], Ftor[20,10], Ftor[0,20]]
		no_coll = [Ftor[0,30], Ftor[30,0]]
		collide.each { |ftor|
			assert(r.collide?(ftor))
			assert(ftor.collide?(r))
		}
		no_coll.each { |ftor|
			assert(!r.collide?(ftor))
			assert(!ftor.collide?(r))
		}
	end
end

__END__
