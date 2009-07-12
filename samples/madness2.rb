# 0. Make whole level data-driven
# 1. Make flash a class that supports timed operations
# 2. Make level transition code with timed level changing

require 'jme'
require 'jmephysics'
require 'yaml'
require 'types'

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
    collided_with(event.trigger_data).execute
  end
end

class Madness < SimplePhysicsGame
  LEVEL_SIZE, START, CUBE_SIZE = 400.m, [370.m, 100.m, 370.m], 4.m
  CAMERA_START = [400.m, 100.m, 400.m]
  LOSE_MESSAGE = "You Lose!"
  LEVELS_DIR = __FILE__.sub(/.rb$/, '') + "/levels"

  attr_reader :icecube

  def simpleInitGame
    @velocity_holder = Vector3f.new
    [create_sky, create_icecube, create_level, create_keybindings]
    [create_camera, create_status]

    @time = 0.0
    physics_space.add_to_update_callbacks do |space, time|
      if @time > 0.5
        if @icecube.scale.x < 1.mm
          finish LOSE_MESSAGE
        else
          @icecube.scale @icecube.scale.x - 5.cm
          @time = 0.0
        end
      end
      @time += time
    end
  end

  def simpleUpdate
    @chaser.update tpf # update chase camera for moving icecube
    @info_text.value = "Velocity: #{@icecube.get_linear_velocity(@velocity_holder)}"
    finish LOSE_MESSAGE if @icecube.local_translation.y < -20
  end

  def reset
    cam.location = Vector3f *CAMERA_START
    @icecube.at *START
    @icecube.set_linear_velocity(Vector3f(0,0,0))
    @icecube.set_angular_velocity(Vector3f(0,0,0))
    @icecube.scale CUBE_SIZE
    flash ""
  end

  def flash(message)
    @flash_text.value = message
  end

  def finish(message)
    flash message
    self.pause = true
  end

  def create_level(level=1)
    obstacle_action = ObstacleAction.new self
    YAML.load_file("#{LEVELS_DIR}/#{level}.yml").each do |obstacle| 
      root_node << obstacle.create_physics(self, obstacle_action)
    end
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
    cam.location = Vector3f *CAMERA_START

    # set up our chase camera so we can follow the icecube
    @chaser = ChaseCamera.create(cam, @icecube.geometry) do
      mouse_look.min_roll_out, mouse_look.max_roll_out = 12.m, 24.m
      mouse_look.max_ascent = 45.deg_in_rad
      damping_k, spring_k = 36.m, 16.m
      min_distance, max_distance = 256.m, 128.m      
      set_ideal_sphere_coords Vector3f(40, 0, 35.deg_in_rad)
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
    root_node << Skybox.new("sky", 1000.m,1000.m,1000.m, "/data/skyboxes/mountains/")
  end

  def create_status
    stat_node << @flash_text=Text.create_default_text_label("flash", LOSE_MESSAGE)
    @flash_text.local_scale = 5
    @flash_text.local_translation.set settings.width/2 - @flash_text.width/2, settings.height/2, 0
    @flash_text.text_color = ColorRGBA.white
    flash ""
    stat_node << @info_text =Text.create_default_text_label("info", "Velocity:")
    @info_text.local_translation.set 0, 10, 0
  end

  def keybinding(key, action)
    input.add_action action, InputHandler::DEVICE_KEYBOARD, key, InputHandler::AXIS_NONE, false
  end
end

Madness.new.start
