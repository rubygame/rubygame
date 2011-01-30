

require 'rubygame/vector2'
require 'rubygame/new_rect'
include Rubygame



describe Rect do


  shared_examples_for "initializer (shared)" do

    it "should accept 4 integers" do
      r = Rect.send(@method,1,2,3,4)
      r.x.should eql( 1.0 )
      r.y.should eql( 2.0 )
      r.w.should eql( 3.0 )
      r.h.should eql( 4.0 )
    end

    it "should accept an array of 4 integers" do
      r = Rect.send(@method,[1,2,3,4])
      r.x.should eql( 1.0 )
      r.y.should eql( 2.0 )
      r.w.should eql( 3.0 )
      r.h.should eql( 4.0 )
    end

    it "should accept 4 floats" do
      r = Rect.send(@method,1.5, 2.5, 3.5, 4.5)
      r.x.should eql( 1.5 )
      r.y.should eql( 2.5 )
      r.w.should eql( 3.5 )
      r.h.should eql( 4.5 ) 
    end

    it "should accept an array of 4 floats" do
      r = Rect.send(@method,[1.5, 2.5, 3.5, 4.5])
      r.x.should eql( 1.5 )
      r.y.should eql( 2.5 )
      r.w.should eql( 3.5 )
      r.h.should eql( 4.5 ) 
    end

    it "should accept 2 arrays of 2 integers" do
      r = Rect.send(@method,[1,2],[3,4])
      r.x.should eql( 1.0 )
      r.y.should eql( 2.0 )
      r.w.should eql( 3.0 )
      r.h.should eql( 4.0 )
    end

    it "should accept 2 arrays of 2 floats" do
      r = Rect.send(@method,[1.5, 2.5], [3.5, 4.5])
      r.x.should eql( 1.5 )
      r.y.should eql( 2.5 )
      r.w.should eql( 3.5 )
      r.h.should eql( 4.5 ) 
    end

    it "should accept another Rect" do
      r = Rect.send(@method, Rect.send(@method,[1,2,3,4]) )
      r.x.should eql( 1.0 )
      r.y.should eql( 2.0 )
      r.w.should eql( 3.0 )
      r.h.should eql( 4.0 )
    end

    it "should accept an object with a rect method" do
      ob = mock(:rect => Rect.send(@method,1,2,3,4))
      r = Rect.send(@method, ob )
      r.x.should eql( 1.0 )
      r.y.should eql( 2.0 )
      r.w.should eql( 3.0 )
      r.h.should eql( 4.0 )
    end


    it "should not accept zero args" do
      proc{ Rect.new }.should raise_error(ArgumentError)
    end

    it "should not accept more than 4 args" do
      proc{ Rect.send(@method,1,2,3,4,5) }.should raise_error(ArgumentError)
    end

  end


  describe "new" do
    before :each do
      @method = :new
    end

    it_should_behave_like "initializer (shared)"
  end


  describe "Rect[]" do
    before :each do
      @method = :[]
    end

    it_should_behave_like "initializer (shared)"
  end



  it "to_ary should return [x,y,w,h]" do
    Rect.new(1,2,3,4).to_ary.should eql([1.0,2.0,3.0,4.0])
  end

  it "to_a should return [x,y,w,h]" do
    Rect.new(1,2,3,4).to_a.should eql([1.0,2.0,3.0,4.0])
  end



  describe "at" do

    it "0 should return x" do
      Rect.new(1,2,3,4).at(0).should eql(1.0)
    end

    it "1 should return y" do
      Rect.new(1,2,3,4).at(1).should eql(2.0)
    end

    it "2 should return w" do
      Rect.new(1,2,3,4).at(2).should eql(3.0)
    end

    it "3 should return h" do
      Rect.new(1,2,3,4).at(3).should eql(4.0)
    end

  end


  describe "[]" do

    it "0 should return x" do
      Rect.new(1,2,3,4)[0].should eql(1.0)
    end

    it "1 should return y" do
      Rect.new(1,2,3,4)[1].should eql(2.0)
    end

    it "2 should return w" do
      Rect.new(1,2,3,4)[2].should eql(3.0)
    end

    it "3 should return h" do
      Rect.new(1,2,3,4)[3].should eql(4.0)
    end

  end


  describe "[]=" do

    it "0 should set x" do
      r = Rect.new(1,2,3,4)
      r[0] = 9
      r.x.should eql(9.0)
    end

    it "1 should set y" do
      r = Rect.new(1,2,3,4)
      r[1] = 9
      r.y.should eql(9.0)
    end

    it "2 should set w" do
      r = Rect.new(1,2,3,4)
      r[2] = 9
      r.w.should eql(9.0)
    end

    it "3 should set h" do
      r = Rect.new(1,2,3,4)
      r[3] = 9
      r.h.should eql(9.0)
    end

  end




  it "should be enumerable" do
    Rect.new(1,2,3,4).should be_kind_of(Enumerable)
  end


  describe "each" do
    it "should iterate over [x,y,w,h]" do
      a = []
      Rect.new(1,2,3,4).each{ |i| a << i }
      a.should eql([1.0,2.0,3.0,4.0])
    end
  end

  describe "collect" do
    it "should iterate over [x,y,w,h]" do
      Rect.new(1,2,3,4).collect{|i| -i}.should eql([-1.0,-2.0,-3.0,-4.0])
    end

    it "should return an Array" do
      Rect.new(1,2,3,4).collect{|i| -i}.should be_instance_of(Array)
    end
  end

  describe "collect!" do
    it "collect! should modify the caller" do
      r = Rect.new(1,2,3,4)
      r.collect!{|i| -i}
      r.to_ary.should eql([-1.0,-2.0,-3.0,-4.0])
    end
  end

  # Alias of collect!
  describe "map!" do
    it "map! should modify the caller" do
      r = Rect.new(1,2,3,4)
      r.collect!{|i| -i}
      r.to_ary.should eql([-1.0,-2.0,-3.0,-4.0])
    end
  end




  describe "x" do

    it "should be the first number" do
      Rect.new(1,2,3,4).x.should eql(1.0)
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.x = 9
      r.x.should eql(9.0)
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.x = 9 }.should raise_error
    end

  end


  describe "y" do

    it "should be the second number" do
      Rect.new(1,2,3,4).y.should eql(2.0)
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.y = 9
      r.y.should eql(9.0)
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.y = 9 }.should raise_error
    end

  end


  describe "w" do

    it "should be the third number" do
      Rect.new(1,2,3,4).w.should eql(3.0)
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.w = 9
      r.w.should eql(9.0)
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.w = 9 }.should raise_error
    end

    it "should have a width alias" do
      Rect.new(1,2,3,4).width.should eql(3.0)
    end

    it "should have a width writer" do
      r = Rect.new(1,2,3,4)
      r.width = 9
      r.w.should eql(9.0)
    end

    it "width write should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.width = 9 }.should raise_error
    end

  end


  describe "h" do

    it "should be the fourth number" do
      Rect.new(1,2,3,4).h.should eql(4.0)
    end

    it "should be writable" do
      r = Rect.new(1,2,3,4)
      r.h = 9
      r.h.should eql(9.0)
    end

    it "should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.h = 9 }.should raise_error
    end

    it "should have a height alias" do
      Rect.new(1,2,3,4).height.should eql(4.0)
    end

    it "should have a height writer" do
      r = Rect.new(1,2,3,4)
      r.height = 9
      r.h.should eql(9.0)
    end

    it "height writer should not be writable if frozen" do
      r = Rect.new(1,2,3,4).freeze
      proc{ r.height = 9 }.should raise_error
    end

  end




  it "left should be x" do
    Rect.new(1,2,3,4).left.should eql(1.0)
  end

  it "top should be y" do
    Rect.new(1,2,3,4).top.should eql(2.0)
  end

  it "right should be x+w" do
    Rect.new(1,2,10,4).right.should eql(11.0)
  end

  it "bottom should be y+h" do
    Rect.new(1,2,3,10).bottom.should eql(12.0)
  end

  it "centerx should be x+w/2" do
    Rect.new(1,2,3,4).centerx.should eql(2.5)
  end

  it "centery should be x+w/2" do
    Rect.new(1,2,3,5).centery.should eql(4.5)
  end


  it "center should be Vector2[centerx,centery]" do
    Rect.new(1,2,4,8).center.should be_a( Vector2 )
    Rect.new(1,2,4,8).center.should == Vector2[3.0,6.0]
  end

  it "topleft should be Vector2[left,top]" do
    Rect.new(1,2,4,8).topleft.should be_a( Vector2 )
    Rect.new(1,2,4,8).topleft.should == Vector2[1.0,2.0]
  end

  it "topright should be Vector2[right,top]" do
    Rect.new(1,2,4,8).topright.should be_a( Vector2 )
    Rect.new(1,2,4,8).topright.should == Vector2[5.0,2.0]
  end

  it "bottomleft should be Vector2[left,bottom]" do
    Rect.new(1,2,4,8).bottomleft.should be_a( Vector2 )
    Rect.new(1,2,4,8).bottomleft.should == Vector2[1.0,10.0]
  end

  it "bottomright should be Vector2[right,bottom]" do
    Rect.new(1,2,4,8).bottomright.should be_a( Vector2 )
    Rect.new(1,2,4,8).bottomright.should == Vector2[5.0,10.0]
  end

  it "midleft should be Vector2[left,centery]" do
    Rect.new(1,2,4,8).midleft.should be_a( Vector2 )
    Rect.new(1,2,4,8).midleft.should == Vector2[1.0,6.0]
  end

  it "midright should be Vector2[right,centery]" do
    Rect.new(1,2,4,8).midright.should be_a( Vector2 )
    Rect.new(1,2,4,8).midright.should == Vector2[5.0,6.0]
  end

  it "midtop should be Vector2[centerx,top]" do
    Rect.new(1,2,4,8).midtop.should be_a( Vector2 )
    Rect.new(1,2,4,8).midtop.should == Vector2[3.0,2.0]
  end

  it "midbottom should be Vector2[centerx,bottom]" do
    Rect.new(1,2,4,8).midbottom.should be_a( Vector2 )
    Rect.new(1,2,4,8).midbottom.should == Vector2[3.0,10.0]
  end



  shared_examples_for "align (shared)" do

    [:left, :top, :right, :bottom, :centerx, :centery].each do |edge|
      it "#{edge.inspect} should accept an integer" do
        lambda{ @r.send(@method, edge => 1) }.should_not raise_error
      end

      it "#{edge.inspect} should accept a float" do
        lambda{ @r.send(@method, edge => 1.0) }.should_not raise_error
      end

      it "#{edge.inspect} should not accept an array of integers" do
        lambda{
          @r.send(@method, edge => [1,2])
        }.should raise_error(TypeError)
      end

      it "#{edge.inspect} should not accept an array of floats" do
        lambda{
          @r.send(@method, edge => [1.0,2.0])
        }.should raise_error(TypeError)
      end

      it "#{edge.inspect} should not accept a Vector2" do
        lambda{
          @r.send(@method, edge => Vector2[1,2])
        }.should raise_error(TypeError)
      end
    end

    [:center, :topleft, :topright, :bottomleft, :bottomright,
     :midleft, :midright, :midtop, :midbottom].each do |point|
      it "#{point.inspect} not should accept an integer" do
        lambda{ @r.send(@method, point => 1) }.should raise_error(TypeError)
      end

      it "#{point.inspect} not should accept a float" do
        lambda{ @r.send(@method, point => 1.0) }.should raise_error(TypeError)
      end

      it "#{point.inspect} should accept an array of integers" do
        lambda{ @r.send(@method, point => [1,2]) }.should_not raise_error
      end

      it "#{point.inspect} should accept an array of floats" do
        lambda{ @r.send(@method, point => [1.0,2.0]) }.should_not raise_error
      end

      it "#{point.inspect} should accept a Vector2" do
        lambda{
          @r.send(@method, point => Vector2[1,2])
        }.should_not raise_error
      end
    end


    it "should raise ArgumentError for unknown points" do
      lambda{ @r.send(@method, :a => 1) }.should raise_error(ArgumentError)
    end

    it "should raise TypeError for invalid values" do
      ["foo", :foo, [], [1], {}, nil, true, Object.new].each do |val|
        lambda{
          @r.send(@method, :left => val)
        }.should raise_error(TypeError)
      end
    end


    [[:left,        10,       Rect.new(10,2,3,4)  ],
     [:top,         10,       Rect.new(1,10,3,4)  ],
     [:right,       10,       Rect.new(7,2,3,4)   ],
     [:bottom,      10,       Rect.new(1,6,3,4)   ],
     [:centerx,     10,       Rect.new(8.5,2,3,4) ],
     [:centery,     10,       Rect.new(1,8,3,4)   ],
     [:center,      [10,20],  Rect.new(8.5,18,3,4)],
     [:topleft,     [10,20],  Rect.new(10,20,3,4) ],
     [:topright,    [10,20],  Rect.new(7,20,3,4)  ],
     [:bottomleft,  [10,20],  Rect.new(10,16,3,4) ],
     [:bottomright, [10,20],  Rect.new(7,16,3,4)  ],
     [:midleft,     [10,20],  Rect.new(10,18,3,4) ],
     [:midright,    [10,20],  Rect.new(7,18,3,4)  ],
     [:midtop,      [10,20],  Rect.new(8.5,20,3,4)],
     [:midbottom,   [10,20],  Rect.new(8.5,16,3,4)],
    ].each do |sym, val, expected|
      it "should be able to align #{sym.inspect}" do
        @r.send(@method, sym => val).should == expected
      end

      if val.is_a? Array
        it "should accept a Vector2 for #{sym.inspect}" do
          @r.send(@method, sym => Vector2[*val]).should == expected
        end
      end
    end


    it "should work with zero args" do
      lambda{
        @r.send(@method).should == Rect.new(1,2,3,4)
      }.should_not raise_error
    end

    it "should work with a single Hash entry" do
      lambda{
        @r.send(@method, :left => 5).should == Rect.new(5,2,3,4)
      }.should_not raise_error
    end

    it "should work with multiple Hash entries" do
      lambda{
        @r.send(@method, :left => 5, :top => 4).should == Rect.new(5,4,3,4)
      }.should_not raise_error
    end

    it "should work with a single arg pair" do
      lambda{
        @r.send(@method, :left, 5).should == Rect.new(5,2,3,4)
      }.should_not raise_error
    end

    it "should work with multiple arg pairs" do
      lambda{
        @r.send(@method, :left, 5, :top, 4).should == Rect.new(5,4,3,4)
      }.should_not raise_error
    end

    it "should apply multiple arg pairs in order" do
      lambda{
        @r.send(@method, :left, 5, :right, 6).should == Rect.new(3,2,3,4)
      }.should_not raise_error
    end

  end


  describe "align" do
    before :each do
      @method = :align
      @r = Rect.new(1,2,3,4)
    end

    it_should_behave_like "align (shared)"

    it "should not modify self" do
      @r.align(:left => 5)
      @r.should == Rect.new(1,2,3,4)
    end
  end


  describe "align!" do
    before :each do
      @method = :align!
      @r = Rect.new(1,2,3,4)
    end

    it_should_behave_like "align (shared)"

    it "should modify self" do
      @r.align!(:left => 5)
      @r.should == Rect.new(5,2,3,4)
    end
  end




  shared_examples_for "a method that takes one rect-like" do

    it "should not raise when given a valid rect" do
      r1 = Rect.new(1,2,3,4)
      r2 = Rect.new(5,6,7,8)
      proc{ r1.send(@method, r2) }.should_not raise_error
    end

    it "should not raise when given a valid Array" do
      r = Rect.new(1,2,3,4)
      a = [5,6,7,8]
      proc{ r.send(@method, a) }.should_not raise_error
    end

    it "should not raise when given an non-normal rect" do
      r1 = Rect.new(1,2,3,4)
      r2 = Rect.new(5,6,-7,-8)
      proc{ r1.send(@method, r2) }.should_not raise_error
    end

    it "should not raise when given an object with a valid rect" do
      r = Rect.new(1,2,3,4)
      o = mock(:rect => Rect.new(5,6,7,8))
      proc{ r.send(@method, o) }.should_not raise_error
    end

    it "should not raise when given an object with a valid Array" do
      r = Rect.new(1,2,3,4)
      o = mock(:rect => [5,6,7,8])
      proc{ r.send(@method, o) }.should_not raise_error
    end

    it "should raise TypeError when given a bad type" do
      r = Rect.new(1,2,3,4)
      proc{ r.send(@method, nil  ) }.should raise_error(ArgumentError)
      proc{ r.send(@method, true ) }.should raise_error(ArgumentError)
      proc{ r.send(@method, false) }.should raise_error(ArgumentError)
      proc{ r.send(@method, "a"  ) }.should raise_error(ArgumentError)
      proc{ r.send(@method, :a   ) }.should raise_error(ArgumentError)
      proc{ r.send(@method, {}   ) }.should raise_error(ArgumentError)
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
      r1.to_ary.should eql([0.0, 1.0, 10.0, 15.0])
    end

    it "should not change the size" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).size.should == r1.size
    end

    it "should move right to be inside the other rect" do
      r1 = Rect.new(0,42,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([70.0, 42.0, 10.0, 15.0])
    end

    it "should move left to be inside the other rect" do
      r1 = Rect.new(100,42,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([80.0, 42.0, 10.0, 15.0])
    end

    it "should move down to be inside the other rect" do
      r1 = Rect.new(72,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([72.0, 40.0, 10.0, 15.0])
    end

    it "should move up to be inside the other rect" do
      r1 = Rect.new(72,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([72.0, 55.0, 10.0, 15.0])
    end

    it "should move right-down to be inside the other rect" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([70.0, 40.0, 10.0, 15.0])
    end

    it "should move left-down to be inside the other rect" do
      r1 = Rect.new(100,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([80.0, 40.0, 10.0, 15.0])
    end

    it "should move right-up to be inside the other rect" do
      r1 = Rect.new(0,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([70.0, 55.0, 10.0, 15.0])
    end

    it "should move left-up to be inside the other rect" do
      r1 = Rect.new(100,100,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([80.0, 55.0, 10.0, 15.0])
    end

    it "should be centered on X if too wide" do
      r1 = Rect.new(0,1,30,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([65.0, 40.0, 30.0, 15.0])
    end

    it "should be centered on Y if too tall" do
      r1 = Rect.new(0,1,10,40)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([70.0, 35.0, 10.0, 40.0])
    end

    it "should be centered on X and Y if too wide and tall" do
      r1 = Rect.new(0,1,30,40)
      r2 = Rect.new(70,40,20,30)
      r1.clamp(r2).to_ary.should eql([65.0, 35.0, 30.0, 40.0])
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
      r1.to_ary.should eql([70.0, 40.0, 10.0, 15.0])
    end

    it "should return self" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clamp!(r2).should equal(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.clamp!(r2) }.should raise_error
      r1.to_ary.should eql([1.0, 2.0, 3.0, 4.0])
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
      r1.to_ary.should eql([65.0, 35.0, 10.0, 15.0])
    end

    it "should clip this rect to only the part inside the other rect" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should eql([70.0, 40.0, 5.0, 10.0])
    end

    it "should be clipped to the other rect if contained by this rect" do
      r1 = Rect.new(65,35,30,40)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should eql([70.0, 40.0, 20.0, 30.0])
    end

    it "should have no effect if contained by the other rect" do
      r1 = Rect.new(70,40,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).should == r1
    end

    it "should set size to zero if they don't overlap" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should eql([0.0, 1.0, 0.0, 0.0])
    end

    it "should normalize the rect" do
      r1 = Rect.new(80,55,-10,-15)
      r2 = Rect.new(70,40,20,30)
      r1.clip(r2).to_ary.should eql([70.0, 40.0, 10.0, 15.0])
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
      r1.to_ary.should eql([70.0, 40.0, 5.0, 10.0])
    end

    it "should return self" do
      r1 = Rect.new(65,35,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.clip!(r2).should equal(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.clip!(r2) }.should raise_error
      r1.to_ary.should eql([1.0, 2.0, 3.0, 4.0])
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
      r.to_ary.should eql([65.0, 35.0, 10.0, 15.0])
    end

    it "should change x" do
      r = Rect.new(65,35,10,15)
      r.move(5,0).to_ary.should eql([70.0, 35.0, 10.0, 15.0])
    end

    it "should change y" do
      r = Rect.new(65,35,10,15)
      r.move(0,10).to_ary.should eql([65.0, 45.0, 10.0, 15.0])
    end

    it "should change x and y" do
      r = Rect.new(65,35,10,15)
      r.move(5,10).to_ary.should eql([70.0, 45.0, 10.0, 15.0])
    end

    it "should work with negative numbers" do
      r = Rect.new(65,35,10,15)
      r.move(-5,-10).to_ary.should eql([60.0, 25.0, 10.0, 15.0])
    end

    it "should not normalize the result" do
      r = Rect.new(65,35,-10,-15)
      r.move(-5,-10).to_ary.should eql([60.0, 25.0, -10.0, -15.0])
    end

    it "should accept an array of two numbers" do
      r = Rect.new(1,2,3,4)
      proc{ r.move([1,2]) }.should_not raise_error
    end

    it "should raise error if given zero args" do
      r = Rect.new(1,2,3,4)
      proc{ r.move() }.should raise_error
    end

    it "should raise error if given an array of one number" do
      r = Rect.new(1,2,3,4)
      proc{ r.move([1]) }.should raise_error
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
      r.to_ary.should eql([66.0, 37.0, 10.0, 15.0])
    end

    it "should return self" do
      r = Rect.new(65,35,10,15)
      r.move!(1,2).should equal(r)
    end

  end




  describe "normalize" do

    it "should not modify the caller" do
      r = Rect.new(65,35,-10,-15)
      r.normalize
      r.to_ary.should eql([65.0, 35.0, -10.0, -15.0])
    end

    it "should correct negative width" do
      r = Rect.new(65,35,-10,15)
      r.normalize.to_ary.should eql([55.0, 35.0, 10.0, 15.0])
    end

    it "should correct negative height" do
      r = Rect.new(65,35,10,-15)
      r.normalize.to_ary.should eql([65.0, 20.0, 10.0, 15.0])
    end

    it "should correct negative width and height" do
      r = Rect.new(65,35,-10,-15)
      r.normalize.to_ary.should eql([55.0, 20.0, 10.0, 15.0])
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
      r.to_ary.should eql([55.0, 20.0, 10.0, 15.0])
    end

    it "should return self" do
      r1 = Rect.new(65,35,10,15)
      r1.normalize!.should equal(r1)
    end

    it "should raise an error and fail if frozen" do
      r = Rect.new(1,2,-3,-4).freeze
      proc{ r.normalize! }.should raise_error
      r.to_ary.should eql([1.0, 2.0, -3.0, -4.0])
    end

  end




  shared_examples_for "stretch (shared)" do

    [:left, :top, :right, :bottom].each do |edge|
      it "#{edge.inspect} should accept an integer" do
        lambda{ @r.send(@method, edge => 1) }.should_not raise_error
      end

      it "#{edge.inspect} should accept a float" do
        lambda{ @r.send(@method, edge => 1.0) }.should_not raise_error
      end

      it "#{edge.inspect} should not accept an array of integers" do
        lambda{
          @r.send(@method, edge => [1,2])
        }.should raise_error(TypeError)
      end

      it "#{edge.inspect} should not accept an array of floats" do
        lambda{
          @r.send(@method, edge => [1.0,2.0])
        }.should raise_error(TypeError)
      end

      it "#{edge.inspect} should not accept a Vector2" do
        lambda{
          @r.send(@method, edge => Vector2[1,2])
        }.should raise_error(TypeError)
      end
    end

    [:topleft, :topright, :bottomleft, :bottomright].each do |point|
      it "#{point.inspect} not should accept an integer" do
        lambda{ @r.send(@method, point => 1) }.should raise_error(TypeError)
      end

      it "#{point.inspect} not should accept a float" do
        lambda{ @r.send(@method, point => 1.0) }.should raise_error(TypeError)
      end

      it "#{point.inspect} should accept an array of integers" do
        lambda{ @r.send(@method, point => [1,2]) }.should_not raise_error
      end

      it "#{point.inspect} should accept an array of floats" do
        lambda{ @r.send(@method, point => [1.0,2.0]) }.should_not raise_error
      end

      it "#{point.inspect} should accept a Vector2" do
        lambda{
          @r.send(@method, point => Vector2[1,2])
        }.should_not raise_error
      end
    end


    [:centerx, :centery].each do |edge|
      it "should raise ArgumentError for #{edge.inspect}" do
        lambda{
          @r.send(@method, edge => 1)
        }.should raise_error(ArgumentError)
      end
    end

    [:center, :midleft, :midright, :midtop, :midbottom].each do |point|
      it "should raise ArgumentError for #{point.inspect}" do
        lambda{
          @r.send(@method, point => [1,2])
        }.should raise_error(ArgumentError)
      end
    end

    it "should raise ArgumentError for unknown points" do
      lambda{ @r.send(@method, :a => 1) }.should raise_error(ArgumentError)
    end

    it "should raise TypeError for invalid values" do
      ["foo", :foo, [], [1], {}, nil, true, Object.new].each do |val|
        lambda{
          @r.send(@method, :left => val)
        }.should raise_error(TypeError)
      end
    end


    [[:left,        -10,        Rect.new(-10,2,14,4)   ],
     [:top,         -10,        Rect.new(1,-10,3,16)   ],
     [:right,       10,         Rect.new(1,2,9,4)      ],
     [:bottom,      10,         Rect.new(1,2,3,8)      ],
     [:topleft,     [-10,-20],  Rect.new(-10,-20,14,26)],
     [:topright,    [ 10,-20],  Rect.new(1,-20,9,26)   ],
     [:bottomleft,  [-10, 20],  Rect.new(-10,2,14,18)  ],
     [:bottomright, [ 10, 20],  Rect.new(1,2,9,18)     ],
    ].each do |sym, val, expected|
      it "should be able to stretch #{sym.inspect}" do
        @r.send(@method, sym => val).should == expected
      end

      if val.is_a? Array
        it "should accept a Vector2 for #{sym.inspect}" do
          @r.send(@method, sym => Vector2[*val]).should == expected
        end
      end
    end


    it "should work with zero args" do
      lambda{
        @r.send(@method).should == Rect.new(1,2,3,4)
      }.should_not raise_error
    end

    it "should work with a single Hash entry" do
      lambda{
        @r.send(@method, :left => -10).should == Rect.new(-10,2,14,4)
      }.should_not raise_error
    end

    it "should work with multiple Hash entries" do
      lambda{
        @r.send(@method, :left => -10, :top => -20).
          should == Rect.new(-10,-20,14,26)
      }.should_not raise_error
    end

    it "should work with a single arg pair" do
      lambda{
        @r.send(@method, :left, -10).should == Rect.new(-10,2,14,4)
      }.should_not raise_error
    end

    it "should work with multiple arg pairs" do
      lambda{
        @r.send(@method, :left, -10, :top, -20).
          should == Rect.new(-10,-20,14,26)
      }.should_not raise_error
    end

    it "should apply multiple arg pairs in order" do
      lambda{
        @r.send(@method, :left, -10, :topleft, [-20,-10]).
          should == Rect.new(-20,-10,24,16)
      }.should_not raise_error
    end

  end


  describe "stretch" do
    before :each do
      @method = :stretch
      @r = Rect.new(1,2,3,4)
    end

    it_should_behave_like "stretch (shared)"

    it "should not modify self" do
      @r.stretch(:left => 5)
      @r.should == Rect.new(1,2,3,4)
    end
  end


  describe "stretch!" do
    before :each do
      @method = :stretch!
      @r = Rect.new(1,2,3,4)
    end

    it_should_behave_like "stretch (shared)"

    it "should modify self" do
      @r.stretch!(:left => -10)
      @r.should == Rect.new(-10,2,14,4)
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
      r1.to_ary.should eql([0.0, 1.0, 10.0, 15.0])
    end

    it "should expand right to contain the other rect" do
      r1 = Rect.new(20,40,10,30)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(20.0)
      r3.top.should eql(40.0)
      r3.right.should eql(90.0)
      r3.bottom.should eql(70.0)
    end

    it "should expand left to contain the other rect" do
      r1 = Rect.new(90,40,10,30)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(70.0)
      r3.top.should eql(40.0)
      r3.right.should eql(100.0)
      r3.bottom.should eql(70.0)
    end

    it "should expand down to contain the other rect" do
      r1 = Rect.new(70,10,20,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(70.0)
      r3.top.should eql(10.0)
      r3.right.should eql(90.0)
      r3.bottom.should eql(70.0)
    end

    it "should expand up to contain the other rect" do
      r1 = Rect.new(70,90,20,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(70.0)
      r3.top.should eql(40.0)
      r3.right.should eql(90.0)
      r3.bottom.should eql(100.0)
    end

    it "should expand right-down to contain the other rect" do
      r1 = Rect.new(20,10,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(20.0)
      r3.top.should eql(10.0)
      r3.right.should eql(90.0)
      r3.bottom.should eql(70.0)
    end

    it "should expand left-down to contain the other rect" do
      r1 = Rect.new(90,10,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(70.0)
      r3.top.should eql(10.0)
      r3.right.should eql(100.0)
      r3.bottom.should eql(70.0)
    end

    it "should expand right-up to contain the other rect" do
      r1 = Rect.new(20,90,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(20.0)
      r3.top.should eql(40.0)
      r3.right.should eql(90.0)
      r3.bottom.should eql(100.0)
    end

    it "should expand left-up to contain the other rect" do
      r1 = Rect.new(90,90,10,10)
      r2 = Rect.new(70,40,20,30)
      r3 = r1.union(r2)
      r3.left.should eql(70.0)
      r3.top.should eql(40.0)
      r3.right.should eql(100.0)
      r3.bottom.should eql(100.0)
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
      r1.union(r2).to_ary.should eql([60.0, 30.0, 30.0, 40.0])
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
      r1.to_ary.should eql([0.0, 1.0, 90.0, 69.0])
    end

    it "should return self" do
      r1 = Rect.new(0,1,10,15)
      r2 = Rect.new(70,40,20,30)
      r1.union!(r2).should equal(r1)
    end

    it "should raise an error and fail if frozen" do
      r1 = Rect.new(1,2,3,4).freeze
      r2 = Rect.new(5,6,7,8)
      proc{ r1.union!(r2) }.should raise_error
      r1.to_ary.should eql([1.0, 2.0, 3.0, 4.0])
    end

  end



end
