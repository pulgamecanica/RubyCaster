class Point
	attr_accessor :x, :y

	def initialize(x, y)
		@x = x
		@y = y
	end

	def ==(p)
		@x == p.x && @y == p.y
	end

	def *(factor)
		Point.new(@x * factor, @y * factor)
	end

	def /(factor)
		Point.new(@x / factor, @y / factor)
	end


	def scale(real_scale, new_scale)
		self * new_scale / real_scale
	end

	def +(p)
		Point.new(@x + p.x, @y + p.y)
	end

	def add_vec(vec)
		_x = @x + Game.cosines[vec.angle] * vec.magnitude
		_y = @y - Game.sines[vec.angle] * vec.magnitude # must be - when raycasting 
		Point.new(_x, _y)
	end

	def self.addPoints(p1, p2)
		Point.new(p1.x + p2.x, p2.y + p2.y)
	end

	def to_s
		"[#{@x}, #{@y}]"
	end
end

class Vector
	attr_accessor :angle, :magnitude

	def initialize(angle, magnitude)
		angle = angle % Game.angle360
		angle = Game.angle360 + angle if angle <= 0
		@angle = angle
		@magnitude = magnitude
	end

	def to_s
		"vec => [#{@angle}º: #{@magnitude}]"
	end

end

#****************************#
# 8|              X  <-- vector v(45º, 11)
# 7|            .
# 6|          .
# 5|        .
# 4|      .
# 3|    .
# 2|  .   o         <-- point o(4, 2)
# 1|_______________           o + v
# 0 1 2 3 4 5 6 7 8           => new_point (10, 12)








