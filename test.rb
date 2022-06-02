require 'ruby2d'

# Set the window size
set width: 800, height: 800
set title: "Simple Paint", background: 'gray', resizable: true, diagnostics: true
set fps_cap: 16

# s = Square.new()
class	Figure
	attr_accessor	:x, :y, :color

	def initialize(x, y, color)
		@color = color
		@x = x
		@y = y
	end

end

class GameSquare < Figure
	attr_accessor :size

	def initialize(x, y, size, color)
		super(x, y, color);
		@size = size
	end

	def draw
		Square.new(x: x, y: y, color: color, size: size)
	end
end

class GameCircle < Figure
	attr_accessor	:radius

	def initialize(x, y, radius, color)
		super(x, y, color);
		@radius = radius
	end

	def draw
		Circle.new(x: x, y: y, color: color, radius: radius)
	end
end

class Game
	def initialize
		@figure_count = 0
	end
end

game = Game.new

update do
	x = Window.mouse_x
	y = Window.mouse_y
	rad = 5
	s = GameSquare.new(x, y, 10, '#00ff00')
	c = GameCircle.new(x, y, rad, 'yellow')

	s.draw
	c.draw
end

show