# TODO: More specs!


require 'rubygame'
include Rubygame



describe Screen do

  before :each do
    Rubygame.init
  end

  after :each do
    Rubygame.quit
  end

  it "should not be open by default" do
    Screen.open?.should be_false
  end

  it ".new should open the display window" do
    Screen.new( [10,10] )
    Screen.open?.should be_true
  end

  it ".open should open the display window" do
    Screen.open( [10,10] )
    Screen.open?.should be_true
  end

  it ".set_mode should open the display window" do
    Screen.set_mode( [10,10] )
    Screen.open?.should be_true
  end

  it ".instance should open the display window" do
    Screen.instance( [10,10] )
    Screen.open?.should be_true
  end

  it ".close should close the display window if open" do
    Screen.open( [10,10] )
    Screen.close
    Screen.open?.should be_false
  end

  it ".close should do nothing if the display window is not open" do
    Screen.close
    Screen.open?.should be_false
  end

  it "should not be open after Rubygame.quit" do
    Screen.new( [10,10] )
    Rubygame.quit
    Screen.open?.should be_false
  end


  describe "instance" do

    it "should be open after opening it" do
      screen = Screen.open( [10,10] )
      screen.should be_open
    end

    it "should have a close method" do
      screen = Screen.open( [10,10] )
      lambda{ screen.close }.should_not raise_error
    end

    it "should not be open after #close" do
      screen = Screen.open( [10,10] )
      screen.close
      screen.should_not be_open
    end

    it "should not be open after Screen.close" do
      screen = Screen.open( [10,10] )
      Screen.close
      screen.should_not be_open
    end

    it "should not be open after #close and re-open" do
      screen = Screen.open( [10,10] )
      screen.close
      Screen.open( [10,10] )
      screen.should_not be_open
    end

    it "should not be open after Rubygame.quit" do
      screen = Screen.open( [10,10] )
      Rubygame.quit
      screen.should_not be_open
    end

    it "#close should not raise error when already closed" do
      screen = Screen.open( [10,10] )
      screen.close
      lambda{ screen.close }.should_not raise_error
    end

    it "#close should not affect other instances" do
      screen1 = Screen.open( [10,10] )
      screen1.close
      screen2 = Screen.open( [10,10] )
      screen1.close
      screen2.should be_open
    end

  end



  ###########
  # OPENGL? #
  ###########

  describe ".opengl?" do

    it "should be true if Screen is open with :opengl" do
      Screen.open( [10,10], :opengl => true )
      Screen.opengl?.should be_true
    end

    it "should be true if Screen is open with OPENGL flag (deprecated)" do
      Screen.open( [10,10], 0, [Rubygame::OPENGL] )
      Screen.opengl?.should be_true
    end

    it "should not be true if Screen has never been opened" do
      Screen.opengl?.should be_false
    end

    it "should not be true if Screen has been closed" do
      Screen.open( [10,10] )
      Screen.close
      Screen.opengl?.should be_false
    end

    it "should not be true if Screen is not OpenGL mode" do
      Screen.open( [10,10] )
      Screen.opengl?.should be_false
    end

  end


  describe "#opengl?" do

    it "should be true if Screen is open with :opengl" do
      screen = Screen.open( [10,10], :opengl => true )
      screen.opengl?.should be_true
    end

    it "should be true if Screen is open with OPENGL flag (deprecated)" do
      screen = Screen.open( [10,10], 0, [Rubygame::OPENGL] )
      screen.opengl?.should be_true
    end

    it "should not be true if Screen is not open" do
      screen = Screen.open( [10,10] )
      screen.close
      screen.opengl?.should be_false
    end

    it "should not be true if Screen is not OpenGL mode" do
      screen = Screen.open( [10,10] )
      screen.opengl?.should be_false
    end

  end



  #########################
  # GET_OPENGL_ATTRIBUTES #
  #########################


  # All attributes whose values are integers.
  INT_OPENGL_ATTRS = {
    :red_size         => SDL::GL_RED_SIZE,
    :green_size       => SDL::GL_GREEN_SIZE,
    :blue_size        => SDL::GL_BLUE_SIZE,
    :alpha_size       => SDL::GL_ALPHA_SIZE,
    :buffer_size      => SDL::GL_BUFFER_SIZE,
    :depth_size       => SDL::GL_DEPTH_SIZE,
    :stencil_size     => SDL::GL_STENCIL_SIZE,
    :accum_red_size   => SDL::GL_ACCUM_RED_SIZE,
    :accum_green_size => SDL::GL_ACCUM_GREEN_SIZE,
    :accum_blue_size  => SDL::GL_ACCUM_BLUE_SIZE,
    :accum_alpha_size => SDL::GL_ACCUM_ALPHA_SIZE,
  }

  # All attributes whose values are bools.
  BOOL_OPENGL_ATTRS = {
    :doublebuffer     => SDL::GL_DOUBLEBUFFER,
  }



  describe ".get_opengl_attributes" do

    before :each do
      Screen.open( [10,10], :opengl => true )
    end


    it "should raise SDLError if Screen is not open" do
      Rubygame.quit
      lambda{ Screen.get_opengl_attributes(:red_size) }.should raise_error
    end

    it "should raise SDLError if Screen does not have opengl" do
      Rubygame.quit
      Screen.open( [10,10], :opengl => false )
      lambda{ Screen.get_opengl_attributes(:red_size) }.should raise_error
    end

    it "should raise SDLError if SDL.GL_GetAttribute fails" do
      SDL.should_receive(:GL_GetAttribute).
        with(SDL::GL_RED_SIZE).and_return(nil)

      lambda{
        Screen.get_opengl_attributes(:red_size)
      }.should raise_error(Rubygame::SDLError)
    end


    it "with an invalid attribute symbol should raise ArgumentError" do
      lambda{ 
        Screen.get_opengl_attributes( :foo )
      }.should raise_error(ArgumentError)
    end

    it "with an non-symbol should raise ArgumentError" do
      ["red_size", SDL::GL_RED_SIZE, true, nil].each { |bad_attr|
        lambda{ 
          Screen.get_opengl_attributes( bad_attr )
        }.should raise_error(ArgumentError)
      }
    end


    it "with no args should return an empty hash" do
      Screen.get_opengl_attributes().should == {}
    end


    INT_OPENGL_ATTRS.each do |attr_sym, attr_int|
      describe "with #{attr_sym.inspect}" do

        it "should not raise an error" do
          lambda{ 
            Screen.get_opengl_attributes(attr_sym)
          }.should_not raise_error
        end

        it "should return a hash with key #{attr_sym.inspect}" do
          result = Screen.get_opengl_attributes(attr_sym)
          result.should be_instance_of(Hash)
          result.keys[0].should == attr_sym
        end

        it "should call SDL.GL_GetAttribute with #{attr_int.inspect}" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(1)
          Screen.get_opengl_attributes(attr_sym)
        end

        it "should return the appropriate value for #{attr_sym.inspect}" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(123)
          result = Screen.get_opengl_attributes(attr_sym)
          result[attr_sym].should == 123
        end

      end
    end


    BOOL_OPENGL_ATTRS.each do |attr_sym, attr_int|
      describe "with #{attr_sym.inspect}" do

        it "should not raise an error" do
          lambda{ 
            Screen.get_opengl_attributes(attr_sym)
          }.should_not raise_error
        end

        it "should return a hash with key #{attr_sym.inspect}" do
          result = Screen.get_opengl_attributes(attr_sym)
          result.should be_instance_of(Hash)
          result.keys[0].should == attr_sym
        end

        it "should call SDL.GL_GetAttribute with #{attr_int.inspect}" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(1)
          Screen.get_opengl_attributes(attr_sym)
        end

        it "should return the appropriate value for #{attr_sym.inspect}" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(1)
          Screen.open( [10,10], :opengl => true )
          result = Screen.get_opengl_attributes(attr_sym)
          result[attr_sym].should == true
        end

        it "should convert the internal value 1 to true" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(1)
          result = Screen.get_opengl_attributes(attr_sym)
          result[attr_sym].should == true
        end

        it "should convert the internal value 0 to false" do
          SDL.should_receive(:GL_GetAttribute).with(attr_int).and_return(0)
          result = Screen.get_opengl_attributes(attr_sym)
          result[attr_sym].should == false
        end

      end
    end



    describe "with multiple symbols" do

      attrs     = [ :red_size, :green_size, :doublebuffer ]
      attr_ints = [ SDL::GL_RED_SIZE, SDL::GL_GREEN_SIZE,
                    SDL::GL_DOUBLEBUFFER ]
      vals      = [ 1, 2, true ]
      val_ints  = [ 1, 2, 1 ]


      it "should not raise an error" do
        lambda{ 
          Screen.get_opengl_attributes( *attrs )
        }.should_not raise_error
      end

      it "should return a hash with each symbol as a key" do
        result = Screen.get_opengl_attributes( *attrs )
        result.should be_instance_of(Hash)
        attrs.each { |attr|  result.should have_key(attr)  }
        result.should have(attrs.size).keys
      end

      it "should call SDL.GL_GetAttribute for each attribute" do
        attr_ints.each_index { |i|
          SDL.should_receive(:GL_GetAttribute).
            with(attr_ints[i]).and_return(val_ints[i])
        }
        Screen.get_opengl_attributes( *attrs )
      end

      it "should return the appropriate value for each symbol" do
        attr_ints.each_index { |i|
          SDL.should_receive(:GL_GetAttribute).
            with(attr_ints[i]).and_return(val_ints[i])
        }

        result = Screen.get_opengl_attributes( *attrs )

        attrs.each_index { |i|
          result[ attrs[i] ].should == vals[i]
        }
      end

    end
  end



  #########################
  # SET_OPENGL_ATTRIBUTES #
  #########################

  describe ".set_opengl_attributes" do

    before :each do
      Screen.open( [10,10], :opengl => true )
    end

    it "should not raise error when Screen is not open" do
      Rubygame.quit
      Rubygame.init
      lambda{
        Screen.set_opengl_attributes(:red_size => 8)
      }.should_not raise_error
    end

    it "should not raise error when Screen does not have opengl" do
      Rubygame.quit
      Screen.open( [10,10], :opengl => false )
      lambda{
        Screen.set_opengl_attributes(:red_size => 8)
      }.should_not raise_error
    end

    it "with no args should not raise an error" do
      lambda{
        Screen.set_opengl_attributes()
      }.should_not raise_error
    end


    it "with an invalid attribute symbol should raise ArgumentError" do
      lambda{ 
        Screen.set_opengl_attributes( :foo => 8 )
      }.should raise_error(ArgumentError)
    end

    it "with an non-symbol should raise ArgumentError" do
      ["red_size", SDL::GL_RED_SIZE, true, nil].each { |bad_attr|
        lambda{ 
          Screen.set_opengl_attributes( bad_attr => 8)
        }.should raise_error(ArgumentError)
      }
    end


    it "should raise SDLError if SDL.GL_SetAttribute fails" do
      SDL.should_receive(:GL_SetAttribute).
        with(SDL::GL_RED_SIZE, 8).and_return(-1)

      lambda{
        Screen.set_opengl_attributes(:red_size => 8)
      }.should raise_error(Rubygame::SDLError)
    end



    INT_OPENGL_ATTRS.each do |attr_sym, attr_int|
      describe "with #{attr_sym.inspect}" do

        it "should not raise error when value is zero integer" do
          lambda{ 
            Screen.set_opengl_attributes(attr_sym => 0)
          }.should_not raise_error
        end

        it "should not raise error when value is a positive integer" do
          lambda{ 
            Screen.set_opengl_attributes(attr_sym => 123)
          }.should_not raise_error
        end

        it "should raise TypeError when value is a negative integer" do
          lambda{ 
            Screen.set_opengl_attributes(attr_sym => -1)
          }.should raise_error(TypeError)
        end

        it "should raise TypeError when value is not an integer" do
          [-1.0, 0.0, 1.0, :foo, "bar", true, false, nil, [], {}].each { |val|
            lambda{ 
              Screen.set_opengl_attributes(attr_sym => val)
            }.should raise_error(TypeError)
          }
        end

        it "should call SDL.GL_SetAttribute with the right args" do
          SDL.should_receive(:GL_SetAttribute).
            with(attr_int, 123).and_return(0)
          Screen.set_opengl_attributes(attr_sym => 123)
        end

      end
    end


    BOOL_OPENGL_ATTRS.each do |attr_sym, attr_int|
      describe "with #{attr_sym.inspect}" do

        it "should not raise an error when value is true" do
          lambda{ 
            Screen.set_opengl_attributes(attr_sym => true)
          }.should_not raise_error
        end

        it "should not raise an error when value is false" do
          lambda{ 
            Screen.set_opengl_attributes(attr_sym => false)
          }.should_not raise_error
        end

        it "should raise TypeError when value is not a boolean" do
          [-1, 0, 1, 2, 3.0, :foo, "bar", nil, [], {}].each { |val|
            lambda{ 
              Screen.set_opengl_attributes(attr_sym => val)
            }.should raise_error(TypeError)
          }
        end

        it "should call SDL.GL_SetAttribute with 1 for true" do
          SDL.should_receive(:GL_SetAttribute).
            with(attr_int, 1).and_return(0)
          result = Screen.set_opengl_attributes(attr_sym => true)
        end

        it "should call SDL.GL_SetAttribute with 0 for false" do
          SDL.should_receive(:GL_SetAttribute).
            with(attr_int, 0).and_return(0)
          result = Screen.set_opengl_attributes(attr_sym => false)
        end

      end
    end



    describe "with multiple symbols" do

      args      = { :red_size => 1, :green_size => 2, :doublebuffer => true }
      attr_ints = [ SDL::GL_RED_SIZE, SDL::GL_GREEN_SIZE,
                    SDL::GL_DOUBLEBUFFER ]
      val_ints  = [ 1, 2, 1 ]


      it "should not raise an error" do
        lambda{ 
          Screen.set_opengl_attributes( args )
        }.should_not raise_error
      end

      it "should call SDL.GL_SetAttribute for each attribute" do
        attr_ints.each_index { |i|
          SDL.should_receive(:GL_SetAttribute).
            with(attr_ints[i], val_ints[i])
        }
        Screen.set_opengl_attributes( args )
      end

    end

   end


end
