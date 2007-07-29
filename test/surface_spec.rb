# This is mostly for regression testing and bugfix confirmation at the moment.

require 'rubygame'
include Rubygame

context "A Surface being created (with a Screen available)" do
  setup do
    @screen = Screen.new([100,100])
  end

  teardown do
    Rubygame.quit
  end

  specify "should raise TypeError when #new size is not an Array" do
    lambda {
      Surface.new("not an array")
    }.should raise_error(TypeError)
  end

  specify "should raise ArgumentError when #new size is an Array of non-Numerics" do
    lambda {
      Surface.new(["not", "numeric", "members"])
    }.should raise_error(TypeError)
  end

  specify "should raise ArgumentError when #new size is too short" do
    lambda {
      Surface.new([1])
    }.should raise_error(ArgumentError)
  end
end

# Maybe an overly-broad context?
context "An existing Surface" do
  setup do
    @screen = Screen.new([100,100])
    @surface = Surface.new([100,100])
  end

  teardown do
    Rubygame.quit
  end

  specify "should raise TypeError when #blit target is not a Surface" do
    lambda {
      @surface.blit("not a surface", [0,0])
    }.should raise_error(TypeError)
  end

  specify "should raise TypeError when #blit dest is not an Array" do
    lambda {
      @surface.blit(@screen, "foo")
    }.should raise_error(TypeError)
  end

  specify "should raise TypeError when #blit src is not an Array" do
    lambda { 
      @surface.blit(@screen, [0,0], "foo")
    }.should raise_error(TypeError)
  end

  specify "should raise TypeError when #fill color is not an Array" do
    lambda {
      @surface.fill("not_an_array")
    }.should raise_error(TypeError)
  end

  specify "should raise TypeError when #fill color is an Array of non-Numerics" do
    lambda {
      @surface.fill(["non", "numeric", "members"])
    }.should raise_error(TypeError)
  end

  specify "should raise ArgumentError when #fill color is too short" do
    lambda {
      @surface.fill([0xff, 0xff])
    }.should raise_error(TypeError)
  end

  specify "should raise TypeError when #fill color is not an Array" do
    lambda {
      @surface.fill([0xff, 0xff, 0xff], "not_an_array")
    }.should raise_error(TypeError)
  end
end
