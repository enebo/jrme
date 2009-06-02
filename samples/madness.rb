# 1. Make skybox follow camera
# 2. Do you win/you lose + graphics
# 3. change original chase camera location

require 'jme'
require 'jmephysics'
require 'yaml'

class MoveAction < InputAction
  def initialize(mobile, direction)
    super()
    @mobile, @direction = mobile, direction
  end

  def performAction(event)
    @mobile.add_force @direction if event.trigger_pressed
  end
end

class ObstacleAction < InputAction
  def initialize(game, cube)
    super()
    @game, @cube = game, cube
  end

  def performAction(event)
    contact_info = event.trigger_data

    # We want static node that we collide with so we can ask what it is.
    if contact_info.node2.kind_of? DynamicPhysicsNode 
      obstacle = contact_info.node1
    elsif contact_info.node1.kind_of? DynamicPhysicsNode 
      obstacle = contact_info.node2
    end

    case obstacle.get_child(0).name
      when "freezer":
        @cube.scale Madness::CUBE_SIZE
      when "goal":
        @game.finish "You won!"
    end
  end
end

class Madness < SimplePhysicsGame
  LEVEL_SIZE = 400.m
  START = 370.m, 100.m, 370.m
  CUBE_SIZE = 4.m

  def simpleInitGame
    @velocity_holder = Vector3f.new
    [create_sky, create_level, create_icecube, create_keybindings]
    [create_obstacles, create_camera, create_status]

    @time = 0.0
    physics_space.add_to_update_callbacks do |space, time|
      if @time > 0.5
        if @cube_geom.local_scale.x < 1.mm
          finish "You Lose!"
        else
          @cube_geom.scale @cube_geom.local_scale.x - 5.cm
          @time = 0.0
        end
      end
      @time += time
    end
  end

  def simpleUpdate
    @chaser.update tpf # update chase camera for moving icecube

    @info_text.value = "Velocity: #{@icecube.get_linear_velocity(@velocity_holder)}"
  end

  def reset
    self.pause = true
    @icecube.at *START
    @cube_geom.scale CUBE_SIZE
  end

  def finish(message)
    @info_text.value = message
    self.pause = true
  end

  def create_obstacle(details)
    handler = input
    obstacle_action = ObstacleAction.new self, @cube_geom
    color_for = {'freezer' => ColorRGBA.blue, 'bumper' => ColorRGBA.yellow, 'goal' => ColorRGBA.red}

    root_node << physics_space.create_static do
      geometry Sphere(details['type'], 16, 16, 16.m)
      made_of Material::IRON
      color color_for[details['type']]
      at details['x'].m, -6.m, details['z'].m
      handler.add_action obstacle_action, collision_event_handler, false
    end
  end

  def create_level
    root_node << @floor = physics_space.create_static do
      geometry(Box.new("floor", Vector3f.new, LEVEL_SIZE, 1.m, LEVEL_SIZE)).texture("data/texture/wall.jpg", Vector3f.new(30, 30, 30))
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2*LEVEL_SIZE, 60.m, 2.m)
      at 0, 30.m, LEVEL_SIZE
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2*LEVEL_SIZE, 60.m, 2.m)
      at 0, 30.m, -LEVEL_SIZE
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2.m, 60.m, 2*LEVEL_SIZE)
      at LEVEL_SIZE, 30.m, 0
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2.m, 60.m, 2*LEVEL_SIZE)
      at -LEVEL_SIZE, 30.m, 0
    end
  end

  def create_obstacles
    YAML.load_file(File.dirname(__FILE__) + "/madness/levels/1.yml").each do |o|
      create_obstacle o
    end
  end

  def create_icecube
    root_node << @icecube = physics_space.create_dynamic do
      geometry Cube("Icecube", CUBE_SIZE)
      made_of Material::ICE
      texture "data/images/Monkey.jpg"
      at *START
    end
    @cube_geom = @icecube.get_child(0)
  end

  def create_camera
    options = {ThirdPersonMouseLook::PROP_MAXROLLOUT => 24.m.to_s,
      ThirdPersonMouseLook::PROP_MINROLLOUT => 12.m.to_s,
      ThirdPersonMouseLook::PROP_MAXASCENT => 45.deg_in_rad.to_s,
      ChaseCamera::PROP_INITIALSPHERECOORDS => Vector3f.new(5,0, 35.deg_in_rad),
      ChaseCamera::PROP_DAMPINGK => 16.m.to_s,
      ChaseCamera::PROP_SPRINGK => 36.m.to_s
    }

    @chaser = ChaseCamera.new(cam, @cube_geom, options)
    @chaser.min_distance, @chaser.max_distance = 128.m, 256.m
  end

  def create_keybindings
    KeyBindingManager.key_binding_manager.remove ["toggle_lights", "mem_report"]
    mag = 700
    keybinding(KeyInput::KEY_J, MoveAction.new(@icecube, Vector3f(-mag, 0, 0)))
    keybinding(KeyInput::KEY_K, MoveAction.new(@icecube, Vector3f(mag, 0, 0)))
    keybinding(KeyInput::KEY_H, MoveAction.new(@icecube, Vector3f(0, 0, -mag)))
    keybinding(KeyInput::KEY_L, MoveAction.new(@icecube, Vector3f(0, 0, mag)))
    keybinding(KeyInput::KEY_R, proc { |event| reset })
  end

  def create_sky
    root_node << Skybox.new("skybox", 500.m, 500.m, 500.m,
       "data/texture/north.jpg", "data/texture/south.jpg",
       "data/texture/east.jpg", "data/texture/west.jpg",
       "data/texture/top.jpg", "data/texture/bottom.jpg")
  end

  def create_status
    stat_node << @info_text =Text.create_default_text_label("info", "Velocity:")
    @info_text.local_translation.set 0, 20, 0
  end

  def keybinding(key, action)
    input.add_action action, InputHandler::DEVICE_KEYBOARD, key, InputHandler::AXIS_NONE, false
  end
end

Madness.new.start
