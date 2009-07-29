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
    i, width_m = level.to_m(x), level.to_m(width)
    center_i = i + width_m / 2
    j, height_m = level.to_m(y), level.to_m(height)
    center_j = j + height_m / 2
    k = 10.m
    nub = level.to_m(0.5) # A 0 index will render on edge of board shift 1/2u
    return [center_j - nub, -3.m, center_i - nub], [height_m / 2, k, width_m / 2]
  end

  def location(i, j, k)
    return level.to_m(i), level.to_m(j), level.to_m(k)
  end

  def load
    0.upto(width - 1) { |j| 0.upto(height - 1) { |i| process(i, j, 0.m) } }

    Floor.create level.game, level.game.collision_action, *floor_location_extent
  end

  def process(i, j, k)
    ai, aj, ak = i + y, j + x, k
    g, o = level.game, level.game.collision_action
    
    case lines[i][j]
    when BUMPER: level.obstacles << Bumper.create(g, location(ai, ak, aj), o)
    when DOUBLER: level.obstacles << Doubler.create(g, location(ai, ak + 7.m, aj), o)
    when FREEZER: level.obstacles << Freezer.create(g, location(ai, ak, aj), o)
    when GOAL: level.obstacles << Goal.create(g, location(ai, ak, aj), o)
    when PLAYER: level.player = Player.create(g, location(ai, ak + 7.m, aj))
    when CAMERA: level.camera_location = location(ai, ak, aj)
    end
  end
end

class Level
  UNIT, DEFAULT_SKYBOX = 32, "data/texture/wall.jpg"
  include GameTypes
  attr_accessor :player, :camera, :skybox, :floors, :obstacles, :game
  attr_accessor :camera_location

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
    data[:floors].each do |floor|
      lines = floor[:data].split(/\n/)
      width, height, x, y, z = lines[0].length, lines.length, *floor[:location]
      @floors << FloorDim.new(self, width, height, x, y, lines).load
    end
  end

  def setup
    root, action = @game.root_node, @game.collision_action
    root << @game.icecube = player
    @game.cam.location = Vector3f *camera_location
    @game.chaser = Camera.create(@game, camera_location)
    floors.each { |floor| root << floor }
    obstacles.each { |obstacle| root << obstacle }
    root << Skybox.new("sky", 1000.m,1000.m,1000.m, skybox)
  end
end
