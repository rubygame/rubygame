
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame


class EventHandler
  # Peeking inside. Cheating!
  attr_reader :hooks
end


describe EventHandler do

  it "should have no hooks after creation" do
    EventHandler.new.hooks.should be_empty
  end

end
