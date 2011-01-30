

require 'rubygame/ftor'
include Rubygame



describe Ftor do
  
  describe ".new_from_to" do
    it "should accept two Ftors" do
      lambda {
        Ftor.new_from_to( Ftor.new(0,0), Ftor.new(2,0) )
      }.should_not raise_error
    end

    it "should accept two Arrays" do
      lambda {
        Ftor.new_from_to( [0,0], [2,0] )
      }.should_not raise_error
    end

    it "should create an Ftor connecting the points" do
      f = Ftor.new_from_to([2,-4],[10,3])
      f.x.should == 8
      f.y.should == 7
    end
  end

end
