class Player
  def self.create(game, location)
    game.physics_space.create_dynamic(:location => location) do
      geometry MultiFaceCube("Icecube", Madness::CUBE_SIZE)
      made_of Material::ICE
      texture "data/nekobean_smile.png"
      at *options[:location]
    end
  end
end

class Camera
  def self.create(game, location)
    ChaseCamera.create(game.cam, game.icecube.geometry) do
      mouse_look.min_roll_out, mouse_look.max_roll_out = 12.m, 24.m
      mouse_look.max_ascent = 45.deg_in_rad
      damping_k, spring_k = 36.m, 16.m
      min_distance, max_distance = 256.m, 128.m      
      set_ideal_sphere_coords Vector3f(40, 0, 35.deg_in_rad)
    end
  end
end

class Goal
  def self.create(game, location, collision_action)
    game.physics_space.create_static(:location => location) do
      collision { game.finish("  Goal!!") }
      geometry Sphere('Goal', 16.samples, 16.samples, 16.m)
      made_of Material::IRON
      color ColorRGBA.red
      at *options[:location]
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Freezer
  def self.create(game, location, collision_action)
    game.physics_space.create_static(:location => location) do
      collision { game.icecube.scale Madness::CUBE_SIZE }
      geometry Sphere('Freezer', 16.samples, 16.samples, 16.m)
      made_of Material::ICE
      color ColorRGBA.blue
      at *options[:location]
      game.input.add_action collision_action, collision_event_handler, false
    end
  end
end

class Bumper
  def self.create(game, location, collision_action)
    game.physics_space.create_static(:location => location) do
      geometry Dome.new('Bumper', 16.samples, 16.samples, 16.m)
      made_of Material::RUBBER
      color ColorRGBA.yellow
      at *options[:location]
    end
  end
end

class Doubler
  def self.create(game, location, collision_action)
    game.physics_space.create_dynamic(:location => location) do
      geometry Sphere('Bumper', 16.samples, 16.samples, 4.m)
      made_of Material::RUBBER
      color ColorRGBA.yellow
      at *options[:location]
      collision do   # We may see multiple collision events.  
        unless @hit  # Only first one should work.
          game.root_node.detach_child(self)  # Remove doubler from scene graph
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

class Floor
  def self.create(game, collision_action, location, size)
    @node = game.physics_space.create_static(:location => location, :texture => "data/texture/wall.jpg", :texture_scale => [30, 30, 30]) do
      geometry(Box.new("floor", Vector3f.new, *size)).texture(options[:texture], Vector3f(*options[:texture_scale]))
      made_of Material::RUBBER
      at *options[:location]
    end
  end
end
