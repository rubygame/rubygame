

require 'rubygame/color'
include Rubygame::Color


# Fuzz factor for floating point comparisons
DELTA = 0.01


# Some sample colors in all color models.
$colors = {
  :ruby => {
    :rgb    => [0.44, 0.0625, 0.0625],
    :hsv    => [0.00, 0.8600, 0.4400],
    :hsl    => [0.00, 0.7500, 0.2500],
    :rgb255 => [ 112,     16,     16],
  },
  :skyblue => {
    :rgb    => [0.50, 0.75, 1.00],
    :hsv    => [0.56, 0.50, 1.00],
    :hsl    => [0.56, 1.00, 0.75],
    :rgb255 => [ 128,  191,  255],
  },
  :chocolate => {
    :rgb    => [0.38, 0.25, 0.13],
    :hsv    => [0.08, 0.67, 0.38],
    :hsl    => [0.83, 0.50, 0.25],
    :rgb255 => [  97,   64,   33],
  },
}



##############################
##      SHARED  SPECS       ##
##############################

shared_examples_for "Color with RGBA array (shared)" do
  it "should have an RGBA array with 4 components" do
    @color.should respond_to(:to_rgba_ary)
    @color.to_rgba_ary.should be_instance_of( Array )
    @color.to_rgba_ary.should have_exactly(4).components
  end

  it "should have the expected red component" do
    @color.to_rgba_ary.at(0).should be_within(DELTA).of(@r.to_f)
  end

  it "should have the expected green component" do
    @color.to_rgba_ary.at(1).should be_within(DELTA).of(@g.to_f)
  end

  it "should have the expected blue component" do
    @color.to_rgba_ary.at(2).should be_within(DELTA).of(@b.to_f)
  end

  it "should have the expected alpha compenent" do
    @color.to_rgba_ary.at(3).should be_within(DELTA).of(@a.to_f)
  end


  invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
  invalid.each do |inv|
    it ".new should raise ArgumentError from #{inv.inspect}" do
      lambda{ @klass.new(inv) }.should raise_error(ArgumentError)
    end
  end

end




describe "ColorRGB" do

  before :each do
    @klass = ColorRGB
  end

  ##############################
  ##    RGB  SHARED  SPECS    ##
  ##############################

  shared_examples_for "ColorRGB (shared)" do
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
      @color.r.should be_within(DELTA).of(@r.to_f)
    end

    it "should have the expected green component" do
      @color.g.should be_within(DELTA).of(@g.to_f)
    end

    it "should have the expected blue component" do
      @color.b.should be_within(DELTA).of(@b.to_f)
    end

    it "should have the expected alpha component" do
      @color.a.should be_within(DELTA).of(@a.to_f)
    end
  end


  ##############################
  ##   RGB  INITIALIZATION    ##
  ##############################

  describe "initialized from a 3-Array" do
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

  describe "initialized from a 4-Array" do
    before(:each) do
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @color = ColorRGB.new( [@r, @g, @b, @a] )
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from an Array of integers" do
    before(:each) do
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 1.0
      @r, @g, @b, @a = [@r, @g, @b, @a].collect { |c| c.to_i }
      @color = ColorRGB.new( [@r, @g, @b, @a] )
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB" do
    before(:each) do
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @source = ColorRGB.new( [@r, @g, @b, @a] )
      @color  = ColorRGB.new( @source )
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB255" do
    before(:each) do
      @source = ColorRGB255.new( $colors[:ruby][:rgb255] + [128] )
      @color  = ColorRGB.new( @source )
      @r, @g, @b, @a = @source.to_rgba_ary
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSV" do
    before(:each) do
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
      @color  = ColorRGB.new( @source )
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSL" do
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
  #         RGB  EQL?          #
  ##############################

  describe "(eql?)" do

    before :each do
      @color1 = ColorRGB.new( $colors[:ruby][:rgb] + [0.5] )
    end

    it "should eql? itself" do
      @color1.should eql(@color1)
    end

    it "should eql? an equivalent ColorRGB" do
      @color2 = ColorRGB.new( $colors[:ruby][:rgb] + [0.5] )
      @color1.should eql(@color2)
    end

    it "should not eql? a different ColorRGB" do
      @color1.should_not eql( ColorRGB.new([0.1, 0.2, 0.3, 0.4]) )
    end

    it "should not eql? an Array with same numbers" do
      @color1.should_not eql( @color1.to_ary )
    end

    it "should not eql? a Array with different numbers" do
      @color1.should_not eql( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should not eql? an equivalent ColorRGB255" do
      @color1.should_not eql( ColorRGB255.new(@color1) )
    end

    it "should not eql? a ColorRGB255 with same numbers" do
      @color1.should_not eql( ColorRGB255.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSV" do
      @color1.should_not eql( ColorHSV.new(@color1) )
    end

    it "should not eql? a ColorHSV with same numbers" do
      @color1.should_not eql( ColorHSV.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSL" do
      @color1.should_not eql( ColorHSL.new(@color1) )
    end

    it "should not eql? a ColorHSL with same numbers" do
      @color1.should_not eql( ColorHSL.new(@color1.to_ary) )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not eql? #{inv.inspect}" do
        @color1.should_not eql( inv )
      end
    end

  end

  
  ##############################
  #           RGB ==           #
  ##############################

  describe "(==)" do

    before :each do
      @color1 = ColorRGB.new( $colors[:ruby][:rgb] + [0.5] )
    end

    it "should == an equivalent ColorRGB" do
      @color2 = ColorRGB.new( $colors[:ruby][:rgb] + [0.5] )
      @color1.should == @color2
    end

    it "should not == a different ColorRGB" do
      @color1.should_not == ColorRGB.new( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should == an Array with same numbers" do
      @color1.should == @color1.to_ary
    end

    it "should not == a Array with different numbers" do
      @color1.should_not == [0.1, 0.2, 0.3, 0.4]
    end

    it "should == an equivalent ColorRGB255" do
      @color1 = @klass.new( ColorRGB255.new(@color1) )
      @color1.should == ColorRGB255.new( @color1 )
    end

    it "should not == a ColorRGB255 with same numbers" do
      @color1.should_not == ColorRGB255.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSV" do
      @color1.should == ColorHSV.new( @color1 )
    end

    it "should not == a ColorHSV with same numbers" do
      @color1.should_not == ColorHSV.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSL" do
      @color1.should == ColorHSL.new( @color1 )
    end

    it "should not == a ColorHSL with same numbers" do
      @color1.should_not == ColorHSL.new( @color1.to_ary )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not == #{inv.inspect}" do
        @color1.should_not == inv
      end
    end

  end


  ##############################
  #         RGB MATHS          #
  ##############################

  describe "added with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] )

      @color = @color1 + @color2

      @r, @g, @b, @a = 0.29, 0.33, 0.37, 0.5
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "subtracted with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] )

      @color = @color1 - @color2

      @r, @g, @b, @a = 0.21, 0.17, 0.13, 0.5
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "multiplied with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.3, 0.4] )

      @color = @color1 * @color2

      @r, @g, @b, @a = 0.01, 0.02, 0.03, 0.5
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "divided with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.1, 0.1, 0.1, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] )

      @color = @color1 / @color2

      @r, @g, @b, @a = 1.0, 0.625, 0.3125, 0.5
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "over another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] )

      @color = @color1.over(@color2)

      @r, @g, @b, @a = 0.27, 0.29, 0.33, 0.7
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "averaged with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] )

      @color = @color1.average(@color2)

      @r, @g, @b, @a = 0.3, 0.35, 0.45, 0.45
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "weighted-averaged with another ColorRGB" do
    before(:each) do
      @color1 = ColorRGB.new( [0.5, 0.5, 0.5, 0.5] )
      @color2 = ColorRGB.new( [0.1, 0.2, 0.4, 0.4] )

      @color = @color1.average(@color2, 0.9)

      @r, @g, @b, @a = 0.46, 0.47, 0.49, 0.49
    end

    it_should_behave_like "ColorRGB (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

end




describe "ColorHSV" do

  before :each do
    @klass = ColorHSV
  end

  ##############################
  ##    HSV  SHARED  SPECS    ##
  ##############################

  shared_examples_for "ColorHSV (shared)" do
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
      @color.h.should be_within(DELTA).of(@h.to_f)
    end

    it "should have the expected saturation component" do
      @color.s.should be_within(DELTA).of(@s.to_f)
    end

    it "should have the expected value component" do
      @color.v.should be_within(DELTA).of(@v.to_f)
    end

    it "should have the expected alpha component" do
      @color.a.should be_within(DELTA).of(@a.to_f)
    end
  end


  ##############################
  ##   HSV  INITIALIZATION    ##
  ##############################

  describe "initialized from a 3-Array" do
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

  describe "initialized from a 4-Array" do
    before(:each) do
      @h, @s, @v = $colors[:ruby][:hsv]
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @color = ColorHSV.new( [@h, @s, @v, @a] )
    end

    it_should_behave_like "ColorHSV (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB" do
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

  describe "initialized from a ColorRGB255" do
    before(:each) do
      @source = ColorRGB255.new( $colors[:ruby][:rgb255] + [128] )
      @color  = ColorHSV.new( @source )
      @h, @s, @v = 0.0000, 0.8571, 0.4392
      @r, @g, @b = 0.4392, 0.0627, 0.0627
      @a = 0.5
    end

    it_should_behave_like "ColorHSV (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSV" do
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

  describe "initialized from a ColorHSL" do
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
  #         HSV  EQL?          #
  ##############################

  describe "(eql?)" do

    before :each do
      @color1 = ColorHSV.new( $colors[:ruby][:hsv] + [0.5] )
    end

    it "should eql? itself" do
      @color1.should eql(@color1)
    end

    it "should eql? an equivalent ColorHSV" do
      @color2 = ColorHSV.new( $colors[:ruby][:hsv] + [0.5] )
      @color1.should eql(@color2)
    end

    it "should not eql? a different ColorHSV" do
      @color1.should_not eql( ColorHSV.new([0.1, 0.2, 0.3, 0.4]) )
    end

    it "should not eql? an Array with same numbers" do
      @color1.should_not eql( @color1.to_ary )
    end

    it "should not eql? a Array with different numbers" do
      @color1.should_not eql( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should not eql? an equivalent ColorRGB" do
      @color1.should_not eql( ColorRGB.new(@color1) )
    end

    it "should not eql? a ColorRGB with same numbers" do
      @color1.should_not eql( ColorRGB.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorRGB255" do
      @color1.should_not eql( ColorRGB255.new(@color1) )
    end

    it "should not eql? a ColorRGB255 with same numbers" do
      @color1.should_not eql( ColorRGB255.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSL" do
      @color1.should_not eql( ColorHSL.new(@color1) )
    end

    it "should not eql? a ColorHSL with same numbers" do
      @color1.should_not eql( ColorHSL.new(@color1.to_ary) )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not eql? #{inv.inspect}" do
        @color1.should_not eql( inv )
      end
    end

  end

  
  ##############################
  #           HSV ==           #
  ##############################

  describe "(==)" do

    before :each do
      @color1 = ColorHSV.new( $colors[:ruby][:hsv] + [0.5] )
    end

    it "should == an equivalent ColorHSV" do
      @color2 = ColorHSV.new( $colors[:ruby][:hsv] + [0.5] )
      @color1.should == @color2
    end

    it "should not == a different ColorHSV" do
      @color1.should_not == ColorHSV.new( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should == an Array with same numbers" do
      @color1.should == @color1.to_ary
    end

    it "should not == a Array with different numbers" do
      @color1.should_not == [0.1, 0.2, 0.3, 0.4]
    end

    it "should == an equivalent ColorRGB" do
      @color1.should == ColorRGB.new( @color1 )
    end

    it "should not == a ColorRGB with same numbers" do
      @color1.should_not == ColorRGB.new( @color1.to_ary )
    end

    it "should == an equivalent ColorRGB255" do
      @color1 = @klass.new( ColorRGB255.new(@color1) )
      @color1.should == ColorRGB255.new( @color1 )
    end

    it "should not == a ColorRGB255 with same numbers" do
      @color1.should_not == ColorRGB255.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSL" do
      @color1.should == ColorHSL.new( @color1 )
    end

    it "should not == a ColorHSL with same numbers" do
      @color1.should_not == ColorHSL.new( @color1.to_ary )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not == #{inv.inspect}" do
        @color1.should_not == inv
      end
    end

  end

end




describe "ColorHSL" do

  before :each do
    @klass = ColorHSL
  end

  ##############################
  ##    HSL  SHARED  SPECS    ##
  ##############################

  shared_examples_for "ColorHSL (shared)" do
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
      @color.h.should be_within(DELTA).of(@h.to_f)
    end

    it "should have the expected saturation component" do
      @color.s.should be_within(DELTA).of(@s.to_f)
    end

    it "should have the expected luminosity component" do
      @color.l.should be_within(DELTA).of(@l.to_f)
    end

    it "should have the expected alpha component" do
      @color.a.should be_within(DELTA).of(@a.to_f)
    end
  end


  ##############################
  ##   HSL  INITIALIZATION    ##
  ##############################

  describe "initialized from a 3-Array" do
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

  describe "initialized from a 4-Array" do
    before(:each) do
      @h, @s, @l = $colors[:ruby][:hsl]
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @color = ColorHSL.new( [@h, @s, @l, @a] )
    end

    it_should_behave_like "ColorHSL (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB" do
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

  describe "initialized from a ColorRGB255" do
    before(:each) do
      @source = ColorRGB255.new( $colors[:ruby][:rgb255] + [128] )
      @color  = ColorHSL.new( @source )
      @h, @s, @l = 0.0000, 0.7500, 0.2510
      @r, @g, @b = 0.4392, 0.0627, 0.0627
      @a = 0.5
    end

    it_should_behave_like "ColorHSL (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSV" do
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

  describe "initialized from a ColorHSL" do
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


  ##############################
  #         HSL  EQL?          #
  ##############################

  describe "(eql?)" do

    before :each do
      @color1 = ColorHSL.new( $colors[:ruby][:hsl] + [0.5] )
    end

    it "should eql? itself" do
      @color1.should eql(@color1)
    end

    it "should eql? an equivalent ColorHSL" do
      @color2 = ColorHSL.new( $colors[:ruby][:hsl] + [0.5] )
      @color1.should eql(@color2)
    end

    it "should not eql? a different ColorHSL" do
      @color1.should_not eql( ColorHSL.new([0.1, 0.2, 0.3, 0.4]) )
    end

    it "should not eql? an Array with same numbers" do
      @color1.should_not eql( @color1.to_ary )
    end

    it "should not eql? a Array with different numbers" do
      @color1.should_not eql( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should not eql? an equivalent ColorRGB" do
      @color1.should_not eql( ColorRGB.new(@color1) )
    end

    it "should not eql? a ColorRGB with same numbers" do
      @color1.should_not eql( ColorRGB.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorRGB255" do
      @color1.should_not eql( ColorRGB255.new(@color1) )
    end

    it "should not eql? a ColorRGB255 with same numbers" do
      @color1.should_not eql( ColorRGB255.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSV" do
      @color1.should_not eql( ColorHSV.new(@color1) )
    end

    it "should not eql? a ColorHSV with same numbers" do
      @color1.should_not eql( ColorHSV.new(@color1.to_ary) )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not eql? #{inv.inspect}" do
        @color1.should_not eql( inv )
      end
    end

  end

  
  ##############################
  #           HSL ==           #
  ##############################

  describe "(==)" do

    before :each do
      @color1 = ColorHSL.new( $colors[:ruby][:hsl] + [0.5] )
    end

    it "should == an equivalent ColorHSL" do
      @color2 = ColorHSL.new( $colors[:ruby][:hsl] + [0.5] )
      @color1.should == @color2
    end

    it "should not == a different ColorHSL" do
      @color1.should_not == ColorHSL.new( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should == an Array with same numbers" do
      @color1.should == @color1.to_ary
    end

    it "should not == a Array with different numbers" do
      @color1.should_not == [0.1, 0.2, 0.3, 0.4]
    end

    it "should == an equivalent ColorRGB" do
      @color1.should == ColorRGB.new( @color1 )
    end

    it "should not == a ColorRGB with same numbers" do
      @color1.should_not == ColorRGB.new( @color1.to_ary )
    end

    it "should == an equivalent ColorRGB255" do
      @color1 = @klass.new( ColorRGB255.new(@color1) )
      @color1.should == ColorRGB255.new( @color1 )
    end

    it "should not == a ColorRGB255 with same numbers" do
      @color1.should_not == ColorRGB255.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSV" do
      @color1.should == ColorHSV.new( @color1 )
    end

    it "should not == a ColorHSV with same numbers" do
      @color1.should_not == ColorHSV.new( @color1.to_ary )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not == #{inv.inspect}" do
        @color1.should_not == inv
      end
    end

  end

end



describe "ColorRGB255" do

  before :each do
    @klass = ColorRGB255
  end


  ##############################
  ##  RGB255  SHARED  SPECS   ##
  ##############################

  shared_examples_for "ColorRGB255 (shared)" do 
    it "should have a 'r' (red) component which is a Fixnum" do
      @color.should respond_to(:r)
      @color.r.should be_instance_of( Fixnum )
    end

    it "should have a 'g' (green) component which is a Fixnum" do
      @color.should respond_to(:g)
      @color.g.should be_instance_of( Fixnum )
    end

    it "should have a 'b' (blue) component which is a Fixnum" do
      @color.should respond_to(:b)
      @color.b.should be_instance_of( Fixnum )
    end

    it "should have a 'a' (alpha) component which is a Fixnum" do
      @color.should respond_to(:a)
      @color.a.should be_instance_of( Fixnum )
    end

    it "should have the expected red component" do
      @color.r.should == @r255
    end

    it "should have the expected green component" do
      @color.g.should == @g255
    end

    it "should have the expected blue component" do
      @color.b.should == @b255
    end

    it "should have the expected alpha component" do
      @color.a.should == @a255
    end

  end

  ##############################
  ##  RGB255  INITIALIZATION  ##
  ##############################

  describe "initialized from a 3-Array" do
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 255
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 1.0
      @color = ColorRGB255.new( [@r255, @g255, @b255] )
    end

    it "should have full opacity" do 
      @color.a.should == 255
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a 4-Array" do
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 128
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5
      @color = ColorRGB255.new( [@r255, @g255, @b255, @a255] )
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB" do 
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 128
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5

      @source = ColorRGB.new( $colors[:ruby][:rgb] + [@a] )
      @color  = ColorRGB255.new( @source )
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorRGB255" do
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 128
      @source = ColorRGB255.new( [@r255, @g255, @b255, @a255] )
      @color  = ColorRGB255.new( @source )
      @r, @g, @b, @a = @source.to_rgba_ary
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSV" do 
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 128
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5

      @source = ColorHSV.new( $colors[:ruby][:hsv] + [@a] )
      @color  = ColorRGB255.new( @source )
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "initialized from a ColorHSL" do 
    before(:each) do
      @r255, @g255, @b255 = $colors[:ruby][:rgb255]
      @a255 = 128
      @r, @g, @b = $colors[:ruby][:rgb]
      @a = 0.5

      @source = ColorHSL.new( $colors[:ruby][:hsl] + [@a] )
      @color  = ColorRGB255.new( @source )
    end

    it_should_behave_like "ColorRGB255 (shared)"
    it_should_behave_like "Color with RGBA array (shared)"

  end

  describe "#hex" do
    it 'should create a ColorRGB255 instance' do
      ColorRGB255.hex("#248").should be_instance_of(ColorRGB255)
    end

    it 'should understand "#rgb" strings' do
      ColorRGB255.hex("#248").should == [34, 68, 136, 255]
    end

    it 'should understand "rgb" strings' do
      ColorRGB255.hex("248").should == [34, 68, 136, 255]
    end

    it 'should understand "#rgba" strings' do
      ColorRGB255.hex("#248f").should == [34, 68, 136, 255]
    end

    it 'should understand "rgba" strings' do
      ColorRGB255.hex("248f").should == [34, 68, 136, 255]
    end

    it 'should understand "#rrggbb" strings' do
      ColorRGB255.hex("#214387").should == [33, 67, 135, 255]
    end

    it 'should understand "rrggbb" strings' do
      ColorRGB255.hex("214387").should == [33, 67, 135, 255]
    end

    it 'should understand "#rrggbbaa" strings' do
      ColorRGB255.hex("#214387fe").should == [33, 67, 135, 254]
    end

    it 'should understand "rrggbbaa" strings' do
      ColorRGB255.hex("214387fe").should == [33, 67, 135, 254]
    end

    it 'should ignore case' do
      ColorRGB255.hex("ABCDEF").should == ColorRGB255.hex("abcdef")
    end
    
    invalid = {
      "nil"         => nil,
      "true"        => true,
      "false"       => false,
      "an integer"  => 1234,
      "a float"     => 12.34,
      "an array"    => [1,2,3,4],
      "a hash"      => {1=>2, 3=>4},
      "some object" => Object.new,
      "a Color"     => ColorRGB.new([1,1,1,1])
    }

    invalid.each do |thing, value|
      it 'should fail when given #{thing}' do
        expect{ColorRGB255.hex(value)}.to raise_error
      end
    end
  end


  ##############################
  #        RGB255 EQL?         #
  ##############################

  describe "(eql?)" do

    before :each do
      @color1 = ColorRGB255.new( $colors[:ruby][:rgb255] + [0.5] )
    end

    it "should eql? itself" do
      @color1.should eql(@color1)
    end

    it "should eql? an equivalent ColorRGB255" do
      @color2 = ColorRGB255.new( $colors[:ruby][:rgb255] + [0.5] )
      @color1.should eql(@color2)
    end

    it "should not eql? a different ColorRGB255" do
      @color1.should_not eql( ColorRGB255.new([0.1, 0.2, 0.3, 0.4]) )
    end

    it "should not eql? an Array with same numbers" do
      @color1.should_not eql( @color1.to_ary )
    end

    it "should not eql? a Array with different numbers" do
      @color1.should_not eql( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should not eql? an equivalent ColorRGB" do
      @color1.should_not eql( ColorRGB.new(@color1) )
    end

    it "should not eql? a ColorRGB with same numbers" do
      @color1.should_not eql( ColorRGB.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSV" do
      @color1.should_not eql( ColorHSV.new(@color1) )
    end

    it "should not eql? a ColorHSV with same numbers" do
      @color1.should_not eql( ColorHSV.new(@color1.to_ary) )
    end

    it "should not eql? an equivalent ColorHSL" do
      @color1.should_not eql( ColorHSL.new(@color1) )
    end

    it "should not eql? a ColorHSL with same numbers" do
      @color1.should_not eql( ColorHSL.new(@color1.to_ary) )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not eql? #{inv.inspect}" do
        @color1.should_not eql( inv )
      end
    end

  end

  
  ##############################
  #         RGB255 ==          #
  ##############################

  describe "(==)" do

    before :each do
      @color1 = ColorRGB255.new( $colors[:ruby][:rgb255] + [0.5] )
    end

    it "should == an equivalent ColorRGB255" do
      @color2 = ColorRGB255.new( $colors[:ruby][:rgb255] + [0.5] )
      @color1.should == @color2
    end

    it "should not == a different ColorRGB255" do
      @color1.should_not == ColorRGB255.new( [0.1, 0.2, 0.3, 0.4] )
    end

    it "should == an Array with same numbers" do
      @color1.should == @color1.to_ary
    end

    it "should not == a Array with different numbers" do
      @color1.should_not == [0.1, 0.2, 0.3, 0.4]
    end

    it "should == an equivalent ColorRGB" do
      @color1.should == ColorRGB.new( @color1 )
    end

    it "should not == a ColorRGB with same numbers" do
      @color1.should_not == ColorRGB.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSV" do
      @color1.should == ColorHSV.new( @color1 )
    end

    it "should not == a ColorHSV with same numbers" do
      @color1.should_not == ColorHSV.new( @color1.to_ary )
    end

    it "should == an equivalent ColorHSL" do
      @color1.should == ColorHSL.new( @color1 )
    end

    it "should not == a ColorHSL with same numbers" do
      @color1.should_not == ColorHSL.new( @color1.to_ary )
    end

    invalid = [ 1, 2.0, [], [1], [1,2], {}, nil, true, false ]
    invalid.each do |inv|
      it "should not == #{inv.inspect}" do
        @color1.should_not == inv
      end
    end

  end


end
