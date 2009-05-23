require 'jme'
require 'jmephysics'

class Lesson3 < SimplePhysicsGame
  def simpleInitGame
    # first we will create the floor like in Lesson2
    static_node = physics_space.create_static_node
    root_node << static_node
    visual_floor_box = Box.new "floor", Vector3f.new, 5, 0.25, 5
    static_node << visual_floor_box
    # this time we tilt it a bit
    visual_floor_box.local_rotation.fromAngleNormalAxis 0.3, Vector3f.new(0, 0, -1)
    # and create another part below
    visual_floor_box2 = Box.new "floor", Vector3f.new, 5, 0.25, 5
    static_node << visual_floor_box2 
    visual_floor_box2.local_translation.set 9.7, -1.5, 0
    static_node.generatePhysicsGeometry

    # the first box gets in the center above the floor with default material
    create_box([0, 5, 0])

    # lets create an ice block (ice is predefined material) which is transparent blue
    create_box([0, 5, 1.5], Material::ICE) { |box| color box, ColorRGBA.new(0.5, 0.5, 0.9, 0.6) }

    # Use predefined rubber cube that is yellow
    create_box([0, 5, -1.5], Material::RUBBER) { |box| color box, ColorRGBA.yellow }

    # finally we define a custom material
    custom_material = Material.new "supra-stopper"
    custom_material.density = 0.05        # we make it really light
    # a material should define contact detail pairs for each other material 
    # it could collide with in the scene do that just for the floor material:
    # DEFAULT material. Our material should not bounce on DEFAULT and should 
    # never slide on DEFAULT
    contact_details = MutableContactInfo.new.set! :bounce => 0, :mu => 1000
    custom_material.putContactHandlingDetails Material::DEFAULT, contact_details

    # ... finally test our supra-stopper with a red cube
    create_box([0,5,3], custom_material) { |box| color box, ColorRGBA.red }

    # start paused - press P to start the action :)
    self.pause = true;
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
  end
end

Lesson3.new.start
