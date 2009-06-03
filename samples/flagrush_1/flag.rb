java_import com.jme.image.Texture
java_import com.jme.light.LightNode
java_import com.jme.light.PointLight
java_import com.jme.math.FastMath
java_import com.jme.math.Quaternion
java_import com.jme.math.Vector3f
java_import com.jme.math.spring.SpringPoint
java_import com.jme.math.spring.SpringPointForce
java_import com.jme.renderer.ColorRGBA
java_import com.jme.renderer.Renderer
java_import com.jme.scene.Node
java_import com.jme.scene.shape.Cylinder
java_import com.jme.scene.state.CullState
java_import com.jme.scene.state.LightState
java_import com.jme.scene.state.TextureState
java_import com.jme.system.DisplaySystem
java_import com.jme.util.TextureManager
java_import com.jmex.effects.cloth.ClothPatch
java_import com.jmex.effects.cloth.ClothUtils
java_import com.jmex.terrain.TerrainBlock

# Flag maintains the object that is the "goal" of the game. The
# drivers are to try to grab the flags for points. The main job of 
# the class is to build the flag geometry, and position itself randomly
# within the level after a period of time. (tutorial originally from Mark Powell)
class Flag < Node
  # 10 second life time
  LIFE_TIME = 10

  # Constructor builds the flag, taking the terrain as the parameter. This
  # is just the reference to the game's terrain object so that we can 
  # randomly place this flag on the level.
  def initialize(tb)
    super("flag")
    @tb = tb
    @countdown = LIFE_TIME
    @windStrength = 15.0
    @windDirection = Vector3f.new(0.8, 0, 0.2)
    # create a cloth patch that will handle the flag part of our flag.
    @cloth = ClothPatch.new("cloth", 25, 25, 1, 10)
    #  Add our custom flag wind force to the cloth
    @wind = RandomFlagWindForce.new(@windStrength, @windDirection)
    @cloth.addForce(@wind)
    #  Add a simple gravitational force:
    @gravity = ClothUtils.createBasicGravity()
    @cloth.addForce(@gravity)
        
    # Create the flag pole
    c = Cylinder.new("pole", 10, 10, 0.5, 50 )
    attachChild(c)
    q = Quaternion.new()
    # rotate the cylinder to be vertical
    q.fromAngleAxis(FastMath::PI/2, Vector3f.new(1,0,0))
    c.setLocalRotation(q)
    c.setLocalTranslation(Vector3f.new(-12.5,-12.5,0))

    # create a texture that the flag will display.
    # Let's promote jME! 
    ts = DisplaySystem.getDisplaySystem().getRenderer().createTextureState()
    ts.setTexture(TextureManager.loadTexture(resource("data/images/Monkey.jpg"),
            Texture::MinificationFilter::Trilinear,
            Texture::MagnificationFilter::Bilinear))
        
    # We'll use a LightNode to give more lighting to the flag, we use the node because
    # it will allow it to move with the flag as it hops around.
    # first create the light
    dr = PointLight.new()
    dr.setEnabled( true )
    dr.setDiffuse( ColorRGBA.new( 1, 1, 1, 1 ) )
    dr.setAmbient( ColorRGBA.new( 0.5, 0.5, 0.5, 1 ) )
    dr.setLocation( Vector3f.new( 0.5, -0.5, 0 ) )
    # next the state
    lightState = DisplaySystem.getDisplaySystem().getRenderer().createLightState()
    lightState.setEnabled(true)
    lightState.setTwoSidedLighting( true )
    lightState.attach(dr)
    # last the node
    lightNode = LightNode.new( "light" )
    lightNode.setLight( dr )
    lightNode.setLocalTranslation(Vector3f.new(15,10,0))

    setRenderState(lightState)
    attachChild(lightNode)
        
    @cloth.setRenderState(ts)
    # We want to see both sides of the flag, so we will turn back facing culling OFF.
    cs = DisplaySystem.getDisplaySystem().getRenderer().createCullState()
    cs.setCullFace(CullState::Face::None)
    @cloth.setRenderState(cs)
    attachChild(@cloth)
        
    # We need to attach a few points of the cloth to the poll. These points shouldn't
    # ever move. So, we'll attach five points at the top and 5 at the bottom. 
    # to make them not move the mass has to be high enough that no force can move it.
    # I also move the position of these points slightly to help bunch up the flag to
    # give it better realism.
    0.upto(5) do |i|
      @cloth.getSystem().getNode(i*25).position.y *= 0.8
      @cloth.getSystem().getNode(i*25).setMass(java.lang.Float::POSITIVE_INFINITY)
    end
    
    24.downto(19) do |i|
      @cloth.getSystem().getNode(i*25).position.y *= 0.8
      @cloth.getSystem().getNode(i*25).setMass(java.lang.Float::POSITIVE_INFINITY)
    end
    setRenderQueueMode(Renderer::QUEUE_OPAQUE)
    setLocalScale(0.25)
  end
    
  # During the update, we decrement the time. When it reaches zero, we will
  # reset the flag.
  def update(time)
    @countdown -= time
        
    if(@countdown <= 0)
        reset()
    end
  end
    
  # reset sets the life time back to 10 seconds, and then randomly places the flag
  # on the terrain.
  def reset()
    @countdown = LIFE_TIME
    placeFlag()
  end
    
  # place flag picks a random point on the terrain and places the flag there. I
  # set the values to be between (45 and 175) which places it within the force field
  # level.
  def placeFlag()
    x = 45 + FastMath.nextRandomFloat() * 130
    z = 45 + FastMath.nextRandomFloat() * 130
    y = @tb.getHeight(x,z) + 7.5
    localTranslation.x = x
    localTranslation.y = y
    localTranslation.z = z
  end
    
  # RandomFlagWindForce defines a SpringPointForce that will slighly adjust the
  # direction of the wind and the force of the wind. This will cause the flag
  # to flap in the wind and rotate about the flag pole slightly, giving it a
  # realistic movement.
  class RandomFlagWindForce < SpringPointForce

    # Creates a new force with a defined max strength and a starting direction.
    def initialize(strength, direction)
      super()
      @strength = strength
      @windDirection = direction
    end
        
    # called during the update of the cloth. Will adjust the direction slightly
    # and adjust the strength slightly.
    def apply(dt, node)
        @windDirection.x += dt * (FastMath.nextRandomFloat() - 0.5)
        @windDirection.z += dt * (FastMath.nextRandomFloat() - 0.5)
        @windDirection.normalize()
        tStr = FastMath.nextRandomFloat() * @strength
        node.acceleration.addLocal(@windDirection.x * tStr, 
                     @windDirection.y * tStr, @windDirection.z * tStr)
    end
  end
end
