require 'body'
include Rubygame::Body

puts "Ftor - Ftor"
p ["Ftor[20,20].collide?(Ftor[20,20])", Ftor[20,20].collide?(Ftor[20,20])]
p ["Ftor[20,20].collide?(Ftor[20,0])", Ftor[20,20].collide?(Ftor[20,0])]
p ["Ftor[0,20].collide?(Ftor[20,20])", Ftor[20,20].collide?(Ftor[0,20])]
begin
	p ["Ftor[0,20].collide?(Ftor[20,20])", Ftor[20,20].collide?("foo")]
rescue => e
	puts e
end

puts "\nRect - Ftor"
p r = Rect.rect(0,0,20,20)
test = [Ftor[0,30], Ftor[30,0], Ftor[2,2], Ftor[20,20], Ftor[0,20]]
test.each { |ftor|
	p [ftor, r.collide?(ftor)]
}
p r.collide(test)

require 'test/unit'
class TestBody < Test::Unit::TestCase
	def test_ftor_ftor_collision
	end
end

__END__
