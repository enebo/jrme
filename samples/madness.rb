require 'jme'
require 'jmephysics'

class MoveAction < InputAction
  def initialize(mobile, direction)
    super()
    @mobile, @direction = mobile, direction
  end

  def performAction(event)
    @mobile.add_force @direction if event.trigger_pressed
  end
end

class Madness < SimplePhysicsGame
  LEVEL_UNIT_SIZE = 1
  LEVEL_DIMENSION = LEVEL_UNIT_SIZE * 100

  def simpleInitGame
    [create_level, create_icecube, create_camera, create_status, create_keybindings]
  end

  def simpleUpdate
    @chaser.update tpf # update chase camera for moving icecube

    @info_text.text.length = 0
    @v ||= Vector3f.new
    @info_text.text.append "Velocity: #{@icecube.get_linear_velocity(@v)}"
  end

  def create_level
    root_node << @floor = physics_space.create_static do
      geometry(Box.new("floor", Vector3f.new, LEVEL_DIMENSION, 0.25, LEVEL_DIMENSION)).texture("data/texture/wall.jpg", Vector3f.new(30, 30, 30))
    end
  end

  def create_icecube
    root_node << @icecube = physics_space.create_dynamic do
      geometry Cube.new("Icecube", Vector3f.new, LEVEL_UNIT_SIZE)
      made_of Material::ICE
      texture "data/images/Monkey.jpg"
      at LEVEL_DIMENSION / 2, 1.25, LEVEL_DIMENSION / 2
    end

    @cube = @icecube.get_child(0)  # visual representation
  end

  def create_camera
    props = java.util.HashMap.new
    props.put ThirdPersonMouseLook::PROP_MAXROLLOUT, "6"
    props.put ThirdPersonMouseLook::PROP_MINROLLOUT, "3"
    props.put ThirdPersonMouseLook::PROP_MAXASCENT, "#{45 * FastMath::DEG_TO_RAD}"
    props.put ChaseCamera::PROP_INITIALSPHERECOORDS, Vector3f(5, 0, 30 * FastMath::DEG_TO_RAD)
    props.put ChaseCamera::PROP_DAMPINGK, "4"
    props.put ChaseCamera::PROP_SPRINGK, "9"
# Once my HashMap -> Map patch gets accepted I can use this:
#     props = {ThirdPersonMouseLook::PROP_MAXROLLOUT => "6",
#       ThirdPersonMouseLook::PROP_MINROLLOUT => "3",
#       ThirdPersonMouseLook::PROP_MAXASCENT => "#{45 * FastMath::DEG_TO_RAD}",
#       ChaseCamera::PROP_INITIALSPHERECOORDS => Vector3f.new(5, 0, 30 * FastMath::DEG_TO_RAD),
#       ChaseCamera::PROP_DAMPINGK => "4",
#       ChaseCamera::PROP_SPRINGK => "9"
#     }

    @chaser = ChaseCamera.new(cam, @cube, props)
    @chaser.max_distance = 64
    @chaser.min_distance = 32
  end

  def create_keybindings
    mag = 700
    keybinding(KeyInput::KEY_J, MoveAction.new(@icecube, Vector3f(-mag, 0, 0)))
    keybinding(KeyInput::KEY_K, MoveAction.new(@icecube, Vector3f(mag, 0, 0)))
    keybinding(KeyInput::KEY_H, MoveAction.new(@icecube, Vector3f(0, 0, -mag)))
    keybinding(KeyInput::KEY_L, MoveAction.new(@icecube, Vector3f(0, 0, mag)))
  end

  def keybinding(key, action)
    input.add_action action, InputHandler::DEVICE_KEYBOARD, key, 
       InputHandler::AXIS_NONE, false
  end

  def create_status
    @info_text = Text.create_default_text_label "info", "Velocity:"
    @info_text.local_translation.set 0, 20, 0
    stat_node << @info_text
  end
end

Madness.new.start
