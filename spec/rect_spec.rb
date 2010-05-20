# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )


require 'rubygame/new_rect'
include Rubygame


describe Rect do


  describe "new" do

    it "should accept 4 integers" do
      r = Rect.new(1,2,3,4)
      r.x.should.eql?( 1 )
      r.y.should.eql?( 2 )
      r.w.should.eql?( 3 )
      r.h.should.eql?( 4 )
    end

    it "should accept an array of 4 integers" do
      r = Rect.new([1,2,3,4])
      r.x.should.eql?( 1 )
      r.y.should.eql?( 2 )
      r.w.should.eql?( 3 )
      r.h.should.eql?( 4 )
    end

    it "should accept 4 floats" do
      r = Rect.new(1.5, 2.5, 3.5, 4.5)
      r.x.should.eql?( 1.5 )
      r.y.should.eql?( 2.5 )
      r.w.should.eql?( 3.5 )
      r.h.should.eql?( 4.5 ) 
    end

    it "should accept an array of 4 floats" do
      r = Rect.new([1.5, 2.5, 3.5, 4.5])
      r.x.should.eql?( 1.5 )
      r.y.should.eql?( 2.5 )
      r.w.should.eql?( 3.5 )
      r.h.should.eql?( 4.5 ) 
    end

    it "should accept 2 arrays of 2 integers" do
      r = Rect.new([1,2],[3,4])
      r.x.should.eql?( 1 )
      r.y.should.eql?( 2 )
      r.w.should.eql?( 3 )
      r.h.should.eql?( 4 )
    end

    it "should accept 2 arrays of 2 floats" do
      r = Rect.new([1.5, 2.5], [3.5, 4.5])
      r.x.should.eql?( 1.5 )
      r.y.should.eql?( 2.5 )
      r.w.should.eql?( 3.5 )
      r.h.should.eql?( 4.5 ) 
    end

    it "should accept another Rect" do
      r = Rect.new( Rect.new([1,2,3,4]) )
      r.x.should.eql?( 1 )
      r.y.should.eql?( 2 )
      r.w.should.eql?( 3 )
      r.h.should.eql?( 4 )
    end

    it "should accept an object with a rect method" do
      ob = mock(:rect => Rect.new(1,2,3,4))
      r = Rect.new( ob )
      r.x.should.eql?( 1 )
      r.y.should.eql?( 2 )
      r.w.should.eql?( 3 )
      r.h.should.eql?( 4 )
    end


    it "should not accept zero args" do
      proc{ Rect.new }.should raise_error(ArgumentError)
    end

    it "should not accept more than 4 args" do
      proc{ Rect.new(1,2,3,4,5) }.should raise_error(ArgumentError)
    end

  end



  it "to_ary should return [x,y,w,h]" do
    Rect.new(1,2,3,4).to_ary.should == [1,2,3,4]
  end

  it "to_a should return [x,y,w,h]" do
    Rect.new(1,2,3,4).to_a.should == [1,2,3,4]
  end



  describe "at" do

    it "0 should return x" do
      Rect.new(1,2,3,4).at(0).should == 1
    end

    it "1 should return y" do
      Rect.new(1,2,3,4).at(1).should == 2
    end

    it "2 should return w" do
      Rect.new(1,2,3,4).at(2).should == 3
    end

    it "3 should return h" do
      Rect.new(1,2,3,4).at(3).should == 4
    end

  end


  describe "[]" do

    it "0 should return x" do
      Rect.new(1,2,3,4)[0].should == 1
    end

    it "1 should return y" do
      Rect.new(1,2,3,4)[1].should == 2
    end

    it "2 should return w" do
      Rect.new(1,2,3,4)[2].should == 3
    end

    it "3 should return h" do
      Rect.new(1,2,3,4)[3].should == 4
    end

  end


  describe "[]=" do

    it "0 should set x" do
      r = Rect.new(1,2,3,4)
      r[0] = 9
      r.x.should == 9
    end

    it "1 should set y" do
      r = Rect.new(1,2,3,4)
      r[1] = 9
      r.y.should == 9
    end

    it "2 should set w" do
      r = Rect.new(1,2,3,4)
      r[2] = 9
      r.w.should == 9
    end

    it "3 should set h" do
      r = Rect.new(1,2,3,4)
      r[3] = 9
      r.h.should == 9
    end

  end




  it "should be enumerable" do
    Rect.new(1,2,3,4).should be_kind_of(Enumerable)
  end


  describe "each" do
    it "should iterate over [x,y,w,h]" do
      a = []
      Rect.new(1,2,3,4).each{ |i| a << i }
      a.should == [1,2,3,4]
    end
  end

  describe "collect" do
    it "should iterate over [x,y,w,h]" do
      Rect.new(1,2,3,4).collect{|i| -i}.should == [-1,-2,-3,-4]
    end

    it "should return an Array" do
      Rect.new(1,2,3,4).collect{|i| -i}.should be_instance_of(Array)
    end
  end

  describe "collect!" do
    it "collect! should modify the caller" do
      r = Rect.new(1,2,3,4)
      r.collect!{|i| -i}
      r.to_ary.should == [-1,-2,-3,-4]
    end
  end

  # Alias of collect!
  describe "map!" do
    it "map! should modify the caller" do
      r = Rect.new(1,2,3,4)
      r.collect!{|i| -i}
      r.to_ary.should == [-1,-2,-3,-4]
    end
  end




  describe "x" do

    it "should be the first number" do
      Rect.new(1,2,3,4).x.should == 1
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.x = 9
      r.x.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.x = 9 }.should raise_error
    end

  end


  describe "y" do

    it "should be the second number" do
      Rect.new(1,2,3,4).y.should == 2
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.y = 9
      r.y.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.y = 9 }.should raise_error
    end

  end


  describe "w" do

    it "should be the third number" do
      Rect.new(1,2,3,4).w.should == 3
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.w = 9
      r.w.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.w = 9 }.should raise_error
    end

    it "should have a width alias" do
      Rect.new(1,2,3,4).width.should == 3
    end

    it "should have a width writer" do
      r = Rect.new(1,2,3,4)
      r.width = 9
      r.w.should == 9
    end

    it "width write should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.width = 9 }.should raise_error
    end

  end


  describe "h" do

    it "should be the fourth number" do
      Rect.new(1,2,3,4).h.should == 4
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.h = 9
      r.h.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.h = 9 }.should raise_error
    end

    it "should have a height alias" do
      Rect.new(1,2,3,4).height.should == 4
    end

    it "should have a height writer" do
      r = Rect.new(1,2,3,4)
      r.height = 9
      r.h.should == 9
    end

    it "height writer should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.height = 9 }.should raise_error
    end

  end




  describe "left" do

    it "should be the same as x" do
      Rect.new(1,2,3,4).left.should == 1
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.left = 9
      r.left.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.left = 9 }.should raise_error
    end

    it "should change x when set" do
      r = Rect.new(1,2,3,4)
      r.left = 9
      r.x.should == 9
    end

    it "should not change w when set" do
      r = Rect.new(1,2,3,4)
      r.left = 9
      r.w.should == 3
    end

    it "should have an alias l" do
      Rect.new(1,2,3,4).l.should == 1
    end

    it "l should be writable" do
      r = Rect.new(1,2,3,4)
      r.l = 9
      r.l.should == 9
    end

    it "l should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.l = 9 }.should raise_error
    end

    it "l should change x when set" do
      r = Rect.new(1,2,3,4)
      r.l = 9
      r.x.should == 9
    end

    it "l should not change w when set" do
      r = Rect.new(1,2,3,4)
      r.l = 9
      r.w.should == 3
    end

  end


  describe "top" do

    it "should be the same as y" do
      Rect.new(1,2,3,4).top.should == 2
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.top = 9
      r.top.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.top = 9 }.should raise_error
    end

    it "should change y when set" do
      r = Rect.new(1,2,3,4)
      r.top = 9
      r.y.should == 9
    end

    it "should not change h when set" do
      r = Rect.new(1,2,3,4)
      r.top = 9
      r.h.should == 4
    end

    it "should have an alias t" do
      Rect.new(1,2,3,4).t.should == 2
    end

    it "t should be writable" do
      r = Rect.new(1,2,3,4)
      r.t = 9
      r.t.should == 9
    end

    it "t should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.t = 9 }.should raise_error
    end

    it "t should change y when set" do
      r = Rect.new(1,2,3,4)
      r.t = 9
      r.y.should == 9
    end

    it "should not change h when set" do
      r = Rect.new(1,2,3,4)
      r.t = 9
      r.h.should == 4
    end

  end


  describe "right" do

    it "should be the same as x+w" do
      Rect.new(1,2,10,4).right.should == 11
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.right = 9
      r.right.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.right = 9 }.should raise_error
    end

    it "should change x when set" do
      r = Rect.new(1,2,3,4)
      r.right = 9
      r.x.should == 6
    end

    it "should not change w when set" do
      r = Rect.new(1,2,3,4)
      r.right = 9
      r.w.should == 3
    end

    it "should have an alias r" do
      Rect.new(1,2,10,4).r.should == 11
    end

    it "r should be writable" do
      r = Rect.new(1,2,3,4)
      r.r = 9
      r.r.should == 9
    end

    it "r should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.r = 9 }.should raise_error
    end

    it "r should change x when set" do
      r = Rect.new(1,2,3,4)
      r.r = 9
      r.x.should == 6
    end

    it "r should not change w when set" do
      r = Rect.new(1,2,3,4)
      r.r = 9
      r.w.should == 3
    end

  end


  describe "bottom" do

    it "should be the same as y+h" do
      Rect.new(1,2,3,10).bottom.should == 12
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.bottom = 9
      r.bottom.should == 9
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.bottom = 9 }.should raise_error
    end

    it "should change y when set" do
      r = Rect.new(1,2,3,4)
      r.bottom = 9
      r.y.should == 5
    end

    it "should not change h when set" do
      r = Rect.new(1,2,3,4)
      r.right = 9
      r.h.should == 4
    end

    it "should have an alias b" do
      Rect.new(1,2,3,10).b.should == 12
    end

    it "b should be writable" do
      r = Rect.new(1,2,3,4)
      r.b = 9
      r.b.should == 9
    end

    it "b should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.b = 9 }.should raise_error
    end

    it "b should change x when set" do
      r = Rect.new(1,2,3,4)
      r.b = 9
      r.y.should == 5
    end

    it "b should not change h when set" do
      r = Rect.new(1,2,3,4)
      r.b = 9
      r.h.should == 4
    end

  end




  describe "a method that takes one rect-like", :shared => true do

    it "should not raise when given a valid rect" do
      r1 = Rect.new(1,2,3,4)
      r2 = Rect.new(5,6,7,8)
      proc{ r1.send(@method, r2) }.should_not raise_error(TypeError)
    end

    it "should not raise when given a valid Array" do
      r = Rect.new(1,2,3,4)
      a = [5,6,7,8]
      proc{ r.send(@method, a) }.should_not raise_error(TypeError)
    end

    it "should not raise when given an non-normal rect" do
      r1 = Rect.new(1,2,3,4)
      r2 = Rect.new(5,6,-7,-8)
      proc{ r1.send(@method, r2) }.should_not raise_error(TypeError)
    end

    it "should not raise when given an object with a valid rect" do
      r = Rect.new(1,2,3,4)
      o = mock(:rect => Rect.new(5,6,7,8))
      proc{ r.send(@method, o) }.should_not raise_error(TypeError)
    end

    it "should not raise when given an object with a valid Array" do
      r = Rect.new(1,2,3,4)
      o = mock(:rect => [5,6,7,8])
      proc{ r.send(@method, o) }.should_not raise_error(TypeError)
    end

    it "should raise TypeError when given a bad type" do
      r = Rect.new(1,2,3,4)
      proc{ r.send(@method, nil  ) }.should raise_error(TypeError)
      proc{ r.send(@method, true ) }.should raise_error(TypeError)
      proc{ r.send(@method, false) }.should raise_error(TypeError)
      proc{ r.send(@method, "a"  ) }.should raise_error(TypeError)
      proc{ r.send(@method, :a   ) }.should raise_error(TypeError)
      proc{ r.send(@method, {}   ) }.should raise_error(TypeError)
    end

    it "should raise ArgumentError when given a bad Array" do
      r = Rect.new(1,2,3,4)
      proc{ r.send(@method,[])          }.should raise_error(ArgumentError)
      proc{ r.send(@method,[1])         }.should raise_error(ArgumentError)
      proc{ r.send(@method,[1,2,3])     }.should raise_error(ArgumentError)
      proc{ r.send(@method,[1,2,3,"4"]) }.should raise_error(ArgumentError)
    end

    it "should raise ArgumentError if given zero args" do
      r = Rect.new(1,2,3,4)
      proc{ r.send(@method) }.should raise_error(ArgumentError)
    end
    
    it "should raise ArgumentError if given more than one arg" do
      r = Rect.new(1,2,3,4)
      proc{ r.send(@method, 1, 2) }.should raise_error(ArgumentError)
    end

  end




  describe "clamp" do

    before :each do
      @method = :clamp
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should not modify the caller" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2)
      r1.to_ary.should == [0,1,10,15]
    end

    it "should not change the size" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).size.should == r1.size
    end

    it "should move right to be inside the other rect" do
      r1 = Rect.new(0,42,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [70,42,10,15]
    end

    it "should move left to be inside the other rect" do
      r1 = Rect.new(100,42,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [80,42,10,15]
    end

    it "should move down to be inside the other rect" do
      r1 = Rect.new(72,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [72,40,10,15]
    end

    it "should move up to be inside the other rect" do
      r1 = Rect.new(72,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [72,55,10,15]
    end

    it "should move right-down to be inside the other rect" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [70,40,10,15]
    end

    it "should move left-down to be inside the other rect" do
      r1 = Rect.new(100,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [80,40,10,15]
    end

    it "should move right-up to be inside the other rect" do
      r1 = Rect.new(0,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [70,55,10,15]
    end

    it "should move left-up to be inside the other rect" do
      r1 = Rect.new(100,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [80,55,10,15]
    end

    it "should be centered on X if too wide" do
      r1 = Rect.new(0,1,30,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [65,40,30,15]
    end

    it "should be centered on Y if too tall" do
      r1 = Rect.new(0,1,10,40)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [70,35,10,40]
    end

    it "should be centered on X and Y if too wide and tall" do
      r1 = Rect.new(0,1,30,40)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should == [65,35,30,40]
    end

    it "should have no effect if already inside the other rect" do
      r1 = Rect.new(70,40,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).should == r1
    end

  end


  describe "clamp!" do

    before :each do
      @method = :clamp!
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should modify the caller" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp!(r2)
      r1.to_ary.should == [70,40,10,15]
    end

    it "should return self" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp!(r2).should.eql?(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.clamp!(r2) }.should raise_error
      r1.to_ary.should == [1,2,3,4]
    end

  end




  describe "clip" do

    before :each do
      @method = :clip
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should not modify the caller" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2)
      r1.to_ary.should == [65,35,10,15]
    end

    it "should clip this rect to only the part inside the other rect" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should == [70,40,5,10]
    end

    it "should be clipped to the other rect if contained by this rect" do
      r1 = Rect.new(65,35,30,40)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should == [70,40,20,30]
    end

    it "should have no effect if contained by the other rect" do
      r1 = Rect.new(70,40,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).should == r1
    end

    it "should set size to zero if they don't overlap" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should == [0,1,0,0]
    end

    it "should normalize the rect" do
      r1 = Rect.new(80,55,-10,-15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should == [70,40,10,15]
    end

  end


  describe "clip!" do

    before :each do
      @method = :clip!
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should modify the caller" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip!(r2)
      r1.to_ary.should == [70,40,5,10]
    end

    it "should return self" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip!(r2).should.eql?(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.clip!(r2) }.should raise_error
      r1.to_ary.should == [1,2,3,4]
    end

  end




  describe "collide_point?" do

    it "should accept 2 numbers" do
      r = Rect.new(1,2,3,4)
      proc{ r.collide_point?(1,2) }.should_not raise_error
    end

    it "should raise ArgumentError if given zero args" do
      r = Rect.new(1,2,3,4)
      proc{ r.collide_point? }.should raise_error(ArgumentError)
    end

    it "should raise ArgumentError if given one arg" do
      r = Rect.new(1,2,3,4)
      proc{ r.collide_point?(1) }.should raise_error(ArgumentError)
    end

    it "should raise ArgumentError if given more than two args" do
      r = Rect.new(1,2,3,4)
      proc{ r.collide_point?(1,2,3) }.should raise_error(ArgumentError)
    end

    it "should raise error if given non-numbers" do
      r = Rect.new(1,2,3,4)
      proc{ r.collide_point?(nil,nil) }.should raise_error
      proc{ r.collide_point?("a","b") }.should raise_error
      proc{ r.collide_point?([1],[2]) }.should raise_error
    end


    it "should be false if the point is left of the rect" do
      Rect.new(1,2,3,4).collide_point?(0.99,4).should be_false
    end

    it "should be false if the point is right of the rect" do
      Rect.new(1,2,3,4).collide_point?(4.01,4).should be_false
    end

    it "should be false if the point is above the rect" do
      Rect.new(1,2,3,4).collide_point?(2,1.99).should be_false
    end

    it "should be false if the point is below the rect" do
      Rect.new(1,2,3,4).collide_point?(2,6.01).should be_false
    end


    it "should be false if the point is left and above the rect" do
      Rect.new(1,2,3,4).collide_point?(0.99,1.99).should be_false
    end

    it "should be false if the point is right and above the rect" do
      Rect.new(1,2,3,4).collide_point?(4.01,1.99).should be_false
    end

    it "should be false if the point is left and below the rect" do
      Rect.new(1,2,3,4).collide_point?(0.99,6.01).should be_false
    end

    it "should be false if the point is right and below the rect" do
      Rect.new(1,2,3,4).collide_point?(4.01,6.01).should be_false
    end


    it "should be true if the point is on rect's left edge" do
      Rect.new(1,2,3,4).collide_point?(1,4).should be_true
    end

    it "should be true if the point is on rect's right edge" do
      Rect.new(1,2,3,4).collide_point?(4,4).should be_true
    end

    it "should be true if the point is on rect's top edge" do
      Rect.new(1,2,3,4).collide_point?(2,2).should be_true
    end

    it "should be true if the point is on rect's bottom edge" do
      Rect.new(1,2,3,4).collide_point?(2,6).should be_true
    end


    it "should be true if the point is on rect's top left corner" do
      Rect.new(1,2,3,4).collide_point?(1,2).should be_true
    end

    it "should be true if the point is on rect's top right corner" do
      Rect.new(1,2,3,4).collide_point?(4,2).should be_true
    end

    it "should be true if the point is on rect's bottom left corner" do
      Rect.new(1,2,3,4).collide_point?(1,6).should be_true
    end

    it "should be true if the point is on rect's bottom right corner" do
      Rect.new(1,2,3,4).collide_point?(4,6).should be_true
    end


    it "should be true if the point is inside the rect" do
      Rect.new(1,2,3,4).collide_point?(2,4).should be_true
    end
    
  end




  describe "contain?" do

    before :each do
      @method = :contain?
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should be false when the rects don't overlap at all" do
      r1 = Rect.new(10,10,20,20)
      r2 = Rect.new(50,50,10,10)
      r1.contain?(r2).should be_false
    end
    
    it "should be false when the rects partially overlap" do
      r1 = Rect.new(10,10,20,20)
      r2 = Rect.new(9,9,10,10)
      r1.contain?(r2).should be_false
    end
    
    it "should be false when the other rect contains this rect" do
      r1 = Rect.new(15,15,10,10)
      r2 = Rect.new(10,10,20,20)
      r1.contain?(r2).should be_false
    end
    
    it "should be true when this rect contains the other rect" do
      r1 = Rect.new(10,10,20,20)
      r2 = Rect.new(15,15,10,10)
      r1.contain?(r2).should be_true
    end
    
    it "should be true even if the other rect is right on the border" do
      r1 = Rect.new(10,10,20,20)
      r2 = Rect.new(10,10,10,10)
      r1.contain?(r2).should be_true
    end
    
    it "should be true when the rects are equal" do
      r1 = Rect.new(10,10,20,20)
      r2 = Rect.new(10,10,20,20)
      r1.contain?(r2).should be_true
    end

  end




  describe "move" do

    it "should not modify the caller" do
      r = Rect.new(65,35,10,15)
      r.move(1,2)
      r.to_ary.should == [65,35,10,15]
    end

    it "should change x" do
      r = Rect.new(65,35,10,15)
      r.move(5,0).to_ary.should == [70,35,10,15]
    end

    it "should change y" do
      r = Rect.new(65,35,10,15)
      r.move(0,10).to_ary.should == [65,45,10,15]
    end

    it "should change x and y" do
      r = Rect.new(65,35,10,15)
      r.move(5,10).to_ary.should == [70,45,10,15]
    end

    it "should work with negative numbers" do
      r = Rect.new(65,35,10,15)
      r.move(-5,-10).to_ary.should == [60,25,10,15]
    end

    it "should not normalize the result" do
      r = Rect.new(65,35,-10,-15)
      r.move(-5,-10).to_ary.should == [60,25,-10,-15]
    end

    it "should raise error if given zero args" do
      r = Rect.new(1,2,3,4)
      proc{ r.move() }.should raise_error
    end

    it "should raise error if given one arg" do
      r = Rect.new(1,2,3,4)
      proc{ r.move(1) }.should raise_error
    end

    it "should raise error if given more than two args" do
      r = Rect.new(1,2,3,4)
      proc{ r.move(1,2,3) }.should raise_error
    end

  end


  describe "move!" do

    it "should modify the caller" do
      r = Rect.new(65,35,10,15)
      r.move!(1,2)
      r.to_ary.should == [66,37,10,15]
    end

    it "should return self" do
      r = Rect.new(65,35,10,15)
      r.move!(1,2).should.eql?(r)
    end

  end




  describe "normalize" do

    it "should not modify the caller" do
      r = Rect.new(65,35,-10,-15)
      r.normalize
      r.to_ary.should == [65,35,-10,-15]
    end

    it "should correct negative width" do
      r = Rect.new(65,35,-10,15)
      r.normalize.to_ary.should == [55,35,10,15]
    end

    it "should correct negative height" do
      r = Rect.new(65,35,10,-15)
      r.normalize.to_ary.should == [65,20,10,15]
    end

    it "should correct negative width and height" do
      r = Rect.new(65,35,-10,-15)
      r.normalize.to_ary.should == [55,20,10,15]
    end

    it "should have no effect if width and height are not negative" do
      r = Rect.new(65,35,10,15)
      r.normalize.should == r
    end

  end


  describe "normalize!" do

    it "should modify the caller" do
      r = Rect.new(65,35,-10,-15)
      r.normalize!
      r.to_ary.should == [55,20,10,15]
    end

    it "should return self" do
      r1 = Rect.new(65,35,10,15)
      r1.normalize!.should.eql? r1
    end

    it "should raise an error and fail if frozen" do
      r = Rect.new(1,2,-3,-4).freeze
      proc{ r.normalize! }.should raise_error
      r.to_ary.should == [1,2,-3,-4]
    end

  end




  describe "union" do

    before :each do
      @method = :union
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should not modify the caller" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.union(r2)
      r1.to_ary.should == [0,1,10,15]
    end

    it "should expand right to contain the other rect" do
      r1 = Rect.new(20,40,10,30)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 20
      r3.t.should == 40
      r3.r.should == 90
      r3.b.should == 70
    end

    it "should expand left to contain the other rect" do
      r1 = Rect.new(90,40,10,30)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 70
      r3.t.should == 40
      r3.r.should == 100
      r3.b.should == 70
    end

    it "should expand down to contain the other rect" do
      r1 = Rect.new(70,10,20,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 70
      r3.t.should == 10
      r3.r.should == 90
      r3.b.should == 70
    end

    it "should expand up to contain the other rect" do
      r1 = Rect.new(70,90,20,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 70
      r3.t.should == 40
      r3.r.should == 90
      r3.b.should == 100
    end

    it "should expand right-down to contain the other rect" do
      r1 = Rect.new(20,10,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 20
      r3.t.should == 10
      r3.r.should == 90
      r3.b.should == 70
    end

    it "should expand left-down to contain the other rect" do
      r1 = Rect.new(90,10,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 70
      r3.t.should == 10
      r3.r.should == 100
      r3.b.should == 70
    end

    it "should expand right-up to contain the other rect" do
      r1 = Rect.new(20,90,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 20
      r3.t.should == 40
      r3.r.should == 90
      r3.b.should == 100
    end

    it "should expand left-up to contain the other rect" do
      r1 = Rect.new(90,90,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.l.should == 70
      r3.t.should == 40
      r3.r.should == 100
      r3.b.should == 100
    end

    it "should expand to the other rect if it contains this rect" do
      r1 = Rect.new(70,40,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.union(r2).should == r2
    end

    it "should have no effect if it already contains the other rect" do
      r1 = Rect.new(70,40,10,15)
      r2 = Rect.new(70,40,20,30)
      r2.union(r1).should == r2
    end

    it "should normalize the rect" do
      r1 = Rect.new(80,55,-20,-25)
      r2 = Rect.new(70,40,20,30)
      r1.union(r2).to_ary.should == [60,30,30,40]
    end

  end


  describe "union!" do

    before :each do
      @method = :union!
    end

    it_should_behave_like "a method that takes one rect-like"

    it "should modify the caller" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.union!(r2)
      r1.to_ary.should == [0,1,90,69]
    end

    it "should return self" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.union!(r2).should.eql?(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.union!(r2) }.should raise_error
      r1.to_ary.should == [1,2,3,4]
    end

  end



end
