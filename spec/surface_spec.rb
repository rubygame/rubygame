# This is mostly for regression testing and bugfix confirmation at the moment.


require 'rubygame'
include Rubygame


samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")
test_dir = File.join( File.dirname(__FILE__), "" )

test_image = test_dir + "image.png"
test_image_8bit = test_dir + "image_8bit.png"
not_image = test_dir + "short.ogg"
panda = samples_dir + "panda.png"
dne = test_dir + "does_not_exist.png"



describe Surface, "(creation)" do
  before(:each) do
    Rubygame.init()
    @screen = Screen.new([100,100])
  end

  after(:each) do
    Rubygame.quit()
  end

  it "should raise TypeError when #new size is not an Array" do
    lambda {
      Surface.new("not an array")
    }.should raise_error(TypeError)
  end

  it "should raise ArgumentError when #new size is an Array of non-Numerics" do
    lambda {
      Surface.new(["not", "numerics"])
    }.should raise_error(ArgumentError)
  end

  it "should raise ArgumentError when #new size is too short" do
    lambda {
      Surface.new([1])
    }.should raise_error(ArgumentError)
  end


  context "with :alpha option" do

    context "with no :depth option" do
      it "should have depth 32" do
        surface = Surface.new([10,10], :alpha => true)
        surface.depth.should == 32
      end

      it "should not emit a warning" do
        Kernel.should_not_receive(:warn)
        surface = Surface.new([10,10], :alpha => true)
      end
    end

    context "with :depth => 0" do
      it "should have depth 32" do
        surface = Surface.new([10,10], :alpha => true, :depth => 0)
        surface.depth.should == 32
      end

      it "should not emit a warning" do
        Kernel.should_not_receive(:warn)
        surface = Surface.new([10,10], :alpha => true, :depth => 0)
      end
    end

    context "with :depth => 32" do
      it "should have depth 32" do
        surface = Surface.new([10,10], :alpha => true, :depth => 32)
        surface.depth.should == 32
      end

      it "should not emit a warning" do
        Kernel.should_not_receive(:warn)
        surface = Surface.new([10,10], :alpha => true, :depth => 32)
      end
    end

    [8, 15, 16, 24].each { |d|
      context "with :depth => #{d}" do
        it "should have depth 32" do
          # Don't want the warning text mucking up rspec output
          Kernel.stub(:warn)

          surface = Surface.new([10,10], :alpha => true, :depth => d)
          surface.depth.should == 32
        end

        it "should emit a warning" do
          Kernel.should_receive(:warn).
            with("WARNING: Cannot create a #{d}-bit Surface with " +
                 "an alpha channel. Using depth 32 instead.")
          surface = Surface.new([10,10], :alpha => true, :depth => d)
        end
      end
    }

  end

end



describe Surface, "(loading)" do
  before :each do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end
  end

  it "should load image to a new Surface" do
    surface = Surface.load( test_image )
  end

  it "should raise an error if file is not an image" do
    lambda{ Surface.load( not_image ) }.should raise_error( SDLError )
  end

  it "should raise an error if file doesn't exist" do
    lambda{ Surface.load( dne ) }.should raise_error( SDLError )
  end
end


describe Surface, "(loading from string)" do
  before :each do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    @data = "\x42\x4d\x3a\x00\x00\x00\x00\x00"+
            "\x00\x00\x36\x00\x00\x00\x28\x00"+
            "\x00\x00\x01\x00\x00\x00\x01\x00"+
            "\x00\x00\x01\x00\x18\x00\x00\x00"+
            "\x00\x00\x04\x00\x00\x00\x13\x0b"+
            "\x00\x00\x13\x0b\x00\x00\x00\x00"+
            "\x00\x00\x00\x00\x00\x00\x00\x00"+
            "\xff\x00"
  end
  
  it "should be able to load from string" do
    surf = Surface.load_from_string(@data)
    surf.get_at(0,0).should == [255,0,0,255]
  end
  
  it "should be able to load from string (typed)" do
    surf = Surface.load_from_string(@data,"BMP")
    surf.get_at(0,0).should == [255,0,0,255]
  end
end


describe Surface, "(marshalling)" do

  before :each do
    @surf = Rubygame::Surface.new([10,20], :depth => 32, :alpha => true)
    @surf.set_at([0,0], [12,34,56,78])
    @surf.set_at([9,9], [90,12,34,56])
    @surf.colorkey = [34,23,12]
    @surf.alpha = 123
    @surf.clip = [4,3,2,1]
  end

  it "should support Marshal.dump" do
    lambda { Marshal.dump(@surf) }.should_not raise_error
  end

  it "should support Marshal.load" do
    lambda { Marshal.load( Marshal.dump(@surf) ) }.should_not raise_error
  end

  it "should preserve size" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.size.should == [10,20]
  end

  it "should preserve depth" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.depth.should == 32
  end

  it "should preserve flags" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.flags.should == @surf.flags
  end

  it "should preserve pixel data" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.get_at([0,0]).should == [12,34,56,78]
    surf2.get_at([9,9]).should == [90,12,34,56]
  end

  it "should preserve colorkey" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.colorkey.should == [34,23,12]
  end

  it "should preserve alpha" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.alpha.should == 123
  end

  it "should preserve palette" do
    surf = Rubygame::Surface.new([10,20], :depth => 2)
    surf.palette = [[0,1,2], [3,4,5], [6,7,8], [9,10,11]]
    surf2 = Marshal.load( Marshal.dump(surf) )
    surf2.palette.should == [[0,1,2], [3,4,5], [6,7,8], [9,10,11]]
  end

  it "should preserve clip" do
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.clip.should == Rubygame::Rect.new(4,3,2,1)
  end

  it "should preserve taint status" do
    @surf.taint
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.should be_tainted
  end

  it "should preserve frozen status" do
    @surf.freeze
    surf2 = Marshal.load( Marshal.dump(@surf) )
    surf2.should be_frozen
  end

end


describe Surface, "(named resource)" do
  before :each do
    Surface.autoload_dirs = [samples_dir]
  end

  after :each do
    Surface.autoload_dirs = []
    Surface.instance_eval { @resources = {} }
  end

  it "should include NamedResource" do
    Surface.included_modules.should include(NamedResource)
  end

  it "should respond to :[]" do
    Surface.should respond_to(:[])
  end

  it "should respond to :[]=" do
    Surface.should respond_to(:[]=)
  end

  it "should allow setting resources" do
    s = Surface.load(panda)
    Surface["panda"] = s
    Surface["panda"].should == s
  end

  it "should reject non-Surface resources" do
    lambda { Surface["foo"] = "bar" }.should raise_error(TypeError)
  end

  it "should autoload images as Surface instances" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["panda.png"].should be_instance_of(Surface)
  end

  it "should return nil for nonexisting files" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["foobar.png"].should be_nil
  end

  it "should set names of autoload Surfaces" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["panda.png"].name.should == "panda.png"
  end
end



describe Surface, "(blit)" do
  before(:each) do
    Rubygame.init()
    @screen = Screen.new([100,100])
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "should raise TypeError when #blit target is not a Surface" do
    lambda {
      @surface.blit("not a surface", [0,0])
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #blit dest is not an Array" do
    lambda {
      @surface.blit(@screen, "foo")
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #blit src is not an Array" do
    lambda { 
      @surface.blit(@screen, [0,0], "foo")
    }.should raise_error(TypeError)
  end
end



describe Surface, "(fill)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "should raise TypeError when #fill color is not an Array" do
    lambda {
      @surface.fill(nil)
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #fill color is an Array of non-Numerics" do
    lambda {
      @surface.fill(["non", "numeric", "members"])
    }.should raise_error(TypeError)
  end

  it "should raise ArgumentError when #fill color is too short" do
    lambda {
      @surface.fill([0xff, 0xff])
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #fill rect is not an Array" do
    lambda {
      @surface.fill([0xff, 0xff, 0xff], "not_an_array")
    }.should raise_error(TypeError)
  end
end



describe Surface, "(colorkey)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end


  it "colorkey should be nil by default" do
    @surface.colorkey.should be_nil
  end

  it "should not have colorkey flag by default" do
    (@surface.flags & SRCCOLORKEY).should == 0
  end


  it "colorkey should be a color after it is set" do
    @surface.set_colorkey([1,2,3])
    @surface.colorkey.should == [1,2,3]
  end

  it "should have colorkey flag after colorkey is set" do
    @surface.set_colorkey([1,2,3])
    (@surface.flags & SRCCOLORKEY).should == SRCCOLORKEY
  end


  it "colorkey should be nil after it is set to nil" do
    @surface.set_colorkey([1,2,3])
    @surface.set_colorkey( nil )
    @surface.colorkey.should be_nil
  end
 
  it "should not have colorkey flag after colorkey is set to nil" do
    @surface.set_colorkey([1,2,3])
    @surface.set_colorkey( nil )
    (@surface.flags & SRCCOLORKEY).should == 0
  end
end




describe Surface, "(get_at)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "get_at should get [0,0,0,255] on a new non-alpha surface" do
    @surface.get_at(0,0).should == [0,0,0,255]
  end

#   it "get_at should get [0,0,0,0] on a new alpha surface" do
#     @surface = Surface.new([100,100], 0, [SRCALPHA])
#     @surface.get_at(0,0).should == [0,0,0,0]
#   end

  it "get_at should get the color of a filled surface" do
    @surface.fill([255,0,0])
    @surface.get_at(0,0).should == [255,0,0,255]
  end


  describe "(8-bit)" do
    before(:each) do
      Rubygame.init()
      @surface = Surface.load( test_image_8bit )
    end

    it "get_at should get the color of the pixel" do
      @surface.get_at(0,0).should == [255,0,0,255]
    end

  end
end



describe Surface, "(palette)" do 

  after(:each) do
    Rubygame.quit
  end


  describe "depth 1" do
    before :each do
      @surf = Surface.new([1,1], :depth => 1)
    end

    it "should have a palette with 2 entries" do
      @surf.palette.size.should == 2
    end

    it "should have black and white entries" do
      @surf.palette.should include([0,0,0])
      @surf.palette.should include([255,255,255])
    end
  end


  (2..8).each do |d|

    describe "depth #{d}" do
      before :each do
        @surf = Surface.new([1,1], :depth => d)
      end

      it "should have a palette with #{2**d} entries" do
        @surf.palette.size.should == 2**d
      end

      it "palette should be all black by default" do
        @surf.palette.each{ |entry|  entry.should == [0,0,0] }
      end
    end

  end


  describe "depth >8" do
    it "should not have a palette" do
      (9..32).each { |i|
        Surface.new([1,1], :depth => i).palette.should be_nil
      }
    end
  end


end


describe Surface, "(set_palette)" do 

  after(:each) do
    Rubygame.quit
  end


  (2..8).each do |d|

    describe "depth #{d}" do
      before :each do
        @surf = Surface.new([1,1], :depth => d)
      end

      it "should overwrite a single entry" do
        @surf.set_palette([[1,2,3]])
        @surf.palette[0..2].should == [[1,2,3], [0,0,0], [0,0,0]]
      end

      it "should overwrite multiple entries" do
        @surf.set_palette([[1,2,3], [4,5,6]])
        @surf.palette[0..2].should == [[1,2,3], [4,5,6], [0,0,0]]
      end

      it "should overwrite a single entry with an offset" do
        @surf.set_palette([[1,2,3]], :offset => 1)
        @surf.palette[0..2].should == [[0,0,0], [1,2,3], [0,0,0]]
      end

      it "should overwrite multiple entries with an offset" do
        @surf.set_palette([[1,2,3], [4,5,6]], :offset => 1)
        @surf.palette[0..3].should == [[0,0,0], [1,2,3], [4,5,6], [0,0,0]]
      end

      it "should work with a ColorRGB" do
        @surf.set_palette([Rubygame::Color::ColorRGB.new([1,0,1])])
        @surf.palette[0..2].should == [[255,0,255], [0,0,0], [0,0,0]]
      end

      it "should work with a ColorRGB255" do
        @surf.set_palette([Rubygame::Color::ColorRGB255.new([255,0,255])])
        @surf.palette[0..2].should == [[255,0,255], [0,0,0], [0,0,0]]
      end

      it "should work with a ColorHSV" do
        @surf.set_palette([Rubygame::Color::ColorHSV.new([0.2,0.2,0.2])])
        @surf.palette[0..2].should == [[49,51,41], [0,0,0], [0,0,0]]
      end

      it "should work with a ColorHSL" do
        @surf.set_palette([Rubygame::Color::ColorHSL.new([0.2,0.2,0.2])])
        @surf.palette[0..2].should == [[57,61,41], [0,0,0], [0,0,0]]
      end

      it "should work with a color name symbol" do
        @surf.set_palette([:red])
        @surf.palette[0..2].should == [[255,0,0], [0,0,0], [0,0,0]]
      end

      it "should work with a color name string" do
        @surf.set_palette(["red"])
        @surf.palette[0..2].should == [[255,0,0], [0,0,0], [0,0,0]]
      end

      it "should not work with invalid items" do
        [nil, true, false, 1, 1.0, [1,2], {}].each do |invalid_item|
          proc{ @surf.set_palette([invalid]) }.should raise_error
        end
      end

    end

  end


  describe "depth >8" do
    it "should raise SDLError" do
      (9..32).each { |i|
        lambda { 
          Surface.new([1,1], :depth => i).set_palette([:black])
        }.should raise_error(Rubygame::SDLError)
      }
    end
  end


end



describe "A frozen", Surface do

  before :each do
    @surface = Surface.new([10,10])
    @surface.freeze
  end


  it "should be frozen" do
    @surface.should be_frozen
  end


  it "alpha should NOT raise error" do
    lambda{ @surface.alpha }.should_not raise_error
  end

  it "set_alpha should raise error" do
    lambda{ @surface.set_alpha(0) }.should raise_error
  end

  it "alpha= should raise error" do
    lambda{ @surface.alpha = 0 }.should raise_error
  end

 
  it "colorkey should NOT raise error" do
    lambda{ @surface.colorkey }.should_not raise_error
  end

  it "set_colorkey should raise error" do
    lambda{ @surface.set_colorkey(:blue) }.should raise_error
  end

  it "colorkey= should raise error" do
    lambda{ @surface.colorkey = :blue }.should raise_error
  end

 
  it "palette should NOT raise error" do
    lambda{ @surface.palette }.should_not raise_error
  end

  it "set_palette should raise error" do
    @surface = Surface.new([10,10], :depth => 2)
    @surface.freeze
    lambda{ @surface.set_palette([:blue]) }.should raise_error
  end

  it "palette= should raise error" do
    @surface = Surface.new([10,10], :depth => 2)
    @surface.freeze
    lambda{ @surface.palette = [:blue] }.should raise_error
  end


  it "unfrozen-on-frozen blit should raise error" do
    @surface2 = Surface.new([10,10])
    lambda{ @surface2.blit(@surface,[0,0]) }.should raise_error
  end

  it "frozen-on-frozen blit should raise error" do
    @surface2 = Surface.new([10,10])
    @surface2.freeze
    lambda{ @surface.blit(@surface2,[0,0]) }.should raise_error
  end

  it "frozen-on-unfrozen blit should NOT raise error" do
    @surface2 = Surface.new([10,10])
    lambda{ @surface.blit(@surface2,[0,0]) }.should_not raise_error
  end


  it "fill should raise error" do
    lambda{ @surface.fill(:blue) }.should raise_error
  end


  it "get_at should NOT raise error" do
    lambda{ @surface.get_at([0,0]) }.should_not raise_error
  end

  it "set_at should raise error" do
    lambda{ @surface.set_at([0,0],:blue) }.should raise_error
  end


  it "pixels should NOT raise error" do
    lambda{ @surface.pixels }.should_not raise_error
  end

  it "pixels= should raise error" do
    lambda{ @surface.pixels = @surface.pixels }.should raise_error
  end


  it "clip should NOT raise error" do
    lambda{ @surface.clip }.should_not raise_error
  end

  it "clip= should raise error" do
    lambda{ @surface.clip = Rect.new(0,0,1,1) }.should raise_error
  end


  it "draw_line should raise error" do
    if @surface.respond_to? :draw_line
      lambda{ @surface.draw_line([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_line support. Is SDL_gfx available?"
    end
  end

  it "draw_line_a should raise error" do
    if @surface.respond_to? :draw_line_a
      lambda{ @surface.draw_line_a([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_line_a support. Is SDL_gfx available?"
    end
  end


  it "draw_box should raise error" do
    if @surface.respond_to? :draw_box
      lambda{ @surface.draw_box([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_box support. Is SDL_gfx available?"
    end
  end

  it "draw_box_s should raise error" do
    if @surface.respond_to? :draw_box_s
      lambda{ @surface.draw_box_s([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_box_s support. Is SDL_gfx available?"
    end
  end


  it "draw_circle should raise error" do
    if @surface.respond_to? :draw_circle
      lambda{ @surface.draw_circle([0,0],1,:white) }.should raise_error
    else
      pending "No draw_circle support. Is SDL_gfx available?"
    end
  end

  it "draw_circle_a should raise error" do
    if @surface.respond_to? :draw_circle_a
      lambda{ @surface.draw_circle_a([0,0],1,:white) }.should raise_error
    else
      pending "No draw_circle_a support. Is SDL_gfx available?"
    end
  end

  it "draw_circle_s should raise error" do
    if @surface.respond_to? :draw_circle_s
      lambda{ @surface.draw_circle_s([0,0],1,:white) }.should raise_error
    else
      pending "No draw_circle_s support. Is SDL_gfx available?"
    end
  end


  it "draw_ellipse should raise error" do
    if @surface.respond_to? :draw_ellipse
      lambda{ @surface.draw_ellipse([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_ellipse support. Is SDL_gfx available?"
    end
  end

  it "draw_ellipse_a should raise error" do
    if @surface.respond_to? :draw_ellipse_a
      lambda{ @surface.draw_ellipse_a([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_ellipse_a support. Is SDL_gfx available?"
    end
  end

  it "draw_ellipse_s should raise error" do
    if @surface.respond_to? :draw_ellipse_s
      lambda{ @surface.draw_ellipse_s([0,0],[1,1],:white) }.should raise_error
    else
      pending "No draw_ellipse_s support. Is SDL_gfx available?"
    end
  end


  it "draw_arc should raise error" do
    if @surface.respond_to? :draw_arc
      lambda{ @surface.draw_arc([0,0],1,[0,1],:white) }.should raise_error
    else
      pending "No draw_arc support. Is SDL_gfx available?"
    end
  end

  it "draw_arc_s should raise error" do
    if @surface.respond_to? :draw_arc_s
      lambda{ @surface.draw_arc_s([0,0],1,[0,1],:white) }.should raise_error
    else
      pending "No draw_arc_s support. Is SDL_gfx available?"
    end
  end


  it "draw_polygon should raise error" do
    if @surface.respond_to? :draw_polygon
      lambda{ @surface.draw_polygon([[0,0],[1,1]],:white) }.should raise_error
    else
      pending "No draw_polygon support. Is SDL_gfx available?"
    end
  end

  it "draw_polygon_a should raise error" do
    if @surface.respond_to? :draw_polygon_a
      lambda{ @surface.draw_polygon_a([[0,0],[1,1]],:white) }.should raise_error
    else
      pending "No draw_polygon_a support. Is SDL_gfx available?"
    end
  end

  it "draw_polygon_s should raise error" do
    if @surface.respond_to? :draw_polygon_s
      lambda{ @surface.draw_polygon_s([[0,0],[1,1]],:white) }.should raise_error
    else
      pending "No draw_polygon_s support. Is SDL_gfx available?"
    end
  end


  it "draw_curve should raise error" do
    if @surface.respond_to? :draw_curve
      lambda{ @surface.draw_curve([[0,0],[1,1]],:white) }.should raise_error
    else
      pending "No draw_curve support. Is SDL_gfx available?"
    end
  end


  it "rotozoom should NOT raise error" do
    if @surface.respond_to? :rotozoom
      lambda{ @surface.rotozoom(1,1) }.should_not raise_error
    else
      pending "No rotozoom support. Is SDL_gfx available?"
    end
  end

  it "zoom should NOT raise error" do
    if @surface.respond_to? :zoom
      lambda{ @surface.zoom(1) }.should_not raise_error
    else
      pending "No zoom support. Is SDL_gfx available?"
    end
  end

  it "zoom_to should NOT raise error" do
    if @surface.respond_to? :zoom_to
      lambda{ @surface.zoom_to(5,5) }.should_not raise_error
    else
      pending "No zoom_to support. Is SDL_gfx available?"
    end
  end

  it "flip should NOT raise error" do
    if @surface.respond_to? :flip
      lambda{ @surface.flip(true,true) }.should_not raise_error
    else
      pending "No flip support. Is SDL_gfx available?"
    end
  end

end



describe Surface, "(vector support)" do

  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "#blit should accept a Vector2 for dest" do
    lambda {
      @surface.blit(Surface.new([100,100]), Vector2[0,0])
    }.should_not raise_error
  end

  it "#get_at should accept a Vector2 for position" do
    @surface.get_at(Vector2[0,0]).should == [0,0,0,255]
  end

  it "#set_at should accept a Vector2 for position" do
    @surface.set_at(Vector2[0,0], :blue)
    @surface.get_at(0,0).should == [0,0,255,255]
  end


  it "draw_line should accept Vector2s" do
    if @surface.respond_to? :draw_line
      lambda{
        @surface.draw_line( Vector2[0,0], Vector2[1,1], :white )
      }.should_not raise_error
    else
      pending "No draw_line support. Is SDL_gfx available?"
    end
  end

  it "draw_line_a should accept Vector2s" do
    if @surface.respond_to? :draw_line_a
      lambda{
        @surface.draw_line_a( Vector2[0,0], Vector2[1,1], :white )
      }.should_not raise_error
    else
      pending "No draw_line_a support. Is SDL_gfx available?"
    end
  end


  it "draw_box should accept Vector2s" do
    if @surface.respond_to? :draw_box
      lambda{
        @surface.draw_box( Vector2[0,0], Vector2[1,1], :white )
      }.should_not raise_error
    else
      pending "No draw_box support. Is SDL_gfx available?"
    end
  end

  it "draw_box_s should accept Vector2s" do
    if @surface.respond_to? :draw_box_s
      lambda{
        @surface.draw_box_s( Vector2[0,0], Vector2[1,1], :white )
      }.should_not raise_error
    else
      pending "No draw_box_s support. Is SDL_gfx available?"
    end
  end


  it "draw_circle should accept a Vector2" do
    if @surface.respond_to? :draw_circle
      lambda{
        @surface.draw_circle( Vector2[1,1], 1, :white )
      }.should_not raise_error
    else
      pending "No draw_circle support. Is SDL_gfx available?"
    end
  end

  it "draw_circle_a should accept a Vector2" do
    if @surface.respond_to? :draw_circle_a
      lambda{
        @surface.draw_circle_a( Vector2[1,1], 1, :white )
      }.should_not raise_error
    else
      pending "No draw_circle_a support. Is SDL_gfx available?"
    end
  end

  it "draw_circle_s should accept a Vector2" do
    if @surface.respond_to? :draw_circle_s
      lambda{
        @surface.draw_circle_s( Vector2[1,1], 1, :white )
      }.should_not raise_error
    else
      pending "No draw_circle_s support. Is SDL_gfx available?"
    end
  end


  it "draw_ellipse should accept a Vector2" do
    if @surface.respond_to? :draw_ellipse
      lambda{
        @surface.draw_ellipse( Vector2[1,1], [1,2], :white )
      }.should_not raise_error
    else
      pending "No draw_ellipse support. Is SDL_gfx available?"
    end
  end

  it "draw_ellipse_a should accept a Vector2" do
    if @surface.respond_to? :draw_ellipse_a
      lambda{
        @surface.draw_ellipse_a( Vector2[1,1], [1,2], :white )
      }.should_not raise_error
    else
      pending "No draw_ellipse_a support. Is SDL_gfx available?"
    end
  end

  it "draw_ellipse_s should accept a Vector2" do
    if @surface.respond_to? :draw_ellipse_s
      lambda{
        @surface.draw_ellipse_s( Vector2[1,1], [1,2], :white )
      }.should_not raise_error
    else
      pending "No draw_ellipse_s support. Is SDL_gfx available?"
    end
  end


  it "draw_arc should accept a Vector2" do
    if @surface.respond_to? :draw_arc
      lambda{
        @surface.draw_arc( Vector2[1,1], 1, [0,1], :white )
      }.should_not raise_error
    else
      pending "No draw_arc support. Is SDL_gfx available?"
    end
  end

  it "draw_arc_s should accept a Vector2" do
    if @surface.respond_to? :draw_arc_s
      lambda{
        @surface.draw_arc_s( Vector2[1,1], 1, [0,1], :white )
      }.should_not raise_error
    else
      pending "No draw_arc_s support. Is SDL_gfx available?"
    end
  end


  it "draw_polygon should accept Vector2s" do
    if @surface.respond_to? :draw_polygon
      lambda{
        points = [Vector2[1,1], Vector2[1,2], Vector2[2,2]]
        @surface.draw_polygon( points, :white )
      }.should_not raise_error
    else
      pending "No draw_polygon support. Is SDL_gfx available?"
    end
  end

  it "draw_polygon_a should accept Vector2s" do
    if @surface.respond_to? :draw_polygon_a
      lambda{
        points = [Vector2[1,1], Vector2[1,2], Vector2[2,2]]
        @surface.draw_polygon_a( points, :white )
      }.should_not raise_error
    else
      pending "No draw_polygon_a support. Is SDL_gfx available?"
    end
  end

  it "draw_polygon_s should accept Vector2s" do
    if @surface.respond_to? :draw_polygon_s
      lambda{
        points = [Vector2[1,1], Vector2[1,2], Vector2[2,2]]
        @surface.draw_polygon_s( points, :white )
      }.should_not raise_error
    else
      pending "No draw_polygon_s support. Is SDL_gfx available?"
    end
  end


  it "draw_curve should accept Vector2s" do
    if @surface.respond_to? :draw_curve
      lambda{
        points = [Vector2[1,1], Vector2[1,2], Vector2[2,2]]
        @surface.draw_curve( points, :white )
      }.should_not raise_error
    else
      pending "No draw_curve support. Is SDL_gfx available?"
    end
  end

end



describe Surface do

  context "without an alpha channel" do
    it "should be flat" do
      surface = Surface.new([10,10], :alpha => false)
      surface.should be_flat
    end
  end

  context "with an alpha channel" do
    it "should not be flat" do
      surface = Surface.new([10,10], :alpha => true)
      surface.should_not be_flat
    end
  end

end
