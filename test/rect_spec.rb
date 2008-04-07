
require 'rubygame'
include Rubygame


describe Rect, "(new)" do
  it "can be created from an Array of 4 numerics" do
    r = Rect.new([1,2,3,4])
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from another Rect" do
    base = Rect.new([1,2,3,4])
    r = Rect.new( base )
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from two Arrays of 2 numerics" do
    r = Rect.new([1,2],[3,4])
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from 4 Numerics" do
    r = Rect.new(1,2,3,4)
    r.to_ary.should == [1,2,3,4]
  end
end


describe Rect, "(new_from_object)" do
  it "can be created from an Array of 4 numerics" do
    r = Rect.new_from_object( [1,2,3,4] )
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from another Rect" do
    base = Rect.new([1,2,3,4])
    r = Rect.new_from_object( base )
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from an Object whose #rect is a Rect" do
    m = mock( "rect", :rect => Rect.new([1,2,3,4]) )
    r = Rect.new_from_object( m )
    r.to_ary.should == [1,2,3,4]
  end

  it "can be created from an Object whose #rect is an Array of 4 numerics" do
    m = mock( "rect", :rect => [1,2,3,4] )
    r = Rect.new_from_object( m )
    r.to_ary.should == [1,2,3,4]
  end
end



describe Rect, "(attribute readers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have an x attribute reader" do
    @rect.x.should == 1
  end

  it "should have a y attribute reader" do
    @rect.y.should == 2
  end

  it "should have a w attribute reader" do
    @rect.w.should == 3
  end

  it "should have a width attribute reader" do
    @rect.width.should == 3
  end

  it "should have an h attribute reader" do
    @rect.h.should == 4
  end

  it "should have a height attribute reader" do
    @rect.height.should == 4
  end

  it "should have an [] reader" do
    @rect[0].should == 1
    @rect[1].should == 2
    @rect[2].should == 3
    @rect[3].should == 4
  end

  it "should have a size reader" do
    @rect.size.should == [3,4]
  end
end


describe Rect, "(attribute writers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have an x attribute writer" do
    @rect.x = 11
    @rect.x.should == 11
  end

  it "should have a y attribute writer" do
    @rect.y = 12
    @rect.y.should == 12
  end

  it "should have a w attribute writer" do
    @rect.w = 13
    @rect.w.should == 13
  end

  it "should have a width attribute writer" do
    @rect.width = 13
    @rect.width.should == 13
  end

  it "should have an h attribute writer" do
    @rect.h = 14
    @rect.h.should == 14
  end

  it "should have a height attribute writer" do
    @rect.height = 14
    @rect.height.should == 14
  end

  it "should have an [] writer" do
    @rect[0] = 11
    @rect[1] = 12
    @rect[2] = 13
    @rect[3] = 14
    @rect.to_ary.should == [11,12,13,14]
  end

  it "should have a size writer" do
    @rect.size = [13,14]
    @rect.size.should == [13,14]
  end
end



describe Rect, "(side readers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a left side" do
    @rect.left.should == 1
  end

  it "should have a right side" do
    @rect.right.should == 1+3
  end

  it "should have a top side" do
    @rect.top.should == 2
  end

  it "should have a bottom side" do
    @rect.bottom.should == 2+4
  end
end


describe Rect, "(side writers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a left side writer" do
    @rect.left = 11
    @rect.left.should == 11
    @rect.x.should == 11
  end

  it "writing left side should not change width" do
    @rect.left = 11
    @rect.width.should == 3
  end

  it "should have a right side writer" do
    @rect.right = 23
    @rect.right.should == 23
    @rect.x.should == 20
  end

  it "writing right side should not change width" do
    @rect.right = 23
    @rect.width.should == 3
  end

  it "should have a top side writer" do
    @rect.top = 12
    @rect.top.should == 12
    @rect.y.should == 12
  end

  it "writing top side should not change height" do
    @rect.top = 12
    @rect.height.should == 4
  end

  it "should have a bottom side writer" do
    @rect.bottom = 24
    @rect.bottom.should == 24
    @rect.y.should == 20
  end

  it "writing bottom side should not change height" do
    @rect.bottom = 24
    @rect.height.should == 4
  end
end



describe Rect, "(center readers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a center reader" do
    @rect.center.should == [2,4]
  end

  it "should have a centerx reader" do
    @rect.centerx.should == 2
  end

  it "should have a centery reader" do
    @rect.centery.should == 4
  end
end


describe Rect, "(center writers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a center writer" do
    @rect.center = [12,14]
    @rect.center.should == [12,14]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "should have a centerx writer" do
    @rect.centerx = 12
    @rect.centerx.should == 12
    @rect.x.should == 11
  end

  it "should have a centery writer" do
    @rect.centery = 14
    @rect.centery.should == 14
    @rect.y.should == 12
  end
end



describe Rect, "(corner readers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a topleft reader" do
    @rect.topleft.should == [1,2]
  end

  it "should have a topright reader" do
    @rect.topright.should == [1+3,2]
  end

  it "should have a bottomleft reader" do
    @rect.bottomleft.should == [1,2+4]
  end

  it "should have a bottomright reader" do
    @rect.bottomright.should == [1+3,2+4]
  end
end


describe Rect, "(corner writers)" do
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a topleft writer" do
    @rect.topleft = [11,12]
    @rect.topleft.should == [11,12]
    @rect.x.should == 11
    @rect.y.should == 12
  end
  
  it "writing topleft should not change size" do 
    @rect.topleft = [11,12]
    @rect.size.should == [3,4]
  end

  it "should have a topright writer" do
    @rect.topright = [14,12]
    @rect.topright.should == [14,12]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing topright should not change size" do 
    @rect.topright = [14,12]
    @rect.size.should == [3,4]
  end

  it "should have a bottomleft writer" do
    @rect.bottomleft = [11,16]
    @rect.bottomleft.should == [11,16]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing bottomleft should not change size" do 
    @rect.bottomleft = [11,16]
    @rect.size.should == [3,4]
  end

  it "should have a bottomright writer" do
    @rect.bottomright = [14,16]
    @rect.bottomright.should == [14,16]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing bottomright should not change size" do 
    @rect.bottomright = [14,16]
    @rect.size.should == [3,4]
  end
end



describe Rect, "(midpoint readers)" do 
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a midleft reader" do 
    @rect.midleft.should == [1,4]
  end

  it "should have a midright reader" do 
    @rect.midright.should == [4,4]
  end

  it "should have a midtop reader" do 
    @rect.midtop.should == [2,2]
  end

  it "should have a midbottom reader" do 
    @rect.midbottom.should == [2,6]
  end
end


describe Rect, "(midpoint writers)" do 
  before(:each) do
    @rect = Rect.new([1,2,3,4])
  end

  it "should have a midleft writer" do 
    @rect.midleft = [11,14]
    @rect.midleft.should == [11,14]
    @rect.x.should == 11
    @rect.y.should == 12
  end
  
  it "writing midleft should not change size" do 
    @rect.midleft = [11,14]
    @rect.size.should == [3,4]
  end

  it "should have a midright writer" do 
    @rect.midright = [14,14]
    @rect.midright.should == [14,14]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing midright should not change size" do 
    @rect.midright = [14,14]
    @rect.size.should == [3,4]
  end

  it "should have a midtop writer" do 
    @rect.midtop = [12,12]
    @rect.midtop.should == [12,12]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing midtop should not change size" do 
    @rect.midtop = [12,12]
    @rect.size.should == [3,4]
  end

  it "should have a midbottom writer" do 
    @rect.midbottom = [12,16]
    @rect.midbottom.should == [12,16]
    @rect.x.should == 11
    @rect.y.should == 12
  end

  it "writing midbottom should not change size" do 
    @rect.midbottom = [12,16]
    @rect.size.should == [3,4]
  end
end
