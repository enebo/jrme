require 'jme'
require 'jmephysics'

class Lesson4 < SimplePhysicsGame
  STARTING_POINT = [0, 5, 0]
  def simpleInitGame
    # 1. we will create the floor
    static_node = physics_space.create_static_node
    root_node << static_node
    floor_box = static_node.createBox "floor"
    floor_box.local_scale.set 10, 0.5, 10
    # We do not call floorBox.setLocalScale Vector3f.new(10, 0.5, 10) as this  will create a
    # new vector this is important since that would create a new object every frame.

    # 2. we create a sphere that should fall down on the floor
    @dynamic_node = physics_space.create_dynamic_node
    root_node << @dynamic_node
    @dynamic_node.createSphere "rolling sphere"
    @dynamic_node.local_translation.set(*STARTING_POINT)
    # note: we do not move the collision geometry but the physics node!

    add_force = proc { |event| @dynamic_node.add_force Vector3f.new 50, 0, 0 }

    # we register an action so that every press of HOME key will apply force dynamic_node
    input.add_action add_force, InputHandler::DEVICE_KEYBOARD, KeyInput::KEY_HOME,
      InputHandler::AXIS_NONE, false

    # again we have created only physics - activate physics debug mode to see something
    self.show_physics = true
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

Lesson4.new.start