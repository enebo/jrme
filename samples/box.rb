require 'jme'

class Main < SimpleGame
  ORIGIN = Vector3f.new 0, 0, 0
  FAR_PLANE = 20000.0

  def simpleInitGame
    display.title = "Boxin"
    lights

    @mouse = AbsoluteMouse.new display, "Mouse", "data/cursor/cursor1.png"
    @mouse.center
    @mouse.registerWithInputHandler input

    box = Box.new("Box", Vector3f.new, 10, 10, 10)

    root_node << box << @mouse
    root_node.cull_hint = Spatial::CullHint::Never
    box.light_combine_mode = Spatial::LightCombineMode::Off
    input.mouse_look_handler.enabled = false
  end

  def simpleUpdate
  end

  def lights
    light_state.detachAll
    light_state.attach DirectionalLight.new.set!(:enabled => true,
      :diffuse => ColorRGBA.new(1, 1, 1, 1), 
      :ambient => ColorRGBA.new(0.5, 0.5, 0.7, 1),
      :direction => Vector3f.new(-0.8, -1.0, -0.8))
  end

end

Main.new.start
