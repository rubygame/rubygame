#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"
Rect = Rubygame::Rect

# 0 = only final message (how many passed, etc)
# 1 = (RECOMMENDED) final message + failed/excepted notices
# 2 = final message + failed/excepted/passed notices
$VERBOSITY = 1

$total_tests = 0
$passed_tests = 0
$failed_tests = 0
$except_tests = 0

def verbose(string)
	print string if $VERBOSITY > 0
end

def very_verbose(string)
	print string if $VERBOSITY > 1
end

def do_test(string)
	if block_given?
		$total_tests += 1
		begin
			if yield
				very_verbose string+"... PASSED\n"
				$passed_tests += 1
			else
				verbose string+"... FAILED\n"
				$failed_tests += 1
			end
		rescue => exception
			verbose string+"... EXCEPTION: %s\n"%exception.to_s
			$except_tests += 1
		end
	else
		very_verbose "You didn't give a block of code to test!\n"
	end
end

a = b = c = d = 0

puts "===Rect Test==="
do_test("Initialize from Array[4]"){a = Rect.new([0,0,20,20])}
do_test("Initialize from 2x Array[2]"){b = Rect.new([0,0],[20,20])}
do_test("Initialize from 4 Fixnum"){c = Rect.new(0,0,20,20)}
do_test("Initialize from Rect"){d = Rect.new(a)}
do_test("All the above Rects are equal (==)"){ a == b  and b == c and c == d}
do_test("Verify to_s"){a.to_s == "Rect(0,0,20,20)"}
do_test("Verify to_a"){a.to_a == [0,0,20,20]}
do_test("Verify primary attributes (x,y,w,h)")\
	{a.x == 0 and a.y == 0 and a.w == 20 and a.h == 20}
do_test("Verify attributes part 1 (size,centers)")\
	{a.size == [20,20] and a.center == [10,10] and\
	a.centerx == 10 and a.centery == 10}
do_test("Verify attributes part 2 (corners)")\
	{a.topleft == [0,0] and a.topright == [20,0] and a.bottomleft==[0,20] and\
	a.bottomright == [20,20]}
do_test("Verify attributes part 3 (midpoints)")\
	{a.midleft == [0,10] and a.midtop==[10,0] and\
	a.midright == [20,10] and a.midbottom == [10,20]}

if $passed_tests < $total_tests
	puts "Failed: %d; Excepted: %d; Passed: %d; (Total: %d)"\
		%[$failed_tests, $except_test, $passed_tests, $total_tests]
else
	puts "All tests passed (%d of %d)"%[$passed_tests,$total_tests]
end
puts "===End  Test==="
