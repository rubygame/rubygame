require 'rubygame/color'
include Rubygame::Color

# Uses RSpec. See http://rspec.rubyforge.org/

# TODO:
# - Test other color types besides RGB. (HSV and HSL)
# - Test -, *, and / with same type, too.
# - Test all maths with other types
# - Test to_rgba_ary returns [r, g, b, a] correctly for all types
# - Test each type's constructor can take an instance of other color types
# - Test each type's constructor can take a 3 or 4 array with native components.
#   E.g. for ColorHSV it takes [h,s,v,a] instead of [r,g,b,a]

describe ColorRGB do
	it "constructor should work with an Array of 3 numbers" do 
		Proc.new { ColorRGB.new([0.5, 0.0, 1.0]) }.should_not raise_error
		color = ColorRGB.new([0.5, 0.0, 1.0])
		color.to_rgba_ary.should == [0.5, 0.0, 1.0, 1.0]
	end
	
	it "constructor should work with an Array of 4 numbers" do 
		Proc.new { ColorRGB.new([0.5, 0.0, 1.0, 0.5]) }.should_not raise_error
		color = ColorRGB.new([0.5, 0.0, 1.0, 0.5])
		color.to_rgba_ary.should == [0.5, 0.0, 1.0, 0.5]
	end
	
	it "should support addition with other ColorRGBs" do 
		color1 = ColorRGB.new([0.5, 0.0, 1.0])
		color2 = ColorRGB.new([0.1, 0.2, 0.3])
		(color1 + color2).should be_instance_of(ColorRGB)
		(color1 + color2).to_rgba_ary.should == [0.6, 0.2, 1.0, 1.0]
	end
end

