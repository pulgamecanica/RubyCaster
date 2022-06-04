require 'ruby2d'
require_relative 'Math.rb'
require_relative 'Player.rb'
require_relative 'MapObj.rb'

set width: 1000, height: 1000, background: 'gray'

class Game
  attr_reader :player

  @@projectiles = Array.new
  @@global_fire_speed = 10 # 1 in every @@global_fire_speed are fired
  @@player_speed = 3 # pixels per update
  @@tile_size = 64
  @@map_scale = 2

  @@angle0    = 0
  @@angle60   = Window.width
  @@angle30   = (@@angle60/2).floor
  @@angle15   = (@@angle30/2).floor
  @@angle10   = (@@angle60/6).floor
  @@angle5    = (@@angle10/2).floor 
  @@angle45   = (@@angle15*3).floor
  @@angle90   = (@@angle45*2).floor
  @@angle180  = (@@angle60*3).floor
  @@angle270  = (@@angle90*3).floor
  @@angle360  = (@@angle60*6).floor
  @@tangents  = Array.new(@@angle360 + 1) {|i| Math.tan((i * Math::PI) / @@angle180 + 0.0001)}
  @@itangents = Array.new(@@angle360 + 1) {|i| 1 / @@tangents[i]}
  @@cosines   = Array.new(@@angle360 + 1) {|i| Math.cos((i * Math::PI) / @@angle180 + 0.0001)}
  @@icosines  = Array.new(@@angle360 + 1) {|i| 1 / @@cosines[i]}
  @@sines     = Array.new(@@angle360 + 1) {|i| Math.sin((i * Math::PI) / @@angle180 + 0.0001)}
  @@isines    = Array.new(@@angle360 + 1) {|i| 1 / @@sines[i]}
  @@v_step    = Array.new(@@angle360 + 1) do |i|
    res = (@@tile_size * @@tangents[i]).abs
    res *= -1 if i > @@angle0 && i < @@angle180
    x = @@tile_size
    x = (x + 1) * -1 if i > @@angle90 && i < @@angle270
    Point.new(x, res)
  end
  @@h_step    = Array.new(@@angle360 + 1) do |i|
    res = (@@tile_size / @@tangents[i]).abs
    res *= -1 if i > @@angle90 && i < @@angle270
    y = @@tile_size
    y = (y + 1) * -1 if i > @@angle0 && i < @@angle180
    Point.new(res, y) 
  end
  @@map = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ]


  def initialize
    @player = Player.new(Point.new(3 * @@tile_size, 3 * @@tile_size), 0, @@player_speed)
    @key_up, @key_down, @key_left, @key_right, @fire = false
    @can_fire = @@global_fire_speed - 1
    @layout = Array.new
    @@map.each_with_index do |row, y|
      row.each_with_index do |elem, x|
        @layout.append(choose_map_obj(elem, Point.new(x * @@tile_size / @@map_scale, y * @@tile_size / @@map_scale), Point.new(x, y), @@tile_size / @@map_scale - 1))
      end
    end
  end

  def choose_map_obj(id, position, map_position, size)
    case id
      when 0 then Floor.new(position, map_position, size)
      when 1 then Wall.new(position, map_position, size)
    end
  end

  def update
    update_player
    update_projectiles
    display_map
    display_ray
  end

  def key_pressed(key)
    case key
      when 'up' then @key_up = true
      when 'down' then @key_down = true
      when 'left' then @key_left = true
      when 'right' then @key_right = true
      when 'space' then @fire = true
    end
  end

  def key_released(key)
    case key
      when 'up' then @key_up = false
      when 'down' then @key_down = false
      when 'left' then @key_left = false
      when 'right' then @key_right = false
      when 'space' then @fire = false; @can_fire = @@global_fire_speed - 1
    end
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

  def self.tile_size
    return @@tile_size
  end

  def self.scale
    return @@map_scale
  end

  private
    def nearest_colision(angle)
      h_colision = (@player.position.y / @@tile_size).floor * @@tile_size
      h_colision += @@tile_size if angle > @@angle180
      v_colision = (@player.position.x / @@tile_size).floor * @@tile_size
      v_colision += @@tile_size if not angle > @@angle90 && angle < @@angle270 
      # puts "Horizontal: [#{@player.position.x.floor}, #{h_colision}] - [#{(@player.position.x / @@tile_size).floor}, #{h_colision / @@tile_size}]"
      # puts "Vertical: [#{v_colision}, #{@player.position.y.floor}] - [#{v_colision / @@tile_size}, #{(@player.position.y / @@tile_size).floor}]"
      
      h_p = Point.new(@player.position.x + (@player.position.y - h_colision) / @@tangents[angle], h_colision)
      h_p.y -= 1  if angle < @@angle180

      h_tmp = h_p / @@map_scale
      Square.new(x: h_tmp.x, y: h_tmp.y, size: 5, color: "red")
      #NEXT HORIZONTAL
      while (check_boundaries(h_p))
        h_p = h_p + @@h_step[angle]
        h_tmp = h_p / @@map_scale
        Square.new(x: h_tmp.x, y: h_tmp.y, size: 5, color: "red")
      end
      Image.new(
        'images/explosion.png',
        x: h_tmp.x - 10,
        y: h_tmp.y - 10,
        height: 20,
        width: 20,
        z: 40,
      )

      v_p = Point.new(v_colision, @player.position.y + (@player.position.x - v_colision) * @@tangents[angle])
      v_p.x -= 1  if angle > @@angle90 && angle < @@angle270
      v_tmp = v_p / @@map_scale
      Square.new(x: v_tmp.x, y: v_tmp.y, size: 5, color: "blue", z: 20)
      #NEXT VERTICAL
      while (check_boundaries(v_p))
        v_p = v_p + @@v_step[angle]
        v_tmp = v_p / @@map_scale
        Square.new(x: v_tmp.x, y: v_tmp.y, size: 5, color: "blue", z: 20)
      end
      Image.new(
        'images/explosion.png',
        x: v_tmp.x - 10,
        y: v_tmp.y - 10,
        height: 20,
        width: 20,
        z: 40,
      )

      800
    end

    def display_ray

      dist = nearest_colision(@player.angle)
      end_line = (@player.position / @@map_scale).add_vec(Vector.new(@player.angle, dist))
      Line.new(
        x1: @player.position.x / @@map_scale, y1: @player.position.y / @@map_scale,
        x2: end_line.x, y2: end_line.y,
        width: 1,
        color: 'lime',
        z: 10
      )
    end

    def update_player
      @player.angle += @@angle5 if @key_right
      @player.angle -= @@angle5 if @key_left
      mag = 0
      mag += @player.speed if @key_up
      mag -= @player.speed if @key_down
      if mag != 0
        new_position = @player.position.add_vec(Vector.new(@player.angle, mag))
        player.position = new_position if check_boundaries(new_position)
      end
      @player.draw
    end

    def update_projectiles
      @can_fire += 1 if @fire
      @@projectiles.append(Projectile.new(@player.position, @player.angle, 20)) if @fire && @can_fire == @@global_fire_speed
      @@projectiles.each do |projectile|
        projectile.update_position
        @@projectiles.delete(projectile) if not check_boundaries(projectile.position)
        projectile.draw
      end
      @can_fire = 0 if @can_fire >= @@global_fire_speed
    end

    def no_solids_here(position)
      @layout.each {|map_elem| return false if (map_elem.solid && map_elem.map_position == position)}
      return true
    end

    #This function right here recieves the Point(x, y) [coordinate] in relation to the tile size
    def check_boundaries(point)
      point = Point.new((point.x / @@tile_size).floor, (point.y / @@tile_size).floor)
      return point.x > 0 && point.y > 0 && point.y < @@map.length && !@@map[point.y].nil? && point.x < @@map[point.y].length && no_solids_here(point)
    end

    def display_map
      @layout.each {|map_elem| map_elem.draw if not map_elem.nil?}
    end
end

g = Game.new

on :key_down do |event|
  if ['up', 'down', 'left', 'right', 'space'].include?(event.key)
    g.key_pressed(event.key)
  end
end

on :key_up do |event|
  if ['up', 'down', 'left', 'right', 'space'].include?(event.key)
    g.key_released(event.key)
  end
end

update do
  clear
  g.update
end

show