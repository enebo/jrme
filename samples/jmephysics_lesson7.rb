require 'jme'
require 'jmephysics'

class Lesson7 < SimplePhysicsGame
  def simpleInitGame
    # first we will create a floor and sphere like in Lesson4
    static_node = physics_space.create_static_node
    root_node << static_node
    floor_box = static_node.create_box "floor"
    floor_box.local_scale.set 10, 0.5, 10
    dynamic_sphere_node = physics_space.create_dynamic_node
    root_node << dynamic_sphere_node
    dynamic_sphere_node.create_sphere "swinging sphere"

    # but put the sphere a little to the side
    dynamic_sphere_node.local_translation.set 3.4, 5, 0

    # now we are going to tie the sphere to the environment
    # thus we need a joint
    joint_for_sphere = physics_space.create_joint
    # right now that joint does not allow any degree of freedom
    # we want the sphere to act like a pendulum thus we need one rotational degree of freedom:
    rotational_axis = joint_for_sphere.create_rotational_axis
    # the axis of rotation for the sphere should point into z direction
    rotational_axis.direction = Vector3f.new 0, 0, 1
    # ok now we attach the joint to our sphere
    joint_for_sphere.attach dynamic_sphere_node
    # as we used the attach method with only one parameter the other side of the joint is attached to the world
    # this means it is fixed!
    # the anchor point in the world should be above the floor to let the sphere swing right above it
    joint_for_sphere.anchor = Vector3f.new 0, 5, 0

    # then create thos two boxes
    dynamic_box_node1 = physics_space.create_dynamic_node
    root_node << dynamic_box_node1
    dynamic_box_node1.create_box "box1"
    dynamic_box_node2 = physics_space.create_dynamic_node
    root_node << dynamic_box_node2
    dynamic_box_node2.createBox "box2"
    # move the first box above the floor
    dynamic_box_node1.local_translation.set 0, 1, 0
    # move the second box a little to the right
    dynamic_box_node2.local_translation.set 0.7, 1, 0
    # additionally the first first box gets more weight
    dynamic_box_node1.mass = 5

    # these boxes do intersect a little bit this would be problematic without joints but we do join them now
    joint_for_boxes = physics_space.create_joint
    # the boxes shall be able to shift into each other
    # so create one translational degree of free in x direction
    translational_axis = joint_for_boxes.create_translational_axis
    translational_axis.direction = Vector3f.new 1, 0, 0
    # and attach the joint to the two boxes
    joint_for_boxes.attach dynamic_box_node1, dynamic_box_node2

    # the joint currently can extend up to infinity - as this is quite unnatural we restrict that
    translational_axis.position_minimum = 0
    translational_axis.position_maximum = 10

    # to allow the second box to slide above the floor we make it a little slippery
    dynamic_box_node2.material = Material::ICE

    # ok no visuals here - switch on debug mode
    self.show_physics = true;

    # what you will note when starting this program:
    # - joined nodes do not collide with each other
    # - joints themselfes do not have a collision volume and can go through other objects
  end
end

Lesson7.new.start


