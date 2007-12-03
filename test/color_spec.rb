require 'rubygame/color'
include Rubygame::Color

# Uses RSpec. See http://rspec.rubyforge.org/

# TODO:
# - Test all maths with other types
# - Make it more DRY

# Make Float quite fuzzy
class Float
	def ==( other )
		(self - other).abs <= 0.1
	end
end


# Some sample colors in RGB, HSV, and HSL forms
$colors = {
	:ruby      =>  { :rgb => [0.44, 0.0625, 0.0625], :hsv => [  0, 0.86, 0.44], :hsl => [  0, 0.75, 0.25] },
	:skyblue   =>  { :rgb => [0.50, 0.7500, 1.0000], :hsv => [210, 0.50, 1.00], :hsl => [210, 1.00, 0.75] },
	:chocolate =>  { :rgb => [0.38, 0.2500, 0.1300], :hsv => [ 30, 0.67, 0.38], :hsl => [ 30, 0.50, 0.25] }
}

describe "ColorRGB (shared)", :shared => true do 
	it "should have a 'r' (red) component which is a Float" do
		@color.should respond_to(:r)
		@color.r.should be_instance_of( Float )
	end
	
	it "should have a 'g' (green) component which is a Float" do
		@color.should respond_to(:g)
		@color.g.should be_instance_of( Float )
	end
	
	it "should have a 'b' (blue) component which is a Float" do
		@color.should respond_to(:b)
		@color.b.should be_instance_of( Float )
	end
	
	it "should have an 'a' (alpha) component which is a Float" do
		@color.should respond_to(:a)
		@color.a.should be_instance_of( Float )
	end
end

describe "ColorRGB with expected values (shared)", :shared => true do 
	it "should have the expected red component" do
		@color.r.should == @r.to_f
	end
	
	it "should have the expected green component" do
		@color.g.should == @g.to_f
	end
	
	it "should have the expected blue component" do
		@color.b.should == @b.to_f
	end
	
	it "should have the expected alpha component" do
		@color.a.should == @a.to_f
	end
end

describe "Color with expected RGBA Array (shared)", :shared => true do 
	it "should have the expected RGBA Array" do 
		@color.to_rgba_ary.should == [@r, @g, @b, @a]
	end
end

describe "ColorRGB initialized from a 3-Array" do
	before(:each) do
		@r, @g, @b, @a = 0.1, 0.2, 0.3, 1.0
		@color = ColorRGB.new( [@r, @g, @b] )
	end
	
	it "should have full opacity" do 
		@color.a.should == 1.0
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"
	
end

describe "ColorRGB initialized from a 4-Array" do
	before(:each) do
		@r, @g, @b, @a = 0.1, 0.2, 0.3, 0.4
		@color = ColorRGB.new( [@r, @g, @b, @a] )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"
	
end

describe "ColorRGB initialized from an Array of integers" do 
	before(:each) do
		@r, @g, @b, @a = 1.0, 0.0, 0.0, 1.0
		@color = ColorRGB.new( [1, 0, 0, 1] )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"
	
end

describe "ColorRGB initialized from a ColorRGB" do 
	before(:each) do
		@r, @g, @b, @a = 0.1, 0.2, 0.3, 0.4
		@source = ColorRGB.new( [@r, @g, @b, @a] )
		@color  = ColorRGB.new( @source )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"
	
end

describe "ColorRGB initialized from a ColorHSV" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
		@color  = ColorRGB.new( @source )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"

end

describe "ColorRGB initialized from a ColorHSL" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@source = ColorHSV.new( $colors[:ruby][:hsl] + [@a] )
		@color  = ColorRGB.new( @source )
	end

	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "ColorRGB with expected values (shared)"
	
end

##############################
#         RGB MATHS          #
##############################

def clamp(v, min=0.0, max=1.0)
	v = min if v < min
	v = max if v > max
	return v		
end


describe "ColorRGB math (shared)", :shared => true do
	it "should have the expected result" do 
		@result.to_rgba_ary.should == @expect
	end	
	
	it "should be a ColorRGB" do 
		@result.should be_instance_of( ColorRGB )
	end
end

describe "ColorRGB added with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@result = @color1 + @color2
		@expect = [0.25 + 0.04, 0.25 + 0.08, 0.25 + 0.12, 0.5]
		@expect = @expect.collect { |f| clamp(f) }
	end
	
	it_should_behave_like "ColorRGB math (shared)"
	
end

describe "ColorRGB subtracted with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@result = @color1 - @color2
		@expect = [0.25 - 0.04, 0.25 - 0.08, 0.25 - 0.12, 0.5]
		@expect = @expect.collect { |f| clamp(f) }
	end
	
	it_should_behave_like "ColorRGB math (shared)"
	
end

describe "ColorRGB multiplied with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@result = @color1 * @color2
		@expect = [0.25 * 0.04, 0.25 * 0.08, 0.25 * 0.12, 0.5]
		@expect = @expect.collect { |f| clamp(f) }
	end
	
	it_should_behave_like "ColorRGB math (shared)"
	
end

describe "ColorRGB divided with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.1, 0.1, 0.1, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] ) 

		@result = @color1 / @color2
		@expect = [0.25 / 0.04, 0.25 / 0.08, 0.25 / 0.12, 0.5]
		@expect = @expect.collect { |f| clamp(f) }
	end
	
	it_should_behave_like "ColorRGB math (shared)"
	
end
