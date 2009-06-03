# Flag maintains the object that is the "goal" of the game. The
# drivers are to try to grab the flags for points. The main job of 
# the class is to build the flag geometry, and position itself randomly
# within the level after a period of time. (tutorial originally from Mark 
# Powell)
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
    # create a cloth patch that will handle the flag part of our flag.
    @cloth = ClothPatch.new("cloth", 25, 25, 1, 10)
    #  Add our custom flag wind force to the cloth
    wind_strength = 15.0
    wind_direction = Vector3f.new(0.8, 0, 0.2)
    @cloth.add_force RandomFlagWindForce.new(wind_strength, wind_direction)
    @cloth.add_force ClothUtils.create_basic_gravity
        
    # Create the flag pole
    c = Cylinder.new("pole", 10, 10, 0.5, 50 )
    attach_child c
    q = Quaternion.new
    # rotate the cylinder to be vertical
    q.from_angle_axis FastMath::PI/2, Vector3f.new(1, 0, 0)
    c.local_rotation = q
    c.local_translation = Vector3f.new -12.5, -12.5, 0

    # create a texture that the flag will display.
    # Let's promote jME! 
    ts = DisplaySystem.display_system.renderer.create_texture_state
    ts.setTexture(TextureManager.loadTexture(resource("data/images/Monkey.jpg"),
            Texture::MinificationFilter::Trilinear,
            Texture::MagnificationFilter::Bilinear))
        
    # We'll use a LightNode to give more lighting to the flag, we use the node because
    # it will allow it to move with the flag as it hops around.
    # first create the light
    dr = PointLight.new
    dr.enabled = true
    dr.diffuse = ColorRGBA.new 1, 1, 1, 1
    dr.ambient = ColorRGBA.new 0.5, 0.5, 0.5, 1 
    dr.location = Vector3f.new 0.5, -0.5, 0 
    # next the state
    lightState = DisplaySystem.display_system.renderer.create_light_state
    lightState.enabled = true
    lightState.two_sided_lighting = true
    lightState.attach dr
    # last the node
    lightNode = LightNode.new( "light" )
    lightNode.light = dr
    lightNode.local_translation = Vector3f.new 15, 10, 0

    setRenderState(lightState)
    attachChild(lightNode)
        
    @cloth.setRenderState(ts)
    # We want to see both sides of the flag, so we will turn back facing culling OFF.
    cs = DisplaySystem.display_system.renderer.create_cull_state
    cs.cull_face = CullState::Face::None
    @cloth.setRenderState cs
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
    place_flag
  end
    
  # place flag picks a random point on the terrain and places the flag there. I
  # set the values to be between (45 and 175) which places it within the force field
  # level.
  def place_flag
    x = 45 + FastMath.next_random_float * 130
    z = 45 + FastMath.next_random_float * 130
    y = @tb.get_height(x,z) + 7.5
    local_translation.x = x
    local_translation.y = y
    local_translation.z = z
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
      @direction = direction
    end
        
    # called during the update of the cloth. Will adjust the direction slightly
    # and adjust the strength slightly.
    def apply(dt, node)
      @direction.x += dt * (FastMath.next_random_float - 0.5)
      @direction.z += dt * (FastMath.next_random_float - 0.5)
      @direction.normalize
      tStr = FastMath.next_random_float * @strength
      node.acceleration.add_local(@direction.x * tStr, @direction.y * tStr, 
                                  @direction.z * tStr)
    end
  end
end
