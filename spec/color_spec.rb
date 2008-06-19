
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame/color'
include Rubygame::Color


DELTA = 0.01

# Some sample colors in RGB, HSV, and HSL forms
$colors = {
	:ruby      =>  { :rgb => [0.44, 0.0625, 0.0625], :hsv => [   0, 0.86, 0.44], :hsl => [   0, 0.75, 0.25] },
	:skyblue   =>  { :rgb => [0.50, 0.7500, 1.0000], :hsv => [0.56, 0.50, 1.00], :hsl => [0.56, 1.00, 0.75] },
	:chocolate =>  { :rgb => [0.38, 0.2500, 0.1300], :hsv => [0.08, 0.67, 0.38], :hsl => [0.83, 0.50, 0.25] }
}

##############################
##      SHARED  SPECS       ##
##############################

describe "Color with RGBA array (shared)", :shared => true do 
	it "should have an RGBA array with 4 components" do 
		@color.should respond_to(:to_rgba_ary)
		@color.to_rgba_ary.should be_instance_of( Array )
		@color.to_rgba_ary.should have_exactly(4).components
	end
	
	it "should have the expected red component" do 
		@color.to_rgba_ary.at(0).should be_close( @r.to_f, DELTA )
	end
	
	it "should have the expected green component" do 
		@color.to_rgba_ary.at(1).should be_close( @g.to_f, DELTA )
	end
	
	it "should have the expected blue component" do 
		@color.to_rgba_ary.at(2).should be_close( @b.to_f, DELTA )
	end
	
	it "should have the expected alpha compenent" do 
		@color.to_rgba_ary.at(3).should be_close( @a.to_f, DELTA )
	end
end

##############################
##    RGB  SHARED  SPECS    ##
##############################

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

	it "should have the expected red component" do
		@color.r.should be_close( @r.to_f, DELTA )
	end
	
	it "should have the expected green component" do
		@color.g.should be_close( @g.to_f, DELTA )
	end
	
	it "should have the expected blue component" do
		@color.b.should be_close( @b.to_f, DELTA )
	end
	
	it "should have the expected alpha component" do
		@color.a.should be_close( @a.to_f, DELTA )
	end
	
end

##############################
##   RGB  INITIALIZATION    ##
##############################

describe "ColorRGB initialized from a 3-Array" do
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 1.0
		@color = ColorRGB.new( [@r, @g, @b] )
	end
	
	it "should have full opacity" do 
		@color.a.should == 1.0
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB initialized from a 4-Array" do
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@color = ColorRGB.new( [@r, @g, @b, @a] )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB initialized from an Array of integers" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 1.0
		@r, @g, @b, @a = [@r, @g, @b, @a].collect { |c| c.to_i }
		@color = ColorRGB.new( [@r, @g, @b, @a] )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB initialized from a ColorRGB" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@source = ColorRGB.new( [@r, @g, @b, @a] )
		@color  = ColorRGB.new( @source )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB initialized from a ColorHSV" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
		@color  = ColorRGB.new( @source )
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"

end

describe "ColorRGB initialized from a ColorHSL" do 
	before(:each) do
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@source = ColorHSL.new( $colors[:ruby][:hsl] + [@a] )
		@color  = ColorRGB.new( @source )
	end

	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

##############################
#         RGB MATHS          #
##############################

describe "ColorRGB added with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@color = @color1 + @color2
		
		@r, @g, @b, @a = 0.29, 0.33, 0.37, 0.5
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB subtracted with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@color = @color1 - @color2

		@r, @g, @b, @a = 0.21, 0.17, 0.13, 0.5
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB multiplied with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] ) 

		@color = @color1 * @color2

		@r, @g, @b, @a = 0.01, 0.02, 0.03, 0.5
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB divided with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.1, 0.1, 0.1, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] ) 

		@color = @color1 / @color2

		@r, @g, @b, @a = 1.0, 0.625, 0.3125, 0.5
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB over another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] ) 

		@color = @color1.over(@color2)

		@r, @g, @b, @a = 0.27, 0.29, 0.33, 0.7
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB averaged with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] ) 

		@color = @color1.average(@color2)

		@r, @g, @b, @a = 0.3, 0.35, 0.45, 0.45
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorRGB weighted-averaged with another ColorRGB" do 
	before(:each) do
		@color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
		@color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] ) 

		@color = @color1.average(@color2, 0.9)

		@r, @g, @b, @a = 0.46, 0.47, 0.49, 0.49
	end
	
	it_should_behave_like "ColorRGB (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end


##############################
##    HSV  SHARED  SPECS    ##
##############################

describe "ColorHSV (shared)", :shared => true do 
	it "should have a 'h' (hue) component which is a Float" do
		@color.should respond_to(:h)
		@color.h.should be_instance_of( Float )
	end
	
	it "should have a 's' (saturation) component which is a Float" do
		@color.should respond_to(:s)
		@color.s.should be_instance_of( Float )
	end
	
	it "should have a 'v' (value) component which is a Float" do
		@color.should respond_to(:v)
		@color.v.should be_instance_of( Float )
	end
	
	it "should have an 'a' (alpha) component which is a Float" do
		@color.should respond_to(:a)
		@color.a.should be_instance_of( Float )
	end

	it "should have the expected hue component" do
		@color.h.should be_close( @h.to_f, DELTA )
	end
	
	it "should have the expected saturation component" do
		@color.s.should be_close( @s.to_f, DELTA )
	end
	
	it "should have the expected value component" do
		@color.v.should be_close( @v.to_f, DELTA )
	end
	
	it "should have the expected alpha component" do
		@color.a.should be_close( @a.to_f, DELTA )
	end
end

##############################
##   HSV  INITIALIZATION    ##
##############################

describe "ColorHSV initialized from a 3-Array" do
	before(:each) do
		@h, @s, @v = $colors[:ruby][:hsv]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 1.0
		@color = ColorHSV.new( [@h, @s, @v] )
	end
	
	it "should have full opacity" do 
		@color.a.should == 1.0
	end
	
	it_should_behave_like "ColorHSV (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSV initialized from a 4-Array" do
	before(:each) do
		@h, @s, @v = $colors[:ruby][:hsv]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@color = ColorHSV.new( [@h, @s, @v, @a] )
	end
	
	it_should_behave_like "ColorHSV (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

# describe "ColorHSV initialized from an Array of integers" do 
# 	before(:each) do
# 		@h, @s, @v = $colors[:ruby][:hsv]
# 		@a = 1.0
# 		@color = ColorHSV.new( [@h, @s, @v, @a] )
# 	end
#	
# 	it_should_behave_like "ColorHSV (shared)"
# 	it_should_behave_like "Color with RGBA array (shared)"
#	
# end

describe "ColorHSV initialized from a ColorRGB" do 
	before(:each) do
		@h, @s, @v = $colors[:ruby][:hsv]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5

		@source = ColorRGB.new( $colors[:ruby][:rgb] + [@a] )
		@color  = ColorHSV.new( @source )
	end
	
	it_should_behave_like "ColorHSV (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSV initialized from a ColorHSV" do 
	before(:each) do
		@h, @s, @v = $colors[:ruby][:hsv]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		
		
		@source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
		@color  = ColorHSV.new( @source )
	end
	
	it_should_behave_like "ColorHSV (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSV initialized from a ColorHSL" do 
	before(:each) do
		@h, @s, @v = $colors[:ruby][:hsv]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5

		@source = ColorHSL.new( $colors[:ruby][:hsl] + [@a] )
		@color  = ColorHSV.new( @source )
	end
	
	it_should_behave_like "ColorHSV (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

##############################
##    HSV  SHARED  SPECS    ##
##############################

describe "ColorHSL (shared)", :shared => true do 
	it "should have a 'h' (hue) component which is a Float" do
		@color.should respond_to(:h)
		@color.h.should be_instance_of( Float )
	end
	
	it "should have a 's' (saturation) component which is a Float" do
		@color.should respond_to(:s)
		@color.s.should be_instance_of( Float )
	end
	
	it "should have a 'l' (luminosity) component which is a Float" do
		@color.should respond_to(:l)
		@color.l.should be_instance_of( Float )
	end
	
	it "should have an 'a' (alpha) component which is a Float" do
		@color.should respond_to(:a)
		@color.a.should be_instance_of( Float )
	end

	it "should have the expected hue component" do
		@color.h.should be_close( @h.to_f, DELTA )
	end
	
	it "should have the expected saturation component" do
		@color.s.should be_close( @s.to_f, DELTA )
	end
	
	it "should have the expected luminosity component" do
		@color.l.should be_close( @l.to_f, DELTA )
	end
	
	it "should have the expected alpha component" do
		@color.a.should be_close( @a.to_f, DELTA )
	end
end

##############################
##   HSL  INITIALIZATION    ##
##############################

describe "ColorHSL initialized from a 3-Array" do
	before(:each) do
		@h, @s, @l = $colors[:ruby][:hsl]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 1.0
		@color = ColorHSL.new( [@h, @s, @l] )
	end
	
	it "should have full opacity" do 
		@color.a.should == 1.0
	end
	
	it_should_behave_like "ColorHSL (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSL initialized from a 4-Array" do
	before(:each) do
		@h, @s, @l = $colors[:ruby][:hsl]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		@color = ColorHSL.new( [@h, @s, @l, @a] )
	end
	
	it_should_behave_like "ColorHSL (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

# describe "ColorHSL initialized from an Array of integers" do 
# 	before(:each) do
# 		@h, @s, @l = $colors[:ruby][:hsl]
# 		@a = 1.0
# 		@color = ColorHSL.new( [@h, @s, @l, @a] )
# 	end
#	
# 	it_should_behave_like "ColorHSL (shared)"
# 	it_should_behave_like "Color with RGBA array (shared)"
#	
# end

describe "ColorHSL initialized from a ColorRGB" do 
	before(:each) do
		@h, @s, @l = $colors[:ruby][:hsl]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5

		@source = ColorRGB.new( $colors[:ruby][:rgb] + [@a] )
		@color  = ColorHSL.new( @source )
	end
	
	it_should_behave_like "ColorHSL (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSL initialized from a ColorHSV" do 
	before(:each) do
		@h, @s, @l = $colors[:ruby][:hsl]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5
		
		
		@source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
		@color  = ColorHSL.new( @source )
	end
	
	it_should_behave_like "ColorHSL (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end

describe "ColorHSL initialized from a ColorHSL" do 
	before(:each) do
		@h, @s, @l = $colors[:ruby][:hsl]
		@r, @g, @b = $colors[:ruby][:rgb]
		@a = 0.5

		@source = ColorHSL.new( $colors[:ruby][:hsl] + [@a] )
		@color  = ColorHSL.new( @source )
	end
	
	it_should_behave_like "ColorHSL (shared)"
	it_should_behave_like "Color with RGBA array (shared)"
	
end
