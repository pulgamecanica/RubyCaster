require 'ruby2d'
require_relative 'math.rb'
require_relative 'player.rb'
require_relative 'map_element.rb'

set width: 1000, height: 1000
set title: "Simple Paint", background: 'gray', resizable: true, diagnostics: true
set fps_cap: 24

MINIMAP_SIZE  = 200
TILE_SIZE     = 64
MINIMAP_TILE  = 24

class Game
  attr_reader :width, :ppw, :player, :key_up, :key_down, :key_right, :key_left, :dtp

  @@angle0    = 0
  @@angle60   = Window.width
  @@angle30   = (@@angle60/2).floor()
  @@angle15   = (@@angle30/2).floor()
  @@angle10   = (@@angle60/6).floor()
  @@angle5    = (@@angle10/2).floor() 
  @@angle45   = (@@angle15*3).floor()
  @@angle90   = (@@angle45*2).floor()
  @@angle180  = (@@angle60*3).floor()
  @@angle270  = (@@angle90*3).floor()
  @@angle360  = (@@angle60*6).floor()
  @@tangents  = Array.new(@@angle360 + 1) {|i| Math.tan((i * Math::PI) / @@angle180)}
  @@itangents = Array.new(@@angle360 + 1) {|i| 1 / @@tangents[i]}
  @@cosines   = Array.new(@@angle360 + 1) {|i| Math.cos((i * Math::PI) / @@angle180)}
  @@icosines  = Array.new(@@angle360 + 1) {|i| 1 / @@cosines[i]}
  @@sines     = Array.new(@@angle360 + 1) {|i| Math.sin((i * Math::PI) / @@angle180)}
  @@isines    = Array.new(@@angle360 + 1) {|i| 1 / @@sines[i]}
  @@map = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ]


  def initialize
    @width              = Window.width
    @height             = Window.height
    @tile_size          = TILE_SIZE
    @minimap_tile_size  = MINIMAP_TILE
    @dtp                = 220

    @h_step = Array.new(@@angle360 + 1) do |i|
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

    @v_step = Array.new(@@angle360 + 1) do |i|
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

    @key_up     = false
    @key_down   = false
    @key_right  = false
    @key_left   = false

    @player     = Player.new(Point.new(90, 95))

    @@map.each do |y|
      y.each do |x|
        print "#{x} "
      end
      puts
    end
  end

  def key_pressed(key)
    case key
      when 'up' then @key_up = true
      when 'down' then @key_down = true
      when 'left' then @key_left = true
      when 'right' then @key_right = true
    end
  end

  def key_released(key)
    case key
      when 'up' then @key_up = false
      when 'down' then @key_down = false
      when 'left' then @key_left = false
      when 'right' then @key_right = false
    end
  end

  def keys_stats
    s = "#{" UP " if @key_up}#{" DOWN " if @key_down}#{" LEFT " if @key_left}#{" RIGHT " if @key_right}"
    puts s unless s.empty?
  end

  def draw_minimap
    @@map.each_with_index do |y, i|
      y.each_with_index do |x, j|
        Square.new(x: j * @minimap_tile_size, y: i * @minimap_tile_size, size: @minimap_tile_size - 1, color: x == 1 ? "blue" : "green", z: 10)
      end
    end
    map_position = Point.new(player.position.x * @minimap_tile_size / @tile_size, player.position.y * @minimap_tile_size / @tile_size)
    Circle.new(x: map_position.x, y: map_position.y, radius: 2, color: "#424242", z: 11)
  end

  def collide(point)
    return true if(point.x < 0 || point.y < 0)
    p = Point.new(point.x / @tile_size, point.y / @tile_size)
    return true if (p.y >= @@map.length || @@map[p.y].nil? || p.x >= @@map[p.y].length)
    return (@@map[p.y][p.x] == 1)
  end

  def update_player
    a = player.angle
    a -= @@angle5 if key_left
    a += @@angle5 if key_right
    player.angle = a
    m = 0
    m += @tile_size / 8 if key_up
    m -= @tile_size / 8 if key_down
    new_p = player.position.addVector(Vector.new(player.angle, m))
    if not collide(new_p)
      player.position = new_p
    end
  end

  def nearest_vertical(angle)
    x = 0
    if (angle > @@angle90 && angle < @@angle270)
      x = (player.position.x / @tile_size).floor * @tile_size - 1;
    else
      x = (player.position.x / @tile_size).floor * @tile_size + @tile_size;
    end
    p_const = @v_step[angle];
    intersection = Point.new(x, player.position.y + (player.position.x - x) / @@tangents[angle]);
    while (!collide(intersection))
      intersection = Point.addPoints(intersection, p_const);
    end
    return (((player.position.x - intersection.x).abs / @@cosines[angle]).abs);
  end

  def nearest_horizontal(angle)
    y = 0
    if (angle < @@angle180)
      y = (player.position.y / @tile_size).floor * @tile_size - 1;
    else
      y = (player.position.y / @tile_size).floor * @tile_size + @tile_size;
    end
    p_const = @h_step[angle];
    intersection = Point.new(player.position.x + (player.position.y - y) / @@tangents[angle], y);
    while (!collide(intersection))
      intersection = Point.addPoints(intersection, p_const);
    end
    return (((player.position.y - intersection.y).abs / @@sines[angle]).abs);
  end

  def distance(angle)
    v = nearest_vertical(angle)
    v
    # h = nearest_horizontal(angle)
    # v < h ? v : h
  end

  def ray_cast

    dist = distance(player.angle) * @minimap_tile_size / @tile_size
    map_position = Point.new(player.position.x * @minimap_tile_size / @tile_size, player.position.y * @minimap_tile_size / @tile_size)
    rl = RayLine.new(map_position, map_position.addVector(Vector.new(player.angle, 10)), "red", 11)
    rl.draw

    # @@angle60.times do |column|
    #   angle = (player.angle - @@angle30 + column) % @@angle360
    #   angle = @@angle360 + angle if angle < 0
    #   dist = distance(angle)
    #   height = dist * @@cosines[(-@@angle30 + column).abs]
    #   height = (@tile_size / height) * @dtp
    #   height /= 2
    #   rl = RayLine.new(Point.new(column, Window.height / 2 - height), Point.new(column, Window.height / 2 + height), "yellow")
    #   rl.draw
    #   map_position = Point.new(player.position.x * @minimap_tile_size / @tile_size, player.position.y * @minimap_tile_size / @tile_size)
    #   mini_rl = RayLine.new(map_position, map_position.addVector(Vector.new(angle, dist * @minimap_tile_size / @tile_size)), "red", 11)
    #   mini_rl.draw
    # end

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
  def self.angle5
    return @@angle5
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
  def self.tangents
    return @@tangents
  end
  def self.itangents
    return @@itangents
  end
  def self.cosines
    return @@cosines
  end
  def self.icosines
    return @@icosines
  end
  def self.sines
    return @@sines
  end
  def self.isines
    return @@isines
  end
end

game = Game.new
puts "@Angles: #{Game.angle0} #{Game.angle5} #{Game.angle10} #{Game.angle15} #{Game.angle30} #{Game.angle45} #{Game.angle60} #{Game.angle90} #{Game.angle180} #{Game.angle270} #{Game.angle360}"

update do
  x = Window.mouse_x
  y = Window.mouse_y
  Window.clear
  Circle.new(x: x, y: y, radius: 3, color: "purple", z: 9)
  Circle.new(x: x, y: y, radius: 4, color: "black", z: 8) 


  game.update_player
  game.ray_cast
  game.draw_minimap
  game.keys_stats

  on :key_down do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
      game.key_pressed(event.key)
    end
  end

  on :key_up do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
      game.key_released(event.key)
    end
  end
end
show