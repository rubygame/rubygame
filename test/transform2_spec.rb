require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'
require 'rubygame/gl/vector2'
require 'rubygame/gl/transform2'

include Math

describe Transform2 do 
	before :each do 
		@t = Transform2.new( :angle => PI/2, :scale => [2,0.5], :shear => [1,3], :shift => [4,5], :pivot => [10,0] )
	end
	
	it "should take a Hash as the argument to its constructor" do 
		Transform2.new( :foo => :bar ).should be_instance_of(Transform2)
	end
	
	it "should not complain when no arguments are given to its constructor" do 
		Proc.new {
			@t = Transform2.new()
		}.should_not raise_error(ArgumentError)
		@t.should be_instance_of(Transform2)
	end
	
 	it "should complain when a non-Hash is given to its constructor" do 
 		Proc.new {
 			Transform2.new( :foo )
 		}.should raise_error(ArgumentError, "Transform2.new takes 1 Hash argument. Got Symbol.")
 	end
	
	it "should have a translate constructor" do 
		Transform2.translate([4,5]).should == Transform2.new( :shift => [4,5] )
	end
	
	it "should have a rotate constructor" do 
		Transform2.rotate(PI/3).should == Transform2.new( :angle => PI/3 )
	end
	
	it "should have a scale constructor" do 
		Transform2.scale([2,0.5]).should == Transform2.new( :scale => [2,0.5] )
	end

	it "should have a rotate_from constructor" do 
		Transform2.rotate_from(PI/3, [10,0]).should == Transform2.new( :angle => PI/3, :pivot => [10,0] )
	end
	
	it "should have a scale_from constructor" do 
		Transform2.scale_from([2,0.5], [10,0]).should == Transform2.new( :scale => [2,0.5], :pivot => [10,0] )
	end

	it "should have an angle attr reader" do 
		@t.angle.should == PI/2
	end

	it "should have a scale attr reader" do 
		@t.scale.should == Vector2[2,0.5]
	end
	
	it "should have a shear attr reader" do 
		@t.shear.should == Vector2[1,3]
	end

	it "should have a shift attr reader" do 
		@t.shift.should == Vector2[4,5]
	end
	
	it "should have a pivot attr reader" do 
		@t.pivot.should == Point2[10,0]
	end
	
	it "should have an equality (==) operator" do 
		t2 = Transform2.new( :angle => PI/2, :scale => [2,0.5], :shear => [1,3], :shift => [4,5], :pivot => [10,0] )
		(@t == t2).should be_true
	end
	
	it "should support multiplication with a Point2" do
		result = @t * Point2[3,2]
		result.should be_instance_of(Point2)
		result.should == (@t.to_m * Point2[3,2])
	end
	
	it "should support multiplication with a Vector2" do
		result = @t * Vector2[3,2]
		result.should be_instance_of(Vector2)
		result.should == (@t.to_m * Vector2[3,2])
	end

	it "should support multiplication with a Matrix3" do
		result = @t * Matrix3.identity
		result.should be_instance_of(Matrix3)
		result.should == (@t.to_m * Matrix3.identity)
	end

	it "should support multiplication with another Transform2" do
		result = @t * Transform2.new
		result.should be_instance_of(Matrix3)
		result.should == (@t.to_m * Transform2.new.to_m)
	end
	
	it "should be convertible to a Matrix3" do 
		@t.to_m.should be_instance_of(Matrix3)
	end
	
 	it "should correctly calculate its transformation matrix" do 
 		m2 = Matrix3[[-1.5, -0.5,  29.0],
 		             [ 2.0,  2.0, -15.0],
 		             [ 0.0,  0.0,   1.0]]
 		@t.to_m.should == m2
 	end

	it "should correctly calculate its transformation matrix (angle only)" do 
		Transform2.new( :angle => PI/2  ).to_m.should == Matrix3.rotate(PI/2)
	end
	
	it "should correctly calculate its transformation matrix (scale only)" do 
		Transform2.new( :scale => [4,5] ).to_m.should == Matrix3.scale(4,5)
	end
	
	it "should correctly calculate its transformation matrix (shear only)" do 
		Transform2.new( :shear => [4,5] ).to_m.should == Matrix3.shear(4,5)
	end
	
	it "should correctly calculate its transformation matrix (shift only)" do 
		Transform2.new( :shift => [4,5] ).to_m.should == Matrix3.translate(4,5)
	end
end
