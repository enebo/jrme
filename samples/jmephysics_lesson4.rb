require 'jme'
require 'jmephysics'

class Lesson4 < SimplePhysicsGame
  STARTING_POINT = [0, 5, 0]

  def simpleInitGame
    root_node << physics_space.create_static do              # The floor
      createBox("floor").scale(10, 0.5, 10)
    end

    root_node << @sphere = physics_space.create_dynamic do   # The sphere
      createSphere "sphere"
      at *STARTING_POINT
    end

    # note: we do not move the collision geometry but the physics node!
    add_force = proc { |event| @sphere.add_force Vector3f.new 50, 0, 0 }

    # for each press of HOME key we add some force to the sphere
    input.add_action add_force, InputHandler::DEVICE_KEYBOARD, 
      KeyInput::KEY_HOME, InputHandler::AXIS_NONE, false

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

Lesson4.new.start
