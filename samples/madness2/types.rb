class Obstacle
  attr_accessor :location

  def initialize(location=nil, scale=nil)
    @location = location
  end

  def in_meters(value)
    value.map { |e| e.m }
  end
end

class Goal < Obstacle
  def create_physics(game, collision_action)
    loc = in_meters(location)
    game.physics_space.create_static do
      collision { game.finish("  Goal!!") }
      geometry Sphere('Goal', 16, 16, 16.m)
      made_of Material::IRON
      color ColorRGBA.red
      at *loc
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Freezer < Obstacle
  def create_physics(game, collision_action)
    loc = in_meters(location)
    game.physics_space.create_static do
      collision { game.icecube.scale Madness::CUBE_SIZE }
      geometry Sphere('Freezer', 16, 16, 16.m)
      made_of Material::RUBBER
      color ColorRGBA.blue
      at *loc
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Bumper < Obstacle
  def create_physics(game, collision_action)
    loc = in_meters(location)
    game.physics_space.create_static do
      geometry Sphere('Bumper', 16, 16, 16.m)
      made_of Material::RUBBER
      color ColorRGBA.yellow
      at *loc
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Doubler < Obstacle
  def create_physics(game, collision_action)
    loc = in_meters(location)
    game.physics_space.create_dynamic do
      geometry Sphere('Bumper', 16, 16, 4.m)
      made_of Material::IRON
      color ColorRGBA.yellow
      at *loc
      collision do
        # We may register multiple collision events.  Make sure only
        # first one grows the cube.
        unless @hit
          game.root_node.detach_child(self)  # Remove from scene graph
          set_active false                   # No longer to be used in physics
          old_size = game.icecube.scale.x
          new_size =  old_size * 2
          game.icecube.scale new_size
          # move bigger cube up so it fits nicely on level
          game.icecube.local_translation.y += new_size - old_size
          @hit = true
        end
      end
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Floor < Obstacle
  attr_reader :size, :texture, :texture_scale

  def create_physics(game, collision_action)
    siz, loc, tex, tsc = in_meters(size), in_meters(location), texture, texture_scale
    game.physics_space.create_static do
      geometry(Box.new("floor", Vector3f.new, *siz)).texture(tex, Vector3f(*tsc))
      made_of Material::RUBBER
      at *loc
    end
  end
end
