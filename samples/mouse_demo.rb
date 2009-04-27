require 'jme'

class MouseDemo < SimpleGame
  def simpleInitGame
    @mouse = AbsoluteMouse.new display, "Mouse", "data/cursor/cursor1.png"
    @mouse.center
    @mouse.registerWithInputHandler input
#    light_state.detach_all

    box = Box.new("Box", 1, 1, 1)
#    @sphere = Sphere.new("Box2", 16, 1)
#    @sphere.color self, :ambient => ColorRGBA.green
    @sphere = SpherePlus.new(self)
    @sphere.local_translation.set(0, 0, 5)
    root_node << box << @sphere <<  @mouse
    box.light_combine_mode = Spatial::LightCombineMode::Off
    input.mouse_look_handler.enabled = false
  end

  def simpleUpdate
    if MouseInput.get.isButtonDown(0)
#      @mouse.picks.to_a.first.getTargetMesh.setRandomColors
    elsif MouseInput.get.isButtonDown(1)
      puts "BUTTON MIDDLE"
    elsif MouseInput.get.isButtonDown(2)
      puts "BUTTON RIGHT"
    end
  end
end

class SpherePlus < Sphere
  def initialize(game)
    super("Sphere Plus", 30, 1)

    pivot = Node.new("Pivot")
    # This light will rotate around my sphere.  Notice I don't give it a position
    pl = PointLight.new
    pl.setDiffuse(ColorRGBA.red.clone)     # Color the light red
    pl.setEnabled(true)
    game.light_state.attach(pl)

    # This node will hold my light
    ln = SimpleLightNode.new("A node for my pointLight",pl)
    # I set the light's position thru the node
    ln.setLocalTranslation(Vector3f.new(0,50,0))
    # I attach the light's node to my pivot
    pivot.attachChild(ln)

    # I create a box and attach it too my lightnode.  This lets me see where my light is
    b = Box.new("Blarg", 0.6, 0.6, 0.6)#Vector3f.new(-0.3,-0.3,-0.3), Vector3f.new(0.3,0.3,0.3))

    ln.attachChild(b)

    # I create a controller to rotate my pivot
    st=SpatialTransformer.new(1)
    # I tell my spatial controller to change pivot
    st.setObject(pivot,0,-1)

    zAxis = Vector3f.new(0, 0, 1)
    # Assign a rotation for object 0 at t=0 to rot=0 degrees around the z axis
    st.setRotation(0,0,Quaternion.fromAngleAxis(0, zAxis))
    # Assign a rotation for object 0 at t=2 to rot=180 degrees around the z axis
    st.setRotation(0,2,Quaternion.fromAngleAxis(Math::PI, zAxis))
    # Assign a rotation for object 0 at t=4 to rot=360 degrees around the z axis
    st.setRotation(0,4,Quaternion.fromAngleAxis(Math::PI * 2, zAxis))
    # Prepare my controller to start moving around
    st.interpolateMissing
    st.setRepeatType(Controller::RT_WRAP)
    # Tell my pivot it is controlled by st
    pivot.addController(st)

    game.root_node << pivot
  end
end

MouseDemo.new.start
