require_relative 'Math.rb'

class Projectile
	attr_accessor :speed, :angle, :position

	def initialize(position, angle, speed = 20)
		@angle = angle
		@speed = speed
		@position = position
	end

	def update_position
		@position = @position.add_vec(Vector.new(angle, speed))
	end

	def draw
		scale_position = @position / Game.scale
		Circle.new(x: scale_position.x, y: scale_position.y, radius: 2, color: "#00a10a", z: 9)
	end
end

class Wall
	attr_reader :size, :solid, :position, :color, :map_position

	def initialize(position, map_position, size)
		@position = position
		@map_position = map_position
		@size = size
		@solid = true
		@color = '#aa0dd1'
	end

	def draw
		Square.new(x: @position.x, y: @position.y, size: @size, color: @color)
	end

end

class Floor
	attr_reader :size, :solid, :position, :color, :map_position

	def initialize(position, map_position, size)
		@position = position
		@map_position = map_position
		@size = size
		@solid = false
		@color = '#a9c9c9'
	end

	def draw
		Square.new(x: @position.x, y: @position.y, size: @size, color: @color)
	end

end