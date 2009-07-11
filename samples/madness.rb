# 1. Make skybox follow camera
# 2. Do you win/you lose + graphics

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
  def initialize(game)
    super()
    @game = game
  end

  def collided_with(contact)
    @game.icecube == contact.node1 ? contact.node2 : contact.node1
  end

  def performAction(event)
    case collided_with(event.trigger_data).geometry.name
      when "freezer":
        @game.icecube.geometry.scale Madness::CUBE_SIZE
      when "goal":
        @game.finish "You won!"
    end
  end
end

class Madness < SimplePhysicsGame
  LEVEL_SIZE, START, CUBE_SIZE = 400.m, [370.m, 100.m, 370.m], 4.m

  attr_reader :icecube

  def simpleInitGame
    @velocity_holder = Vector3f.new
    [create_sky, create_icecube, create_level, create_keybindings]
    [create_camera, create_status]

    @time = 0.0
    physics_space.add_to_update_callbacks do |space, time|
      if @time > 0.5
        if @icecube.geometry.local_scale.x < 1.mm
          finish "You Lose!"
        else
          @icecube.geometry.scale @icecube.geometry.local_scale.x - 5.cm
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
    @icecube.at *START
    @icecube.set_linear_velocity(Vector3f(0,0,0))
    @icecube.set_angular_velocity(Vector3f(0,0,0))
    @icecube.geometry.scale CUBE_SIZE
  end

  def finish(message)
    @info_text.value = message
    self.pause = true
  end

  def create_obstacle(details)
    handler = input
    obstacle_action = ObstacleAction.new self
    color_for = {'freezer' => ColorRGBA.blue, 'bumper' => ColorRGBA.yellow, 'goal' => ColorRGBA.red}

    root_node << physics_space.create_static do
      geometry Sphere(details['type'], 16, 16, 16.m)
      made_of Material::IRON
      color color_for[details['type']]
      at details['x'].m, -6.m, details['z'].m
      handler.add_action obstacle_action, collision_event_handler, false
    end
  end

  def create_level(level=1)
    root_node << @floor = physics_space.create_static do
      geometry(Box.new("floor", Vector3f.new, LEVEL_SIZE, 1.m, LEVEL_SIZE)).texture("data/texture/wall.jpg", Vector3f.new(30, 30, 30))
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2*LEVEL_SIZE, 600.m, 2.m)
      at 0, 30.m, LEVEL_SIZE
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2*LEVEL_SIZE, 600.m, 2.m)
      at 0, 30.m, -LEVEL_SIZE
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2.m, 600.m, 2*LEVEL_SIZE)
      at LEVEL_SIZE, 30.m, 0
    end
    root_node << physics_space.create_static do
      create_box("wall").scale(2.m, 600.m, 2*LEVEL_SIZE)
      at -LEVEL_SIZE, 30.m, 0
    end

    YAML.load_file(File.dirname(__FILE__) + 
                   "/madness/levels/#{level}.yml").each {|o| create_obstacle o }
  end

  def create_icecube
    root_node << @icecube = physics_space.create_dynamic do
      geometry Cube("Icecube", CUBE_SIZE)
      made_of Material::ICE
      texture "data/images/Monkey.jpg"
      at *START
    end
  end

  def create_camera
    # Reposition camera behind icecube initially
    cam.location = Vector3f(390, 10, 390)

    # set up our chase camera so we can follow the icecube
    @chaser = ChaseCamera.create(cam, @icecube.geometry) do
      mouse_look.min_roll_out, mouse_look.max_roll_out = 12.m, 24.m
      mouse_look.max_ascent = 45.deg_in_rad
      damping_k, spring_k = 36.m, 16.m
      min_distance, max_distance = 256.m, 128.m      
      set_ideal_sphere_coords Vector3f(20, 0, 35.deg_in_rad)
    end
  end

  def create_keybindings
    KeyBindingManager.key_binding_manager.remove ["toggle_lights", "mem_report"]
    mag = 700
    north, south, west, east = Vector3f(-mag, 0, 0), Vector3f(mag, 0, 0),
      Vector3f(0, 0, -mag), Vector3f(0, 0, mag)

    keybinding(KeyInput::KEY_J, MoveAction.new(@icecube, north))
    keybinding(KeyInput::KEY_K, MoveAction.new(@icecube, south))
    keybinding(KeyInput::KEY_H, MoveAction.new(@icecube, west))
    keybinding(KeyInput::KEY_L, MoveAction.new(@icecube, east))
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
