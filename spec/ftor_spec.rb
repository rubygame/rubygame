
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame/ftor'
include Rubygame


describe Ftor do
  
  describe ".new_from_to" do
    it "should accept two Ftors" do
      lambda {
        Ftor.new_from_to( Ftor.new(0,0), Ftor.new(2,0) )
      }.should_not raise_error
    end
  end

end
