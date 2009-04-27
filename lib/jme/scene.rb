
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
  def initialize(name, x, y, z, north, south, east, west, up, down)
    super(name, x, y, z)

    set_texture(Face::North, sky_texture(north))
    set_texture(Face::West, sky_texture(west))
    set_texture(Face::South, sky_texture(south))
    set_texture(Face::East, sky_texture(east))
    set_texture(Face::Up, sky_texture(up))
    set_texture(Face::Down, sky_texture(down))
    preload_textures    
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

  def color(displayer, values)
    material_state = displayer.display.renderer.createMaterialState
    render_state material_state.set! values
    material_state
  end
  
  # The assumption is that renderpass is the most common for a common spatial.
  def to_pass
    render_pass = RenderPass.new
    render_pass.add(self)
    render_pass    
  end
end
