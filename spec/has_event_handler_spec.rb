
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame

HasEventHandler = Rubygame::EventHandler::HasEventHandler


class HandledObject
  include HasEventHandler
  def initialize
    super
  end
end


describe HasEventHandler do

  before :each do
    @object = HandledObject.new
    @results = []
  end
  
  ###############
  # MAGIC HOOKS #
  ###############

  it "should have a #magic_hooks method" do
    @object.should respond_to(:magic_hooks)
  end

end
