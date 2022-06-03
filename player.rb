###############################
#  .    N   .  #   .  090   . #
#    .  | .    #     . |  .   #
#  W -  * - E  # 180 - * - 0  #
#    .  | .    #     . |  .   #
#  .    S   .  #   .  270   . #
###############################
class Player
  attr_accessor :position
  attr_reader   :angle

  def initialize(position, angle = 0)
    @position = position
    @angle = 0
  end

  def angle=(angle)
    @angle = angle % Game.angle360
    @angle = Game.angle360 + angle if angle < 0
  end

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