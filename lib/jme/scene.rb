class Geometry
  def collides_with?(other)
    has_collision(other, false)
  end

  def bound(bound)
    setModelBound bound
    update_model_bound
  end
end

class Node
  include TextureHelper
  
  def <<(child)
    attachChild(child)
    self
  end

  def collides_with?(other)
    has_collision(other, false)
  end
end

class Skybox
  def initialize(name, x, y, z, north=nil, south=nil, east=nil, west=nil, up=nil, down=nil)
    super(name, x, y, z)

    unless north.nil?
      set_texture(Face::North, sky_texture(north))
      set_texture(Face::West, sky_texture(west))
      set_texture(Face::South, sky_texture(south))
      set_texture(Face::East, sky_texture(east))
      set_texture(Face::Up, sky_texture(up))
      set_texture(Face::Down, sky_texture(down))
      preload_textures
    end
  end
  
  def sky_texture(resource)
    TextureManager.load(resource, :BilinearNearestMipMap, :Bilinear)
  end

  def update(cam)
    local_translation.set(cam.location)
    update_geometric_state(0.0, true)
  end
end

class Spatial
  include TextureHelper

  field_reader :parent

  # Overrides set_render_state to accept a list of render states
  def render_state(*list)
    list.each { |stat| setRenderState(stat) }
    updateRenderState
  end

  def color(color)
    renderer = DisplaySystem.display_system.renderer
    material_state = renderer.createMaterialState.set! :diffuse => color

    # Some alpha value.  We need to do more to make it look ok.
    if color.a < 1
        blend_state = renderer.createBlendState.set! :enabled => true,
          :blend_enabled => true, 
          :source_function => BlendState::SourceFunction::SourceAlpha,
          :destination_function => BlendState::DestinationFunction::OneMinusSourceAlpha
        setRenderState blend_state
        setRenderQueueMode Renderer::QUEUE_TRANSPARENT
    end

    setRenderState material_state
  end
  
  # The assumption is that renderpass is the most common for a common spatial.
  def to_pass
    render_pass = RenderPass.new
    render_pass.add(self)
    render_pass
  end

  # Simple abbreviated location setter
  def at(x, y, z)
    local_translation.set(x, y, z)
    self
  end

  # Rotate the number of radian about a normalized axis
  def rotate(rad, axis)
    local_rotation.fromAngleNormalAxis rad, axis
    self
  end

  # Simple abbreviated location setter
  def scale(x, y=nil, z=nil)
    if y && z
      local_scale.set(x, y, z) 
    else
      set_local_scale(x)
    end
    self
  end
end

class Text
  def value=(new_value)
    self.text.length = 0
    self.text.append new_value
  end
end
