require_relative 'Math.rb'

class Player
	attr_accessor :position, :speed
	attr_reader :angle

	def initialize(position, angle, speed = 10)
		@position = position
		@angle = angle
		@speed = speed
	end

	def angle=(new_angle)
		new_angle = new_angle % Game.angle360
		if new_angle < 0
			new_angle = Game.angle360 + new_angle
		end
		@angle = new_angle
	end

	def draw
		scale_position = @position / Game.scale
		Circle.new(x: scale_position.x, y: scale_position.y, radius: 5, color: "#a0110a", z: 10)
	end
end