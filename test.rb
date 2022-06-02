require 'ruby2d'


MINIMAP_SIZE = 200
MINIMAP_TILE = 16
# Set the window size
set width: 800, height: 800
set title: "Simple Paint", background: 'gray', resizable: true, diagnostics: true
set fps_cap: 24

class Point
	attr_reader :x, :y 

	def initialize(x, y)
		@x = x
		@y = y
	end

	def to_s
		return "[#{x}, #{y}]"
	end

	def self.addPoints(point1, point2)
		Point.new(point1.x + point2.x, point1.y + point2.y)
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
		  z: 5
		)
	end
end

class Player
	attr_accessor :position, :angle
	def initialize(position)
		@position = position
		@angle = 0
	end

	################################
	#	 .		N		.	 # 	 .  090º	.	 #
	#		 .	| .		 # 		 . |	.		 #
	#	 W -	*	- E	 # 180 - * - 0º  #
	#		 .	| .		 # 		 . |	.		 #
	#  .		S		.	 #	 .  270º	.  #
	################################

	def face_north
		return angle > 0 && angle < Game.angle180
	end

	def face_south
		return angle < 0 && angle > Game.angle180
	end

	def face_east
		return angle < Game.angle90 || angle > Game.angle270
	end

	def face_west
		return angle > Game.angle90 && angle < Game.angle270
	end
end

class Game
	attr_reader :width, :ppw, :player, :key_up, :key_down, :key_right, :key_left

	def initialize
		@width			= Window.width
		@height			= Window.height
		@tile_size	= 64
		@minimap_tile_size	= MINIMAP_TILE

		@@angle0		= 0
		@@angle60		= @width
		@@angle30		= (@@angle60/2).floor()
		@@angle15		= (@@angle30/2).floor()
		@@angle10		= (@@angle60/6).floor()
		@@angle05		= (@@angle10/2).floor() 
		@@angle45		= (@@angle15*3).floor()
		@@angle90		= (@@angle45*2).floor()
		@@angle180	= (@@angle60*3).floor()
		@@angle270	= (@@angle90*3).floor()
		@@angle360	= (@@angle60*6).floor()

		@tangents = Array.new(@@angle360 + 1) do |i|
			Math.tan((i * Math::PI) / @@angle180)
		end


		@cosines = Array.new(@@angle360 + 1) do |i|
			Math.cos((i * Math::PI) / @@angle180)
		end

		@sines = Array.new(@@angle360 + 1) do |i|
			Math.sin((i * Math::PI) / @@angle180)
		end

		@h_step		= Array.new(@@angle360 + 1) do |i|
			rad_angle = (i * Math::PI) / @@angle180
			x = (@tile_size /  Math.tan(rad_angle)).abs()
			y = @tile_size
			if (i > @@angle90 && i < @@angle270)
				x = -x
			end
			if (i < @@angle180)
				y = -y
			end
			Point.new(x, y)
		end
		@v_step		= Array.new(@@angle360 + 1) do |i|
			rad_angle = (i * Math::PI) / @@angle180
			x = @tile_size
			y = (@tile_size /  Math.tan(rad_angle)).abs()
			if (i > @@angle90 && i < @@angle270)
				x = -x
			end
			if (i < @@angle180)
				y = -y
			end
			Point.new(x, y)
		end

		@key_up			= false
		@key_down		= false
		@key_right	= false
		@key_left		= false

		@player			= Player.new(Point.new(30, 40))

		@@map = [
			[1, 1, 1, 1, 1],
			[1, 0, 1, 0, 1],
			[1, 0, 0, 0, 1],
			[1, 0, 0, 0, 1],
			[1, 0, 1, 0, 1],
			[1, 0, 1, 0, 1],
			[1, 0, 1, 0, 1],
			[1, 0, 0, 0, 1],
			[1, 2, 0, 0, 1],
			[1, 1, 1, 1, 1]
		]
		@@map.each do |y|
			y.each do |x|
				print "#{x} "
			end
			puts
		end
	end

	def draw_minimap
		@@map.each_with_index do |y, i|
			y.each_with_index do |x, j|
				Square.new(x: j * @minimap_tile_size, y: i * @minimap_tile_size, size: @minimap_tile_size, color: x == 1 ? "blue" : "green", z: 10)
			end
		end
		Circle.new(x: player.position.x, y: player.position.y, radius: 2, color: "#424242", z: 11)
	end

	def nearest_vertical(angle)
		
	end

	def nearest_horizontal(angle)
		
	end

	def distance(angle)

	end

  def ray_cast
  	_h_intersection, _v_intersection = nil
  	_h, _v = 0
  	_ray = player.angle - @@angle30 % @@angle360
  	_ray = @@angle360 + _ray unless _ray > 0
  	@@angle60.times do |column|
  		if player.face_north
  			_h = (player.position.y / @tile_size).floor() * @tile_size + @tile_size
  		else
  			_h = (player.position.y / @tile_size).floor() * @tile_size - @tile_size
  		end
  		_h_intersection = Point.new(@tangents[_ray] * (_h - player.position.y), _h.abs)
  		if player.face_east
  			_v = (player.position.x / @tile_size).floor() * @tile_size + @tile_size
  		else
  			_v = (player.position.x / @tile_size).floor() * @tile_size - @tile_size
  		end
  		_v_intersection = Point.new(_v.abs, @tangents[_ray] * (_v - player.position.x),)

  		
  		while (true)
  			if (collide(_h_intersection))
  				break ;
  			end
  			_h_intersection = Point.addPoints(_h_intersection, @h_step[_ray])
  		end

  		while (true)
  			if (collide(_v_intersection))
  				break ;
  			end
  			_h_intersection = Point.addPoints(_v_intersection, @v_step[_ray])
  		end

  		_h_distance = (_h_intersection.x - player.position.x) * @cosines[_ray]
  		_v_distance = (_v_intersection.y - player.position.y) * @sines[_ray]
  		if (_h_distance > _v_distance && _ray != 0 && _ray != @@angle90)

  		else
  			dist = _v_distance * @cosines[_ray]
  			dtp = 60
  			height = @tile_size / dist * dtp
  			center = Window.width / 2
  			bot = center + (height / 2)
  			top = center - (height / 2)
  			r = RayLine.new(Point.new(bot, column), Point.new(top, column), "#00ff00")
  			r.draw
  		end

  		_ray += 1;
			if (_ray >= @@angle360)
				_ray -= @@angle360;
			end
  	end
  end

	def collide(point)
		return true if(point.x / @tile_size  > @@map.length || point.x < 0 || point.y / @tile_size > @@map[0].length || point.y < 0)
		p = Point.new(point.x / @tile_size, point.y / @tile_size)
		return (@@map[p.x][p.y] == 1)
	end

	def self.angle0
		return @@angle0
	end
	def self.angle60
		return @@angle60
	end
	def self.angle30
		return @@angle30
	end
	def self.angle15
		return @@angle15
	end
	def self.angle10
		return @@angle10
	end
	def self.angle05
		return @@angle05
	end
	def self.angle45
		return @@angle45
	end
	def self.angle90
		return @@angle90
	end
	def self.angle180
		return @@angle180
	end
	def self.angle270
		return @@angle270
	end
	def self.angle360
		return @@angle360
	end
end

game = Game.new
puts "@Angles: #{Game.angle0} #{Game.angle05} #{Game.angle10} #{Game.angle15} #{Game.angle30} #{Game.angle45} #{Game.angle60} #{Game.angle90}"



update do
	x = Window.mouse_x
	y = Window.mouse_y
	Window.clear
	game.ray_cast
	game.draw_minimap
	Circle.new(x: x, y: y, radius: 3, color: "purple", z: 9)
	Circle.new(x: x, y: y, radius: 4, color: "black", z: 8)	
	# l = RayLine.new(Point.new(x, y), Point.new(x + 40, y), 'lime')

	# l.draw
end
show