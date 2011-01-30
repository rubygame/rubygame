

require 'rubygame/named_resource'
include Rubygame

TEST_DIR = File.dirname(__FILE__)



describe NamedResource do


  describe "instance names" do
    before :each do
      @class = Class.new {
        include NamedResource

        def initialize( name=nil )
          self.name = name
        end

        def to_s
          "#<InstanceNameExample #{name}>"
        end
        alias :inspect :to_s
      }

      @resource = @class.new( "my_name" )
    end

    it "should have a name" do
      @resource.name.should == "my_name"
    end

    it "name string should be frozen" do
      @resource.name.should be_frozen
    end

    it "should be able to set name" do
      @resource.name = "new_name"
      @resource.name.should == "new_name"
    end

    it "should reject non-string names" do
      lambda { @resource.name = ["foo"] }.should raise_error(TypeError)
    end
  end


  describe "resource table" do

    describe "general" do
      before :each do
        @class = Class.new {
          include NamedResource

          class << self
            attr_accessor :resources
          end

          def to_s
            "#<ResourceTableExample>"
          end
          alias :inspect :to_s
        }

        @instance = @class.new
        @class.resources["foo"] = @instance
      end

      it "should be able to get basename a name from a filename" do
        @class.basename("/foo/bar/baz.ext").should == "baz.ext"
      end

      it "should return object with registered name" do
        @class["foo"].should == @instance
      end

      it "should be able to register an object by name" do
        @class["bar"] = @instance
        @class["bar"].should == @instance
      end

      it "should only allow registering instances of that class" do
        lambda { @class["bar"] = 3 }.should raise_error(TypeError)
      end
    end


    describe "without autoload" do
      before :each do
        @class = Class.new {
          include NamedResource

          class << self
            attr_accessor :resources
          end

          def to_s
            "#<ResourceTableExample>"
          end
          alias :inspect :to_s
        }
      end

      it "should return nil for unregistered names" do
        @class["unassigned"].should be_nil
      end
    end


    describe "with autoload" do
      before :each do
        @class = Class.new {
          include NamedResource

          class << self
            attr_accessor :resources

            def autoload( name )
              instance = self.new
              return instance
            end
          end

          attr_accessor :name

          def to_s
            "#<ResourceTableExample>"
          end
          alias :inspect :to_s
        }
      end

      it "should autoload unregistered names" do
        instance = @class["bar"]
        instance.name.should == "bar"
        instance.should be_instance_of(@class)
      end

      it "should save autoloaded instances" do
        @class.resources["bar"].should be_nil
        instance = @class["bar"]
        @class.resources["bar"].should == instance
      end

      it "should set the name of autoloaded instances" do
        @class["bar"].name.should == "bar"
      end
    end


    describe "autoload paths" do
      before :each do
        @class = Class.new {
          include NamedResource

          class << self
            attr_accessor :resources

            def autoload( name )
              path = find_file( name )
              if path
                instance = self.new
                instance.path = path
                return instance
              end
            end

            # Fake check to see if file exists
            def exist?( path )
              if( path == File.join("foo","bar") or 
                  path == File.join("moo","bar")    )
                true
              else
                false
              end
            end
          end

          attr_accessor :name, :path

          def to_s
            "#<ResourceTableExample>"
          end
          alias :inspect :to_s
        }

        @some_dirs = [ "hoo", "woo", "foo", "moo" ]
      end

      it "should have an accessor for @autoload_paths" do
        @class.autoload_dirs.should == []
        @class.autoload_dirs.push("foo")
        @class.autoload_dirs.should == ["foo"]
      end

      it "should use the first path which succeeds" do
        @class.autoload_dirs = @some_dirs
        @class["bar"].path.should == File.join("foo","bar")
      end

      it "should return nil if no path succeeds" do
        @class.autoload_dirs = @some_dirs
        @class["nothing"].should be_nil
      end

    end

  end
end
