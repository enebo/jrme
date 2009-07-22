# Overall area is for sizing size of board * unit_size
# Multiple floors can exist but they all must be rectangular
# All known game types.  See types.rb for more information on live objects
module GameTypes
  BUMPER, DOUBLER, FREEZER, FLOOR, GOAL, PLAYER = ?B, ?D, ?F, ?., ?G, ?P
  CAMERA, NOTHING = ?C, ?;
end

class FloorDim < Struct.new(:reader,:width,:height,:width_index,:height_index)
  include GameTypes

  def inside?(row_index, column_index)
    column_index > width_index && column_index < width_index + width &&
      row_index > height_index && row_index < height_index + height
  end

  # Calculates center of floor as boxes in JME are center of area + extent 
  def floor_location_extent
    x, width_m = reader.to_m(width_index), reader.to_m(width)
    center_x = x + width_m / 2
    z, height_m = reader.to_m(height_index), reader.to_m(height)
    center_z = z + height_m / 2
    y = 10.m
    nub = reader.to_m(0.5) # A 0 index will render on edge of board shift 1/2u
    return [center_z - nub, -3.m, center_x - nub], [height_m / 2, y, width_m / 2]
  end

  def location(i, j, k)
    return reader.to_m(i), reader.to_m(j), reader.to_m(k)
  end

  def load
    width_index.upto(width_index + width - 1) do |j|
      height_index.upto(height_index + height - 1) { |i| process(i, j, 0.m) }
    end
    Floor.new(*floor_location_extent)
  end

  def process(i, j, k)
    case reader.at(i, j)
    when BUMPER: reader.add_obstacle Bumper.new(location(i, k, j))
    when DOUBLER: reader.add_obstacle Doubler.new(location(i, k + 7.m, j))
    when FREEZER: reader.add_obstacle Freezer.new(location(i, k, j))
    when GOAL: reader.add_obstacle Goal.new(location(i, k, j))
    when PLAYER: reader.player = Player.new(location(i, k + 7.m, j))
    when CAMERA: reader.camera = Camera.new(location(i, k, j))
    end
  end
end

class Level
  UNIT = 32
  include GameTypes
  attr_accessor :player, :camera, :floors, :obstacles

  def initialize(game, level=1)
    map_file = "#{File.dirname(__FILE__)}/levels/#{level}"
    @game, @lines, @floors, @obstacles = game, File.readlines(map_file), [], []
    load_from_mapfile
    setup
  end

  def add_obstacle(obstacle)
    @obstacles << obstacle
  end

  def at(x, y)
    @lines[x][y]
  end

  def to_m(value)
    (value.to_f * UNIT).m
  end

  def load_from_mapfile
    # Find rectangular floor dimensions first
    floor_dims, i = [], 0
    while i < @lines.length - 1
      if @lines[i] =~ /^(;*)([^;]+);*\n$/
        width_index, width, height_index = $1.length, $2.length, i
        height = find_floor_end(height_index, width / 2)
        floor_dims << FloorDim.new(self, width, height - height_index, 
                                   width_index, height_index)
        i = height
      end
      i += 1
    end

    floor_dims.each { |floor_dim| @floors << floor_dim.load }
  end

  def setup
    root, action = @game.root_node, @game.collision_action
    root << @game.icecube = player.create_physics(@game)
    @game.cam.location = Vector3f *camera.location
    @game.chaser = camera.create_physics(@game)
    floors.each { |floor| root << floor.create_physics(@game, action) }
    obstacles.each { |obstacle| root << obstacle.create_physics(@game, action) }
  end

  def find_floor_end(start, index)
    start.upto(@lines.length-1) { |i| return i if @lines[i][index] == NOTHING }
    @lines.length
  end
end
