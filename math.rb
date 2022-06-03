class Point
	attr_reader :x, :y 

	def initialize(x, y)
		@x = x
		@y = y
	end

	def to_s
		"[#{x}, #{y}]"
	end

	def self.addPoints(point1, point2)
		Point.new(point1.x + point2.x, point1.y + point2.y)
	end

	def addVector(vector)
		Point.new(x + Game.cosines[vector.angle] * vector.magnitude, y - Game.sines[vector.angle] * vector.magnitude)
	end
end

class Vector
	attr_reader :magnitude, :angle

	def initialize(angle, magnitude)
		@magnitude	= magnitude
		@angle			= angle
	end
end

class	RayLine
	attr_accessor	:p1, :p2, :color, :z

	def initialize(p1, p2, color, z = 5)
		@p1			= p1
		@p2			= p2
		@z			= z
		@color	= color
	end

	def draw
		Line.new(
		  x1: p1.x, y1: p1.y,
		  x2: p2.x, y2: p2.y,
		  width: 1,
		  color: color,
		  z: z
		)
	end
end