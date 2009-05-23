require 'jme'
require 'jmephysics'

class MoveAction < InputAction
  ZERO = Vector3f.new 0, 0, 0

  def initialize(player, direction)
    super()
    @player, @direction = player, direction
  end

  def performAction(event)
    if event.trigger_pressed  # key goes down - apply motion
      @player.material.surface_motion = @direction
    else                      # key goes up - stand still
      @player.material.surface_motion = ZERO
      # note: for a game we usually won't want zero motion on key release but be able to combine keys in some way
    end
  end
end

class OnFloorAction < InputAction
  def initialize(game)
    super()
    @game = game
  end
  
  def performAction(event)
    contact_info = event.trigger_data
    @game.player_on_floor = true if contact_info.node1 == @game.floor || contact_info.node2 == @game.floor
  end
end

class Lesson8 < SimplePhysicsGame
  attr_accessor :player_on_floor, :floor

  def simpleInitGame
    # no magic here - just create a floor in that method
    create_floor

    # second we create a box - as we create multiple boxes this time the code moved into a separate method
    # to move the player around we create a special material for it and apply surface motion on it
    @player = create_box([8,1,0], Material.new("player material")) do |box|
      box.name = "player"
      color box, ColorRGBA.blue
      box.center_of_mass = Vector3f.new 0, -0.5, 0 # lower center of mass to land on its 'feet'
    end

    # we map the MoveAction to the keys DELETE and PAGE DOWN for forward and backward
    input.add_action MoveAction.new(@player, Vector3f.new(-7, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_I, InputHandler::AXIS_NONE, false
    input.add_action MoveAction.new(@player, Vector3f.new(7, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_K, InputHandler::AXIS_NONE, false

    @player_on_floor = false

    # now the player should be able to jump
    # we do this by applying a single force vector when the HOME key is pressed
    # this should happen only while the player is touching the floor (we determine that below)
    jump = proc do |event|
      @player.add_force Vector3f.new(0, 500, 0) if player_on_floor && event.trigger_pressed
    end

    input.add_action jump, InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_SPACE, InputHandler::AXIS_NONE, false

    # ok finally detect when the player is touching the ground:
    # a simple way to do this is making a boolean variable (playerOnFloor) which is
    # set to true on collision with the floor and to false before each physics computation

    # collision events analoguous to Lesson8
    player_collision_event_handler = @player.collision_event_handler
    input.add_action OnFloorAction.new(self), player_collision_event_handler, false

    # and a very simple callback to set the variable to false before each step
    physics_space.add_to_update_callbacks { |space, time| player_on_floor = false }

    # finally print a key-binding message
    info_text = Text.create_default_text_label "key info", "[del] and [page down] to move, [home] to jump"
    info_text.local_translation.set 0, 20, 0
    stat_node << info_text
  end

  def create_floor
    # first we will create the floor like in Lesson3, but put into into a field
    @floor = physics_space.create_static_node
    root_node << @floor
    model = BinaryImporter.new.load resource("data/model/bike.jme").openStream
    model.model_bound = BoundingBox.new
    model.update_model_bound
    @floor << model
    @floor.generate_physics_geometry

#     visual_floor_box = Box.new "floor", Vector3f.new, 5, 0.25, 5
#     @floor << visual_floor_box
#     # and not that steep
#     visual_floor_box.local_rotation.fromAngleNormalAxis 0.1, Vector3f.new(0, 0, -1)
#     visual_floor_box2 = Box.new "floor", Vector3f.new, 5, 0.25, 5
#     @floor << visual_floor_box2
#     visual_floor_box2.local_translation.set(9.7, -0.5, 0)
#     # and another one a bit on the left
#     visual_floor_box3 = Box.new "floor", Vector3f.new, 5, 0.25, 5
#     @floor << visual_floor_box3
#     visual_floor_box3.local_translation.set(-11, 0, 0)
#     @floor.generate_physics_geometry
  end

  def color(spatial, color)
    renderer = display.renderer
    material_state = renderer.createMaterialState.set! :diffuse => color

    if color.a < 1
        blend_state = renderer.createBlendState.set! :enabled => true,
          :blend_enabled => true,
          :source_function => BlendState::SourceFunction::SourceAlpha,
          :destination_function => BlendState::DestinationFunction::OneMinusSourceAlpha
        spatial.setRenderState blend_state
        spatial.setRenderQueueMode Renderer::QUEUE_TRANSPARENT
    end
    spatial.setRenderState material_state
  end

  def create_box(location, material=Material::DEFAULT)
    dynamic_node = physics_space.create_dynamic_node
    root_node << dynamic_node
    dynamic_node << Box.new("falling box", Vector3f.new, 0.5, 0.5, 0.5)
    dynamic_node.generate_physics_geometry
    dynamic_node.local_translation.set(*location)    # Where is it at
    dynamic_node.material = material                 # Set the material it is made of
    dynamic_node.compute_mass                        # compute mass from density
    yield dynamic_node if block_given?
    dynamic_node
  end

  def simpleUpdate
    # move the cam where the player is
    cam.location.x = @player.local_translation.x;
    cam.update
  end
end

Lesson8.new.start
