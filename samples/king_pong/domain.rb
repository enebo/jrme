class Arena < Node
  SIZE = 400.0
  
  def initialize(side_walls, goal_walls, ball)
    super "Arena"
    texture "data/images/rockwall2.jpg"
    local_translation.set(0, 0, 0)
    self << side_walls << goal_walls << ball
  end
end

class Walls < Node
  HEIGHT = Arena::SIZE/32
  DEPTH = Arena::SIZE/32
end

class GoalWalls < Walls
  LENGTH = Arena::SIZE

  def initialize
    super("GoalWalls")
    wall = Box.new("player_wall1", Vector3f.new, DEPTH, HEIGHT, LENGTH)
    wall.local_translation.set(Arena::SIZE + Arena::SIZE/12, 0, 0)
    self << wall

    wall = Box.new("player_wall2", Vector3f.new, DEPTH, HEIGHT, LENGTH)
    wall.local_translation.set(-Arena::SIZE - Arena::SIZE/12, 0, 0)
    self << wall
  end
end

# Class for collisions
class SideWalls < Walls
  LENGTH = Arena::SIZE/32

  def initialize
    super("Sidewalls")

    wall = Box.new("wall1", Vector3f.new, Arena::SIZE + Arena::SIZE/12 + DEPTH, HEIGHT, LENGTH)
    wall.local_translation.set(0, 0, Arena::SIZE)
    self << wall

    wall = Box.new("wall2", Vector3f.new, Arena::SIZE + Arena::SIZE/12 + DEPTH, HEIGHT, LENGTH)
    wall.local_translation.set(0, 0, -Arena::SIZE)
    self << wall
  end
end

# TODO really understand tpf
# Make ball just roll on terrain without all this hand rolled stuff
# ball should determine velocity based on what it is colliding with
# so wall and paddle could use same logic since one is not moving
# terrain can affect both velocity and acceleration

class Ball < Sphere
  Samples, Radius = 16, 25

  include Rotating, Explosions
  attr_accessor :velocity

  def initialize(terrain)
    super("Ball", Samples, Samples, Radius)
    texture("data/images/Monkey.jpg")
    @velocity, @terrain = Vector3f.new(0, 0, 0), terrain
    reset(10)     # Initialize ball velocity
  end

  def bounce
    @velocity.x *= -15
    @velocity.z += rand(2000) - 1000
    explosion
  end

  def constrain_velocity
    @velocity.x = FastMath.clamp(@velocity.x, -800.0, 800.0)
    @velocity.z = FastMath.clamp(@velocity.z, -800.0, 800.0)
  end

  def move(tpf)
    constrain_velocity
    rotate(tpf)

    # Move ball according to velocity
    local_translation.addLocal(@velocity.mult(tpf))
    local_translation.y = @terrain.getHeight(local_translation)
    local_translation.y = 0.0 if local_translation.y.nan?

    normal = @terrain.getSurfaceNormal(local_translation, @vector)
    if (normal)
      @velocity.x += normal.x * 6000.0 * tpf
      @velocity.z += normal.z * 6000.0 * tpf
    end

    @velocity.multLocal(1.0 - tpf * 0.2)
  end
  
  def reflected_bounce
    @velocity.z *= -1
  end

  def reset(velocity_magnitude = 200)
    local_translation.zero
    @velocity.set(FastMath.rand.nextFloat * velocity_magnitude, 0, 
                  FastMath.rand.nextFloat * velocity_magnitude)
  end
end

class Paddle < Box
  HEIGHT=Arena::SIZE/12
  LENGTH=Arena::SIZE/6
  DEPTH=Arena::SIZE/24
  MIN_Z = -Arena::SIZE + LENGTH
  MAX_Z = Arena::SIZE - LENGTH  

  attr_accessor :speed, :text

  def initialize(label, x_position)
    super(label, Vector3f.new, DEPTH, HEIGHT, LENGTH)
    local_translation.set(x_position, 0, 0)
    @score, @speed = 0, 1000.0
  end

  def move_up(tpf)
    new_z = local_translation.z - @speed * tpf
    local_translation.z = new_z < MIN_Z ? MIN_Z : new_z
  end

  def move_down(tpf)
    new_z = local_translation.z + @speed * tpf
    local_translation.z = new_z > MAX_Z ? MAX_Z : new_z
  end

  def score_goal
    @score = @score + 1
  end
end

class Terrain < TerrainPage
  def initialize
    texture_dir = "data/texture/"
    gray_scale = image_icon(texture_dir + "terrain/trough3.png")
    height_map = ImageBasedHeightMap.new gray_scale.image
    terrain_scale = Vector3f.new(6, 0.4, 6)
    height_map.set_height_scale(0.001)
    super("Terrain", 33, height_map.size + 1, terrain_scale, height_map.height_map)
    local_translation.set(0, -9.5, 0)
    setDetailTexture(1, 16)

    pst = ProceduralSplatTextureGenerator.new(height_map)
    pst.addTexture image_icon(texture_dir + "grassb.png"), -128, 0, 128
    pst.addTexture image_icon(texture_dir + "dirt.jpg"), 0, 128, 255
    pst.addTexture image_icon(texture_dir + "highest.jpg"), 128, 255, 384
    pst.addSplatTexture image_icon(texture_dir + "terrainTex.png"), image_icon(texture_dir + "water.png")
    pst.createTexture(1024)

    ts = DisplaySystem.display_system.renderer.createTextureState
    t1 = TextureManager.load_from_image(pst.image_icon.image)
    t2 = TextureManager.load(resource(texture_dir + "Detail.jpg"))
    t1.set!(:apply => Texture::ApplyMode::Combine,
                :combine_func_rgb => Texture::CombinerFunctionRGB::Modulate,
                :combine_src0_rgb => Texture::CombinerSource::CurrentTexture,
                :combine_op0_rgb => Texture::CombinerOperandRGB::SourceColor,
                :combine_src1_rgb => Texture::CombinerSource::PrimaryColor,
                :combine_op1_rgb => Texture::CombinerOperandRGB::SourceColor)
    t1.set!(:wrap => Texture::WrapMode::Repeat,
                :apply => Texture::ApplyMode::Combine,
                :combine_func_rgb => Texture::CombinerFunctionRGB::AddSigned,
                :combine_src0_rgb => Texture::CombinerSource::CurrentTexture,
                :combine_op0_rgb => Texture::CombinerOperandRGB::SourceColor,
                :combine_src1_rgb => Texture::CombinerSource::Previous,
                :combine_op1_rgb => Texture::CombinerOperandRGB::SourceColor)
    ts.setTexture(t1, 0)
    ts.setTexture(t2, 1)
    setRenderState(ts)
  end
end

class Sky < Skybox
  def initialize
    dir = "data/skybox1/"    
    super("Sky", 10, 10, 10, dir + "1.jpg", dir + "3.jpg", dir + "2.jpg", dir + "4.jpg", dir + "6.jpg", dir + "5.jpg")
    renderer = DisplaySystem.display_system.renderer

    setRenderState renderer.createCullState.set! :cull_face => CullState::Face::None, :enabled => true
    setRenderState renderer.createZBufferState.set! :enabled => false
    setRenderState renderer.createFogState.set! :enabled => false
    setLightCombineMode LightCombineMode::Off
    setCullHint CullHint::Never
    setTextureCombineMode TextureCombineMode::Replace
    updateRenderState

    lockBounds
    lockMeshes
  end


end

class Water < WaterRenderPass
  def initialize(game)
    super(game.cam, 2, false, false)
    set!(:water_plane => Plane.new(Vector3f.new(0.0, 1.0, 0.0), 0.0), 
             :clip_bias => -1.0, :reflection_throttle => 0.0, :refraction_throttle => 0.0)

    @waterQuad = Quad.new("waterQuad", 1, 1)
    @waterQuad.normal_buffer.reset_to(0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0)
    setWaterEffectOnSpatial(@waterQuad)
    
    game.root_node << @waterQuad

    setReflectedScene(game.sky)
    addReflectedScene(game.arena)
    setSkybox(game.sky)
  end

  def update(cam, far_plane)
    transVec = Vector3f.new(cam.location.x, water_height, cam.location.z)
    setTextureCoords(0, transVec.x, -transVec.z, 0.07, far_plane)
    setVertexCoords(transVec.x, transVec.y, transVec.z, far_plane)
  end

  def setVertexCoords(x, y, z, far_plane)
    @waterQuad.vertex_buffer.reset_to(x - far_plane, y, z - far_plane,
                                      x - far_plane, y, z + far_plane,
                                      x + far_plane, y, z + far_plane,
                                      x + far_plane, y, z - far_plane)
  end

  def setTextureCoords(buffer, x, y, texture_scale, far_plane)
    x = x * texture_scale * 0.5
    y = y * texture_scale * 0.5
    texture_scale = far_plane * texture_scale
    @waterQuad.texture_coords(buffer).coords.reset_to(x, texture_scale + y, x, y,
       texture_scale + x, y, texture_scale + x, texture_scale + y)
  end
end
