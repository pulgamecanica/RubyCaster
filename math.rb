class GameObject
	attr_accessor :is_solid
	attr_reader :name

	def initialize(is_solid, name, position, sprite = "")
		@is_solid = is_solid
		@name = name
		@position = position
		@sprite = sprite
	end
end

class Wall < GameObject
	def initialize(position)
		super(true, "Wall", position, "wal.png")
	end
end

class	RayLine
	attr_accessor	:p1, :p2, :color

	def initialize(p1, p2, color)
		@p1 = p1
		@p2 = p2
		@color = color
	end

	def draw
		Line.new(
		  x1: p1.x, y1: p1.y,
		  x2: p2.x, y2: p2.y,
		  width: 1,
		  color: color,
		  z: 20
		)
	end
end