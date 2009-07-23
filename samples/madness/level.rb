# Overall area is for sizing size of board * unit_size
# Multiple floors can exist but they all must be rectangular
# All known game types.  See types.rb for more information on live objects
module GameTypes
  BUMPER, DOUBLER, FREEZER, GOAL, PLAYER, CAMERA = ?B, ?D, ?F, ?G, ?P, ?C
end

class FloorDim < Struct.new(:level, :width, :height, :x, :y, :lines)
  include GameTypes

  # Calculates center of floor as boxes in JME are center of area + extent 
  def floor_location_extent
    x, width_m = level.to_m(x), level.to_m(width)
    center_x = x + width_m / 2
    z, height_m = level.to_m(y), level.to_m(height)
    center_z = z + height_m / 2
    y = 10.m
    nub = level.to_m(0.5) # A 0 index will render on edge of board shift 1/2u
    return [center_z - nub, -3.m, center_x - nub], [height_m / 2, y, width_m / 2]
  end

  def location(i, j, k)
    return level.to_m(i), level.to_m(j), level.to_m(k)
  end

  def load
    0.upto(width - 1) { |j| 0.upto(height - 1) { |i| process(i, j, 0.m) } }

    Floor.new *floor_location_extent
  end

  def process(i, j, k)
    ai, aj, ak = i + y, j + x, k
    case lines[i][j]
    when BUMPER: level.obstacles << Bumper.new(location(ai, ak, aj))
    when DOUBLER: level.obstacles << Doubler.new(location(ai, ak + 7.m, aj))
    when FREEZER: level.obstacles << Freezer.new(location(ai, ak, aj))
    when GOAL: level.obstacles << Goal.new(location(ai, ak, aj))
    when PLAYER: level.player = Player.new(location(ai, ak + 7.m, aj))
    when CAMERA: level.camera = Camera.new(location(ai, ak, aj))
    end
  end
end

class Level
  UNIT, DEFAULT_SKYBOX = 32, "data/texture/wall.jpg"
  include GameTypes
  attr_accessor :player, :camera, :skybox, :floors, :obstacles

  def initialize(game, level=1)
    data = eval File.readlines("#{File.dirname(__FILE__)}/levels/#{level}").join('')
    @skybox = data[:skybox] ? data[:skybox] : DEFAULT_SKYBOX
    @game, @lines, @floors, @obstacles = game, [], [], []
    process_floors(data)
    setup
  end

  def to_m(value)
    (value.to_f * UNIT).m
  end

  def process_floors(data)
    data[:floors].each do |floor_description|
      lines = floor_description[:data].split(/\n/)
      width, x = lines[0].length, floor_description[:location][0]
      height, y = lines.length, floor_description[:location][1]
      puts "DATA #{floor_description[:data]} (#{x}, #{y}), #{width}x#{height}"
      @floors << FloorDim.new(self, width, height, x, y, lines).load
    end
  end

  def setup
    root, action = @game.root_node, @game.collision_action
    root << @game.icecube = player.create_physics(@game)
    @game.cam.location = Vector3f *camera.location
    @game.chaser = camera.create_physics(@game)
    floors.each { |floor| root << floor.create_physics(@game, action) }
    obstacles.each { |obstacle| root << obstacle.create_physics(@game, action) }
  end
end
