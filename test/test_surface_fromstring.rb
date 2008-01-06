#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This is a unit test suite for the from_string functionality of 
# Rubygame::Surface.  Like the others, it's nowhere near being comprehensive.

require "test/unit"
require "rubygame"

class TC_Surface_FromString < Test::Unit::TestCase
  
  # This data is a 1x1 red pixel with full opacity in
  # BMP format.  Done on my Intel machine, so gods know
  # if this test will pass on a PPC
  def setup
    @data = "\x42\x4d\x3a\x00\x00\x00\x00\x00"+
            "\x00\x00\x36\x00\x00\x00\x28\x00"+
            "\x00\x00\x01\x00\x00\x00\x01\x00"+
            "\x00\x00\x01\x00\x18\x00\x00\x00"+
            "\x00\x00\x04\x00\x00\x00\x13\x0b"+
            "\x00\x00\x13\x0b\x00\x00\x00\x00"+
            "\x00\x00\x00\x00\x00\x00\x00\x00"+
            "\xff\x00"
  end
  
  def test_from_string
    surf = Rubygame::Surface.from_string(@data)
    assert_equal(surf.get_at(0,0), [255,0,0,255])
  end
  
  def test_from_string_typed
    surf = Rubygame::Surface.from_string(@data,"BMP")
    assert_equal(surf.get_at(0,0), [255,0,0,255])
  end
end