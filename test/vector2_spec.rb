require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'
require 'rubygame/gl/vector2'
require 'rubygame/gl/transform2'

include Math

describe Vector2 do
	before :each do
		@a = Vector2[2,4]
		@b = Vector2[10,-3]
	end
	
	it "should have a 'new' constructor" do 
		Vector2.new(2,4).should == @a
	end
	
	it "should have a [] constructor" do 
		Vector2[2,4].should == @a
	end
	
	it "should have a Vector2.ify mass constructor" do 
		Vector2.ify( [1,2], [3,4], [5,6] ).should == [Vector2[1,2], Vector2[3,4], Vector2[5,6]]
	end

	it "should have a x attribute reader" do 
		@a.x.should == 2
	end
	
	it "should have a y attribute reader" do 
		@a.y.should == 4
	end
	
	it "should have an equality (==) operator" do 
		(@a == Vector2[2,4]).should be_true
		(@a == @b).should be_false
	end
	
	it "should have an [] operator" do 
		@a[0].should == 2
		@a[1].should == 4
	end
	
	it "should support addition with another Vector2, yielding a Vector2" do 
		result = @a + @b
		result.should be_instance_of(Vector2)
		result.should == Vector2[12,1]
	end
	
	it "should support subraction with another Vector2, yielding a Vector2" do 
		result = @a - @b
		result.should be_instance_of(Vector2)
		result.should == Vector2[-8, 7]
	end
	
	it "should support negation" do 
		(-@a).should == Vector2[-2,-4]
	end

	it "should have an angle" do 
		Vector2[1,1].angle.should == Math::PI/4
	end
	
	it "should have an angle measured against another Vector2" do 
		Vector2[1,1].angle_with(Vector2[-4,4]).should == Math::PI/2
	end
	
	it "should have a dot product with another Vector2" do 
		@a.dot(@b).should == (2 * 10 + 4 * -3)
	end
	
	it "should have a magnitude" do 
		Vector2[3,4].magnitude.should == 5
	end
	
	it "should have a perpendicular Vector2" do 
		@a.perp.should == Vector2[-4,2]
	end
	
	it "should be able to be projected onto a Vector2" do 
		result = Vector2[4,0].projected_onto( Vector2[1,1] )
		result.should be_instance_of(Vector2)
		result.should == Vector2[2,2]
	end
	
	it "should be convertible to an Array" do 
		result = @a.to_ary
		result.should be_instance_of(Array)
		result.should == [2,4]
	end
	
	it "should be convertible to a Vector2" do 
		result = @a.to_v
		result.should be_instance_of(Vector2)
		result.should == Vector2[2,4]
	end
	
	it "should be convertible to a Point2" do 
		result = @a.to_p
		result.should be_instance_of(Point2)
		result.should == Point2[2,4]
	end
	
	it "should have a unit Vector2" do 
		Vector2[3,4].unit.should == Vector2[0.6, 0.8]
	end
	
	it "should have a unit dot product with another Vector2" do 
		@a.udot(@a.perp).should == 0
	end
end
