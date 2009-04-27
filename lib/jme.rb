require 'java'

import java.nio.FloatBuffer
import javax.swing.ImageIcon
import com.jme.animation.SpatialTransformer;
import com.jme.app.AbstractGame
import com.jme.app.BaseGame
import com.jme.app.BaseSimpleGame
import com.jme.app.SimpleGame
import com.jme.app.SimplePassGame
import com.jme.bounding.BoundingBox
import com.jme.bounding.BoundingSphere
import com.jme.image.Texture
import com.jme.input.AbsoluteMouse;
import com.jme.input.FirstPersonHandler;
import com.jme.input.KeyBindingManager
import com.jme.input.KeyInput
import com.jme.input.MouseInput;
import com.jme.intersection.BoundingPickResults;
import com.jme.intersection.PickResults;
import com.jme.light.DirectionalLight
import com.jme.light.PointLight;
import com.jme.light.SimpleLightNode;
import com.jme.math.FastMath
import com.jme.math.Plane
import com.jme.math.Ray;
import com.jme.math.Quaternion
import com.jme.math.Vector2f
import com.jme.math.Vector3f
import com.jme.renderer.ColorRGBA
import com.jme.renderer.Renderer
import com.jme.renderer.pass.BasicPassManager
import com.jme.renderer.pass.Pass
import com.jme.renderer.pass.RenderPass
import com.jme.renderer.pass.ShadowedRenderPass
import com.jme.scene.Controller
import com.jme.scene.Geometry
import com.jme.scene.Node
import com.jme.scene.Skybox
import com.jme.scene.Spatial
import com.jme.scene.Text
import com.jme.scene.shape.Box
import com.jme.scene.shape.Quad
import com.jme.scene.shape.Sphere
import com.jme.scene.shape.Torus
import com.jme.scene.state.BlendState
import com.jme.scene.state.CullState
import com.jme.scene.state.FogState
import com.jme.scene.state.TextureState
import com.jme.scene.state.ZBufferState
import com.jme.system.DisplaySystem
import com.jme.util.TextureManager
import com.jmex.effects.particles.ParticleFactory
import com.jmex.effects.particles.ParticleMesh
import com.jmex.effects.water.WaterRenderPass
import com.jmex.terrain.TerrainPage
import com.jmex.terrain.util.ImageBasedHeightMap
import com.jmex.terrain.util.ProceduralSplatTextureGenerator

class Object
  def set!(values)
    values.keys.each { |key| __send__ key.to_s + "=", values[key] }
    self
  end

  def resource(url)
    self.java_class.class_loader.getResource url
  end

  def image_icon(url)
    ImageIcon.new(resource(url))
  end
end

class FloatBuffer
  def reset_to(*list)
    clear
    list.each { |element| put(element) }
  end
end

module RandomHelper
  def random_percent
    rand(100).to_f / 100
  end

  def random_color
    color = display.renderer.createMaterialState
    color.ambient = ColorRGBA.new(random_percent, random_percent, random_percent, random_percent)
    color
  end
end

module TextureHelper
  def texture(display_provider, url)
    texture_state = display_provider.display.renderer.createTextureState
    texture = TextureManager.load(resource(url))
    texture.setWrap(Texture::WrapMode::Repeat)
    texture_state.setTexture texture
    setRenderState texture_state
  end
end

class TextureManager
  def self.load_from_image(image, min_filter=:Trilinear, max_filter=:Bilinear, flipped=true)
    TextureManager.loadTexture(image, min(min_filter), max(max_filter), flipped)
  end

  def self.load(url, min_filter=:Trilinear, max_filter=:Bilinear)
    TextureManager.loadTexture url, min(min_filter),max(max_filter)
  end

  def self.min(filter_name)
    Texture::MinificationFilter.const_get filter_name.to_s
  end

  def self.max(filter_name)
    Texture::MagnificationFilter.const_get filter_name.to_s
  end
end

class Pass
  def to_pass
    self
  end
end

class BasicPassManager
  def <<(pass)
    add(pass.to_pass)
    self
  end
end

class PickResults
  include Enumerable

  def each
    0.upto(number - 1) { |i| yield getPickData(i) }
  end
end

require 'jme/app'
require 'jme/input'
require 'jme/math'
require 'jme/scene'
require 'jme/shape'

#### Additions to jme
require 'jme/explosions'
require 'jme/effects'
