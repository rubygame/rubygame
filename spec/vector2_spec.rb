
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )


require 'rubygame/vector2'
include Rubygame


Spec::Matchers.define :be_nearly_equal do |number2|
  match do |number1|
    (number1 - number2).abs <= 1E-10
  end
end


describe Vector2 do

  before :each do
    @v1 = Vector2.new(1,2)
    @v2 = Vector2.new(3,-4)
  end

  describe "(components)" do

    it "should have an x component" do
      @v1.x.should == 1
    end

    it "should have a y component" do
      @v1.y.should == 2
    end

    it "should store x and y as floats" do
      @v1.x.should be_instance_of(Float)
      @v1.x.should be_instance_of(Float)
    end

    it "x should be writable" do
      @v1.x = 2
      @v1.x.should == 2
    end

    it "x should not be writable if frozen" do
      @v1.freeze
      lambda{ @v1.x = 2 }.should raise_error
    end

    it "y should be writable" do
      @v1.y = 3
      @v1.y.should == 3
    end

    it "y should not be writable if frozen" do
      @v1.freeze
      lambda{ @v1.y = 3 }.should raise_error
    end

  end


  describe "(conversions)" do

    it "should be convertible to array (to_ary)" do
      @v1.to_ary.should == [1.0, 2.0]
    end

    it "should be convertible to array (to_a)" do
      @v1.to_a.should == [1.0, 2.0]
    end

  end


  describe "(constructors)" do

    it "should have a square brackets constructor" do
      Vector2[1,2].should be_instance_of(Vector2)
    end

    it "should have a polar constructor (radians)" do
      n = 0.707106781186548
      @v = Vector2.new_am(Math::PI * 0.25, 1.0)
      @v.x.should be_nearly_equal(n)
      @v.y.should be_nearly_equal(n)
    end

    it "should have a polar constructor (degrees)" do
      n = 0.707106781186548
      @v = Vector2.new_dam(45, 1.0)
      @v.x.should be_nearly_equal(n)
      @v.y.should be_nearly_equal(n)
    end

    it "should have an en masse constructor" do
      arrays = [[1,2], [3,4], [5,6]]
      vectors = Vector2.many( *arrays )

      vectors.each_with_index { |vector,i|
        vector.should be_instance_of(Vector2)
        vector.x.should == arrays[i][0]
        vector.y.should == arrays[i][1]
      }
    end

  end


  describe "(math)" do

    it "should have an addition operator" do
      result = @v1 + @v2
      result.should be_instance_of(Vector2)
      result.to_ary.should == [4,-2]
    end

    it "should have a subtraction operator" do
      result = @v1 - @v2
      result.should be_instance_of(Vector2)
      result.to_ary.should == [-2,6]
    end

    it "should have a negation operator" do
      result = -(@v2)
      result.should be_instance_of(Vector2)
      result.to_ary.should == [-3,4]
    end

    it "should have a scalar multiplication operator" do
      result = @v1 * 3
      result.should be_instance_of(Vector2)
      result.to_ary.should == [3,6]
    end

    it "should have an equality operator" do
      @v1.should == Vector2.new(1,2)
    end

  end


  it "should have an index operator (brackets)" do
    @v1[0].should == 1
    @v1[1].should == 2
  end

  it "should have an index operator (at)" do
    @v1.at(0).should == 1
    @v1.at(1).should == 2
  end


  it "should have an each method" do
    a = []
    proc{ @v1.each{ |n| a << n } }.should_not raise_error
    a.should == [@v1.x, @v1.y]
  end

  it "should be enumerable" do
    Vector2.included_modules.should include(Enumerable)
  end


  describe "#angle" do

    it "should return the vector's angle in radians" do
      Vector2.new(1,1).angle.should be_nearly_equal(Math::PI*0.25)
    end

    it "should be writable" do
      @v1.angle = 1.234
      @v1.angle.should be_nearly_equal(1.234)
    end

    it "should not be writable when frozen" do
      @v1.freeze
      lambda{ @v1.angle = 1.234 }.should raise_error
    end

    it "should retain magnitude when changing angle" do
      orig_mag = @v1.magnitude
      @v1.angle = 1.234
      @v1.magnitude.should be_nearly_equal(orig_mag)
    end

  end

  describe "#dangle" do

    it "should return the vector's angle in degrees" do
      Vector2.new(1,1).dangle.should == 45
    end

    it "should be writable" do
      @v1.dangle = 1.234
      @v1.dangle.should be_nearly_equal(1.234)
    end

    it "should not be writable when frozen" do
      @v1.freeze
      lambda{ @v1.dangle = 1.234 }.should raise_error
    end

    it "should retain magnitude when changing angle" do
      orig_mag = @v1.magnitude
      @v1.dangle = 1.234
      @v1.magnitude.should be_nearly_equal(orig_mag)
    end

  end


  it "should have an angle with another vector (radians)" do
    @v1.angle_with(@v2).should be_nearly_equal(2.0344439357957)
  end

  it "should have an angle with another vector (degrees)" do
    @v1.dangle_with(@v2).should be_nearly_equal(116.565051177078)
  end


  describe "#magnitude" do

    it "should return the vector's magnitude" do
      @v2.magnitude.should be_nearly_equal(5)
    end

    it "should be writable" do
      @v1.magnitude = 1.234
      @v1.magnitude.should be_nearly_equal(1.234)
    end

    it "should not be writable when frozen" do
      @v1.freeze
      lambda{ @v1.magnitude = 1.234 }.should raise_error(RuntimeError)
    end

    it "should retain angle when changing magnitude" do
      orig_angle = @v1.angle
      @v1.magnitude = 1.234
      @v1.angle.should be_nearly_equal(orig_angle)
    end

  end


  it "should have a dot product operator" do
    @v1.dot(@v2).should == (1*3 + 2*(-4))
  end


  it "should have a perpendicular vector" do
    @v1.perp.should == Vector2.new(-2,1)
  end


  ################
  # PROJECT_ONTO #
  ################

  describe "#projected_onto" do
    it "should perform vector projection onto another vector" do
      @v1.projected_onto(@v2).should == Vector2.new(-0.6, 0.8)
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.projected_onto(@v2)
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.projected_onto(@v2).should_not equal(@v1)
    end
  end


  describe "#project_onto!" do
    it "should perform vector projection onto another vector" do
      @v1.project_onto!(@v2).should == Vector2.new(-0.6, 0.8)
    end

    it "should modify the caller" do
      @v1.project_onto!(@v2)
      @v1.should == Vector2.new(-0.6, 0.8)
    end

    it "should return the caller" do
      @v1.project_onto!(@v2).should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.project_onto!(@v2) }.should raise_error
    end
  end


  ###########
  # REVERSE #
  ###########


  describe "#reverse" do
    it "should reverse the vector's direction" do
      @v1.reverse.should == Vector2.new(-1, -2)
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.reverse
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.reverse.should_not equal(@v1)
    end
  end


  describe "#reverse!" do
    it "should reverse the vector's direction" do
      @v1.reverse!.should == Vector2.new(-1, -2)
    end

    it "should modify the caller" do
      @v1.reverse!
      @v1.should == Vector2.new(-1, -2)
    end

    it "should return the caller" do
      @v1.reverse!.should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.reverse! }.should raise_error
    end
  end


  ##########
  # ROTATE #
  ##########

  describe "#rotate" do
    it "should perform rotation (in radians)" do
      expected = Vector2.new_am(@v1.angle + 0.2, @v1.magnitude)
      @v1.rotate(0.2).should == expected
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.rotate(0.2)
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.rotate(0.2).should_not equal(@v1)
    end
  end


  describe "#rotate!" do
    it "should perform rotation (in radians)" do
      expected = Vector2.new_am(@v1.angle + 0.2, @v1.magnitude)
      @v1.rotate!(0.2).should == expected
    end

    it "should modify the caller" do
      expected = Vector2.new_am(@v1.angle + 0.2, @v1.magnitude)
      @v1.rotate!(0.2)
      @v1.should == expected
    end

    it "should return the caller" do
      @v1.rotate!(0.2).should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.rotate!(0.2) }.should raise_error
    end
  end


  ###########
  # DROTATE #
  ###########

  describe "#drotate" do
    it "should perform rotation (in degrees)" do
      expected = Vector2.new_dam(@v1.dangle + 30, @v1.magnitude)
      @v1.drotate(30).should == expected
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.drotate(30)
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.drotate(30).should_not equal(@v1)
    end
  end


  describe "#drotate!" do
    it "should perform rotation (in degrees)" do
      expected = Vector2.new_dam(@v1.dangle + 30, @v1.magnitude)
      @v1.drotate!(30).should == expected
    end

    it "should modify the caller" do
      expected = Vector2.new_dam(@v1.dangle + 30, @v1.magnitude)
      @v1.drotate!(30)
      @v1.should == expected
    end

    it "should return the caller" do
      @v1.drotate!(30).should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.drotate!(30) }.should raise_error
    end
  end


  ###########
  # STRETCH #
  ###########

  describe "#stretch" do
    it "should perform non-uniform scaling" do
      @v1.stretch(3,-4).should == Vector2.new(3,-8)
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.stretch(3,-4)
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.stretch(3,-4).should_not equal(@v1)
    end
  end


  describe "#stretch!" do
    it "should perform non-uniform scaling" do
      @v1.stretch!(3,-4).should == Vector2.new(3,-8)
    end

    it "should modify the caller" do
      @v1.stretch!(3,-4)
      @v1.should == Vector2.new(3,-8)
    end

    it "should return the caller" do
      @v1.stretch!(3,-4).should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.stretch!(3,-4) }.should raise_error
    end
  end


  ########
  # UNIT #
  ########

  describe "#unit" do
    it "should calculate a unit vector" do
      u = @v1.unit
      u.magnitude.should == 1.0
      u.angle.should == @v1.angle
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.unit
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.unit.should_not equal(@v1)
    end
  end


  # Alias for #unit
  describe "#normalized" do
    it "should calculate a unit vector" do
      u = @v1.normalized
      u.magnitude.should == 1.0
      u.angle.should == @v1.angle
    end

    it "should not modify the caller" do
      v1_orig = @v1.dup
      @v1.normalized
      @v1.should == v1_orig
    end

    it "should return a new object" do
      @v1.normalized.should_not equal(@v1)
    end
  end


  describe "#unit!" do
    it "should calculate a unit vector" do
      u = @v1.unit!
      u.magnitude.should == 1.0
      u.angle.should == @v1.angle
    end

    it "should not modify the caller" do
      orig_angle = @v1.angle
      @v1.unit!
      @v1.magnitude.should == 1.0
      @v1.angle.should == orig_angle
    end

    it "should return the caller" do
      @v1.unit!.should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.unit! }.should raise_error
    end
  end


  # Alias for #unit!
  describe "#normalize!" do
    it "should calculate a unit vector" do
      u = @v1.normalize!
      u.magnitude.should == 1.0
      u.angle.should == @v1.angle
    end

    it "should not modify the caller" do
      orig_angle = @v1.angle
      @v1.normalize!
      @v1.magnitude.should == 1.0
      @v1.angle.should == orig_angle
    end

    it "should return the caller" do
      @v1.normalize!.should equal(@v1)
    end

    it "should raise error if frozen" do
      @v1.freeze
      lambda{ @v1.normalize! }.should raise_error
    end
  end


  ########
  # UDOT #
  ########

  it "should have a unit dot product operator" do
    @v1.udot(@v2).should == @v1.unit.dot(@v2.unit)
  end


end
