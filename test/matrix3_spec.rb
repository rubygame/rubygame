require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'
require 'rubygame/gl/vector2'
require 'rubygame/gl/transform2'

include Math

describe Matrix3 do
	before :each do
		@identity = Matrix3[[1,0,0],[0,1,0],[0,0,1]]
		@shear = Matrix3[[1,8,0],[2,1,0],[0,0,1]]
		@scale = Matrix3[[4,0,0],[0,3,0],[0,0,1]]
		@rotate = Matrix3[[cos(PI/2),-sin(PI/2),0],[sin(PI/2),cos(PI/2),0],[0,0,1]]
		@translate = Matrix3[[1,0,10],[0,1,15],[0,0,1]]
		@sample = Matrix3[[1,2,3],[4,5,6],[7,8,9]]
	end

	it "should have a 'new' constructor" do 
		Matrix3.new([1,2,3],[4,5,6],[7,8,9]).should == @sample
	end
	
	it "should have a [] constructor" do 
		Matrix3[[1,2,3],[4,5,6],[7,8,9]].to_ary.should == @sample
	end
	
	it "should have an 'identity' constructor" do 
		Matrix3.identity.should == @identity
	end
	
	it "should have a 'shear' constructor" do 
		Matrix3.shear(8,2).should == @shear
	end
	
	it "should have a 'scale' constructor" do 
		Matrix3.scale(4,3).should == @scale
	end
	
	it "should have a 'rotate' constructor" do 
		Matrix3.rotate(PI/2).should == @rotate
	end
	
	it "should have a 'translate' constructor" do 
		Matrix3.translate(10,15).should == @translate
	end
	
	it "should have an equality (==) operator" do 
		@identity.should == @identity
	end
	
	it "should support matrix multiplication with other Matrix3's" do 
		result = @translate * @sample
		result.should be_instance_of(Matrix3)
		result.should == Matrix3[[71,82,93],[109,125,141],[7,8,9]]
	end
	
	it "should support multiplication with a Point2" do 
		(@translate * Point2[5,10]).should == Point2[15,25]
		(@scale * Point2[5,10]).should == Point2[20,30]
	end
	
	it "should support multiplication with a Vector2" do 
		(@translate * Vector2[5,10]).should == Vector2[5,10] # Vector2's don't translate
		(@scale * Vector2[5,10]).should == Vector2[20,30]
	end
	
	it "should support multiplication with a Transform2" do 
		(@identity * Transform2.new(:shift => [10,15])).should == @translate
	end
	
	it "should be convertible to nested Arrays" do 
		@sample.to_ary.should == [[1,2,3],[4,5,6],[7,8,9]]
	end
	
	it "should have a #to_m method to 'convert' to Matrix3" do 
		@sample.to_m.should == @sample
	end
end
