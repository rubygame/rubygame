require 'rubygame/gl/matricks'

# Separating Axis Theorem

# Test overlap between range AB and range CD
# Assuming A<B and C<D
# 1. C is in AB
# 2. D is in AB
# 3. CD contains AB
# 4. AB contains CD
def overlap?(a, b, c, d)
	(a <= c and b >= c) or \
	(a <= d and b >= d) or \
	(a <= c and b >= d) or \
	(a >= c and b <= d)
end

# Test overlap between two sets of points, projected onto an arbitrary vector.
def projection_overlap?(vector, pointsA, pointsB)
	pA = pointsA.map do |point| 
		point.to_v.projected_onto(vector).magnitude 
	end

	pB = pointsB.map do |point| 
		point.to_v.projected_onto(vector).magnitude 
	end

	overlap?(pA.min, pA.max, pB.min, pB.max)
end
