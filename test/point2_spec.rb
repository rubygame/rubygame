require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'
require 'rubygame/gl/vector2'
require 'rubygame/gl/transform2'

include Math

describe Point2 do
	before :each do
		@a = Point2[2,4]
		@b = Point2[10,-3]
		@v = Vector2[5,8]
	end
	
	it "should have a 'new' constructor" do 
		Point2.new(2,4).should == @a
	end
	
	it "should have a [] constructor" do 
		Point2[2,4].should == @a
	end
	
	it "should have a Point2.ify mass constructor" do 
		Point2.ify( [1,2], [3,4], [5,6] ).should == [Point2[1,2], Point2[3,4], Point2[5,6]]
	end

	it "should have a x attribute reader" do 
		@a.x.should == 2
	end
	
	it "should have a y attribute reader" do 
		@a.y.should == 4
	end
	
	it "should have an equality (==) operator" do 
		(@a == Point2[2,4]).should be_true
		(@a == @b).should be_false
	end
	
	it "should have an [] operator" do 
		@a[0].should == 2
		@a[1].should == 4
	end
	
	it "should support addition with a Vector2, yielding a Point2" do 
		result = @a + @v
		result.should be_instance_of(Point2)
		result.should == Point2[7,12]
	end
	
	it "should support addition with another Point2, yielding a Vector2" do 
		result = @a - @b
		result.should be_instance_of(Vector2)
		result.should == Vector2[-8, 7]
	end
	
	it "should be able to be projected onto a Vector2" do 
		result = Point2[4,0].projected_onto( Vector2[1,1] )
		result.should be_instance_of(Point2)
		result.should == Point2[2,2]
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
		result.should == @a
	end
end
