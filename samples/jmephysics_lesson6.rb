require 'jme'
require 'jmephysics'

# We inherit from last tutorial so load it
require File.dirname(__FILE__) + '/jmephysics_lesson5'

# something collided with the lower floor
class MyCollisionAction < InputAction
  def performAction(event)
    # as we know this action is handling collision we can cast the data to ContactInfo
    contact_info = event.trigger_data

    # the contact could be sphere <-> floor or floor <-> sphere
    if contact_info.node2.kind_of? DynamicPhysicsNode # it's floor <-> sphere
      sphere = contact_info.node2
    elsif contact_info.node1.kind_of? DynamicPhysicsNode # it's sphere <-> floor
      sphere = contact_info.node1
    else
      # no dynamic node - should not happen, but we ignore it
      return
    end

    # put the sphere back up
    sphere.clear_dynamics
    sphere.at(*Lesson5::STARTING_POINT)
  end
end

class Lesson6 < Lesson5
  def simpleInitGame
    super()

    # now create an additional floor below the existing one
    root_node << lower_floor = physics_space.create_static do
      create_box("floor").scale(50, 0.5, 50)
      at 0, -10, 0
    end

    # We are interested in collision events with the lower floor
    # jME Physics 2 uses SyntheticButtons to listen for these events
    collision_event_handler = lower_floor.collision_event_handler
    # we can subscribe for such an event with an input handler of our choice now
    input.add_action MyCollisionAction.new, collision_event_handler, false
  end
end

Lesson6.new.start
