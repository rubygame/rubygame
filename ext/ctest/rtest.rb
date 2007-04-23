require 'sr_cRect'
require 'rubygame'
require 'ruby/kernel/bench'

R2 = Rubygame::Rect

$rect1 = R2.new([5,5,10,10])
$ary1  = [
	R2.new([0,5,3,3]),
	R2.new([5,0,3,3]),
	R2.new([20,5,3,3]),
	R2.new([5,20,3,3]),
	R2.new([5,5,3,3]),
]
$rect2 = Rect.new(5,5,10,10)
$ary2  = [
	Rect.new(0,5,3,3),
	Rect.new(5,0,3,3),
	Rect.new(20,5,3,3),
	Rect.new(5,20,3,3),
	Rect.new(5,5,3,3),
]

if $0 == __FILE__ then

p bench(1e4) { $rect1.collide_array($ary1) }
p bench(1e4) { $rect2.collide?(*$ary2) }
puts
p [$rect1.collide_array($ary1), $ary1[$rect1.collide_array($ary1)]]
p [$rect2.collide?(*$ary2), $ary2[$rect2.collide?(*$ary2)]]
puts
puts


$rect1 = R2.new([5,5,10,10])
$ary1  = [
	R2.new([0,5,3,3]),
	R2.new([5,0,3,3]),
	R2.new([20,5,3,3]),
	R2.new([5,20,3,3]),
	R2.new([5,5,3,3]),
]
$rect2 = Rect.new(5,5,10,10)
$ary2  = [
	[0,5,3,3],
	[5,0,3,3],
	[20,5,3,3],
	[5,20,3,3],
	[5,5,3,3],
]

p bench(1e4) { $rect2.collide?(*$ary2) }
puts
p [$rect2.collide?(*$ary2), $ary2[$rect2.collide?(*$ary2)]]
puts
puts

$rect1 = R2.new([5,5,10,10])
$ary1  = [
	R2.new([0,5,3,3]),
	R2.new([5,0,3,3]),
	R2.new([20,5,3,3]),
	R2.new([5,20,3,3]),
	R2.new([5,5,3,3]),
]
$rect2 = Rect.new(5,5,10,10)

p bench(1e4) { $rect2.collide?(*$ary1) }
puts
p [$rect2.collide?(*$ary1), $ary1[$rect2.collide?(*$ary1)]]
puts
puts

$rect1 = R2.new([5,5,10,10])
$ary1  = [
	R2.new([0.0,5.0,3.0,3.0]),
	R2.new([5.0,0.0,3.0,3.0]),
	R2.new([20.0,5.0,3.0,3.0]),
	R2.new([5.0,20.0,3.0,3.0]),
	R2.new([5.0,5.0,3.0,3.0]),
]
$rect2 = Rect.new(5,5,10,10)

p bench(1e4) { $rect2.collide?(*$ary1) }
puts
p [$rect2.collide?(*$ary1), $ary1[$rect2.collide?(*$ary1)]]
puts
puts

end