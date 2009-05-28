require 'jme'
require 'jmephysics'

class Lesson3 < SimplePhysicsGame
  def simpleInitGame
    # first create a two segment floor with one segment at an angle
    root_node << physics_space.create_static do
      box = Box.new("floor", Vector3f.new, 2.dam, 1.m, 2.dam)
      geometry(box).rotate(0.3, -ZAXIS)
      geometry(box.clone).at(4.dam - 1.m, -6.m, 0)
    end

    # create four boxes next to each other of various materials
    create_box 0, 2.dam, 0
    create_box 0, 2.dam, 6.m, Material::ICE, ColorRGBA.new(0.5, 0.5, 0.9, 0.6)
    create_box 0, 2.dam, -6.m, Material::RUBBER, ColorRGBA.yellow

    # Define a custom material.  A material should define contact
    # details pairs for each material it can collide with (DEFAULT in this case)
    custom_material = Material.create("supra-stopper") do
      density 0.05     # super light
      contact Material::DEFAULT => MutableContactInfo.new.set!(:bounce => 0, :mu => 1000)
    end

    create_box 0, 2.dam, 1.2.dam, custom_material, ColorRGBA.red

    self.pause = true; # start paused - press 'P' to begin
  end

  def create_box(x, y, z, material=Material::DEFAULT, color=ColorRGBA.green)
    root_node << dynamic_node = physics_space.create_dynamic do
      geometry Cube.new("falling box", Vector3f.new, 2.m)
      color color
      made_of material
      at x, y, z
    end
  end
end

Lesson3.new.start
