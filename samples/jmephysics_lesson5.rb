require 'jme'
require 'jmephysics'

# The action get the node it should move and the direction it should move in.
class MyInputAction < InputAction
  def initialize(sphere, direction)
    super()
    @sphere, @applied_force, @direction = sphere, Vector3f.new, direction
  end

  def performAction(event)
    @applied_force.set(@direction).mult_local event.time
    @sphere.add_force @applied_force  # apply a force to the sphere
  end
end

class Lesson5 < SimplePhysicsGame
  STARTING_POINT = [0, 5, 0]

  def simpleInitGame
    root_node << physics_space.create_static do                # The floor
      create_box("floor").scale(20, 0.5, 20)
    end

    root_node << @sphere = physics_space.create_dynamic do     # The sphere
      create_sphere("sphere")
      at *STARTING_POINT
    end

    # A force must be applied at each physics step if you want constant force.
    # Here we create an input handler that gets invoked each physics step
    handler = InputHandler.new
    physics_space.add_to_update_callbacks { |space, time| handler.update time }

    # now we add an input actions to move the sphere while a key is pressed
    # note: as the input handler gets updated each physics step the force is
    # framerate independent - we can't use the normal input handler here!
    handler.add_action MyInputAction.new(@sphere, Vector3f.new(70, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_HOME, InputHandler::AXIS_NONE, true
    handler.add_action MyInputAction.new(@sphere, Vector3f.new(-70, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_END, InputHandler::AXIS_NONE, true

    self.show_physics = true  # cool physics stuff displayed
  end

  def simpleUpdate
    # If the sphere falls off the floor we will reset it to STARTING_POINT
    if @sphere.world_translation.y < -20
      @sphere.clear_dynamics             # clear speed and forces
      @sphere.at(*STARTING_POINT)        # then put it over the floor again
    end
  end
end

Lesson5.new.start if $0 == __FILE__
