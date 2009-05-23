require 'jme'

import java.io.FileInputStream

class MouseDemo < SimpleGame
  ORIGIN = Vector3f.new 0, 0, 0
  FAR_PLANE = 2000.0

  def simpleInitGame
    lights
    camera
    model_file = "/Users/enebo/work/jrme/data/simple_cube.dae"
    model = load_model(FileInputStream.new(model_file))
    model.updateRenderState
    ball = Sphere.new("marble", 16, 1)
    ball.local_translation.y = model.local_translation.y
    root_node << model << ball
  end

  def simpleUpdate
  end

  def load_model(model, model_name = "model")
    ColladaImporter.squelchErrors(false)
    ColladaImporter.load model, model_name
    n = ColladaImporter.get_model
    n.setModelBound(BoundingBox.new)
    n.updateModelBound
    n
  end

  def lights
    light_state.detachAll
    light_state.attach DirectionalLight.new.set!(:enabled => true,
      :diffuse => ColorRGBA.new(1, 1, 1, 1), :ambient => ColorRGBA.new(0.5, 0.5, 0.7, 1),
      :direction => Vector3f.new(-0.8, -1.0, -0.8))
  end

  def camera
    cam.set_frustum_perspective(45.0, display.width.to_f / display.height, 8.0, FAR_PLANE)
#    cam.location = Vector3f.new(71.87401, 69.71194, 92.63322)
    cam.location = Vector3f.new(59.767094, 78.20338, 33.364197)
    cam.lookAt ORIGIN, Vector3f::UNIT_Y
    cam.update

    root_node.setRenderState(display.renderer.createCullState.set!(:cull_face => CullState::Face::Back))
  end

end

MouseDemo.new.start
