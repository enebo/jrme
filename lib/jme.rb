require 'java'

java_import java.lang.System
java_import java.nio.FloatBuffer
java_import javax.swing.ImageIcon
java_import com.jme.animation.SpatialTransformer
java_import com.jme.app.AbstractGame
java_import com.jme.app.BaseGame
java_import com.jme.app.BaseSimpleGame
java_import com.jme.app.FixedFramerateGame
java_import com.jme.app.SimpleGame
java_import com.jme.app.SimplePassGame
java_import com.jme.bounding.BoundingBox
java_import com.jme.bounding.BoundingSphere
java_import com.jme.image.Texture
java_import com.jme.input.AbsoluteMouse
java_import com.jme.input.ChaseCamera
java_import com.jme.input.FirstPersonHandler
java_import com.jme.input.InputHandler
java_import com.jme.input.KeyBindingManager
java_import com.jme.input.KeyInput
java_import com.jme.input.action.KeyInputAction
java_import com.jme.input.MouseInput
java_import com.jme.input.ThirdPersonHandler
java_import com.jme.input.action.InputAction
java_import com.jme.input.action.KeyNodeBackwardAction
java_import com.jme.input.action.KeyNodeForwardAction
java_import com.jme.input.action.KeyNodeRotateLeftAction
java_import com.jme.input.action.KeyNodeRotateRightAction
java_import com.jme.input.thirdperson.ThirdPersonMouseLook
java_import com.jme.intersection.BoundingPickResults
java_import com.jme.intersection.PickResults
java_import com.jme.light.DirectionalLight
java_import com.jme.light.LightNode
java_import com.jme.light.PointLight
java_import com.jme.light.SimpleLightNode
java_import com.jme.math.FastMath
java_import com.jme.math.Plane
java_import com.jme.math.Ray;
java_import com.jme.math.Quaternion
java_import com.jme.math.Matrix3f
java_import com.jme.math.Vector2f
java_import com.jme.math.Vector3f
java_import com.jme.math.spring.SpringPointForce
java_import com.jme.renderer.ColorRGBA
java_import com.jme.renderer.Renderer
java_import com.jme.renderer.pass.BasicPassManager
java_import com.jme.renderer.pass.Pass
java_import com.jme.renderer.pass.RenderPass
java_import com.jme.renderer.pass.ShadowedRenderPass
java_import com.jme.scene.Controller
java_import com.jme.scene.Geometry
java_import com.jme.scene.Node
java_import com.jme.scene.SharedMesh
java_import com.jme.scene.Skybox
java_import com.jme.scene.Spatial
java_import com.jme.scene.Text
java_import com.jme.scene.shape.Box
java_import com.jme.scene.shape.Cylinder
java_import com.jme.scene.shape.Dome
java_import com.jme.scene.shape.MultiFaceBox
java_import com.jme.scene.shape.Quad
java_import com.jme.scene.shape.RoundedBox
java_import com.jme.scene.shape.Sphere
java_import com.jme.scene.shape.Torus
java_import com.jme.scene.state.BlendState
java_import com.jme.scene.state.CullState
java_import com.jme.scene.state.FogState
java_import com.jme.scene.state.TextureState
java_import com.jme.scene.state.ZBufferState
java_import com.jme.system.DisplaySystem
java_import com.jme.system.JmeException
java_import com.jme.util.TextureManager
java_import com.jme.util.Timer
java_import com.jme.util.export.binary.BinaryImporter
java_import com.jme.util.export.binary.BinaryExporter
java_import com.jmex.effects.cloth.ClothPatch
java_import com.jmex.effects.cloth.ClothUtils
java_import com.jmex.effects.particles.ParticleFactory
java_import com.jmex.effects.particles.ParticleMesh
java_import com.jmex.effects.water.WaterRenderPass
java_import com.jmex.model.collada.ColladaImporter
java_import com.jmex.terrain.TerrainBlock
java_import com.jmex.terrain.TerrainPage
java_import com.jmex.terrain.util.ImageBasedHeightMap
java_import com.jmex.terrain.util.MidPointHeightMap
java_import com.jmex.terrain.util.ProceduralTextureGenerator
java_import com.jmex.terrain.util.ProceduralSplatTextureGenerator

class Object
  def set!(values)
    values.keys.each { |key| __send__ key.to_s + "=", values[key] }
    self
  end

  def self.new!(values)
    self.new.set!(values)
  end

  def resource(url)
    self.java_class.class_loader.getResource url
#    java.lang.ClassLoader.get_system_class_loader.get_resource url
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
require 'jme/bounding'
require 'jme/input'
require 'jme/math'
require 'jme/scene'
require 'jme/shape'
require 'jme/terrain'

#### Additions to jme
require 'jme/explosions'
require 'jme/effects'
require 'jme/screen_settings'
require 'jme/unit'
