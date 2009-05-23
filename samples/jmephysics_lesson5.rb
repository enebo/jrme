require 'jme'
require 'jmephysics'


# The action get the node it should move and the direction it should move in.
class MyInputAction < InputAction
  def initialize(dynamic_node, direction)
    super()
    @dynamic_node = dynamic_node
    @applied_force = Vector3f.new
    @direction = direction
  end

  def performAction(event)
    @applied_force.set(@direction).mult_local event.time
    # the really important line: apply a force to the moved node
    @dynamic_node.add_force @applied_force
  end
end

class Lesson5 < SimplePhysicsGame
  STARTING_POINT = [0, 5, 0]

  def simpleInitGame
    # first we will create a floor and sphere like in Lesson4
    static_node = physics_space.create_static_node
    root_node << static_node
    floor_box = static_node.create_box "floor"
    floor_box.local_scale.set 100, 0.5, 100
    @dynamic_node = physics_space.create_dynamic_node
    root_node << @dynamic_node
    @dynamic_node.create_sphere "rolling sphere"
    @dynamic_node.local_translation.set(*STARTING_POINT)

    # we want to take in account now what was already mentioned in Lesson3:
    # forces must be applied for each physics step if you want a constant force applied
    # thus we create an input handler that gets invoked each physics step
    input_handler = InputHandler.new
    physics_space.add_to_update_callbacks { |space, time| input_handler.update time }

    # now we add an input actions to move the sphere while a key is pressed
    # we invoke handler action every update of the input handler while the HOME/END key is down
    #
    # note: as the input handler gets updated each physics step the force is framerate independent -
    #       we can't use the normal input handler here!
    input_handler.addAction MyInputAction.new(@dynamic_node, Vector3f.new(70, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_HOME, InputHandler::AXIS_NONE, true
    input_handler.addAction MyInputAction.new(@dynamic_node, Vector3f.new(-70, 0, 0)),
      InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_END, InputHandler::AXIS_NONE, true

    # again we have created only physics - activate physics debug mode to see something
    self.show_physics = true;
  end

  def simpleUpdate
    # as the user can steer the sphere only in one direction it will fall off the floor after a
    # short time we want to put it back up then
    if @dynamic_node.world_translation.y < -20
      @dynamic_node.clear_dynamics                          # clear speed and forces
      @dynamic_node.local_translation.set(*STARTING_POINT)  # then put it over the floor again
    end
  end
end

Lesson5.new.start if $0 == __FILE__