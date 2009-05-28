require 'jme'
require 'field'
require 'fence'
require 'input_handler'
require 'movement'
require 'vehicle'

class Driving < BaseGame
  include ScreenSettings

  def initialize()
    super()
    # We will load our own "fantastic" Flag Rush logo. Yes, I'm an artist.
    set_config_show_mode AbstractGame::ConfigShowMode::AlwaysShow, resource("data/images/Monkey.jpg")
  end

  def update(interpolation)
    # update the time to get the framerate
    @timer.update
    interpolation = @timer.time_per_frame
    
    @input.update interpolation  # move the player around
    @chaser.update interpolation # update chase camera for player moving
    @fence.update interpolation  # update fence force field

    # We want to keep the skybox around our eyes, so it moves with the camera
    @skybox.local_translation = @cam.location

    quit if KeyBindingManager.key_binding_manager.valid_command? "exit"

    # make sure that if the player left the level we don't crash. When we add 
    # collisions, the fence will do its job and keep the player inside.
    characterMinHeight = @terrain.get_height(@player.local_translation) + 
      @agl

    if !java.lang.Float.isInfinite(characterMinHeight) && !java.lang.Float.isNaN(characterMinHeight)
      @player.local_translation.y = characterMinHeight
    end

    # Moving anything in the scene and we need to let it know to update
    @scene.updateGeometricState(interpolation, true)
  end
 
  # draws the scene graph
  def render(interpolation)
    display.renderer.clearBuffers     # Clear the screen
    display.renderer.draw @scene
  end
 
  # initializes the display and camera.
  def initSystem
    self.display = create_display
 
    # initialize the camera
    @cam = create_camera(display)
    @cam.setFrustumPerspective(45.0,  settings.width.to_f / settings.height, 1, 5000)
    @cam.update
    display.renderer.camera = @cam

    # Get a high resolution timer for FPS updates.
    @timer = Timer.timer
 
    KeyBindingManager.key_binding_manager.set "exit", KeyInput::KEY_ESCAPE
  end
 
  # initializes the scene
  def initGame
    display.title = "Flag Rush"

    @scene = Node.new "Scene graph node"

    renderer = display.renderer

    # Create ZBuffer to display pixels closest to the camera above farther ones
    @scene.setRenderState renderer.createZBufferState.set!(:enabled => true,
      :function => ZBufferState::TestFunction::LessThanOrEqualTo)

    # Time for a little opt. We don't need to render back face triangles.
    @scene.setRenderState renderer.createCullState.set!(:cull_face => CullState::Face::Back)

    [build_terrain, build_lighting, build_environment, build_skybox,
     build_player, build_chase_camera, build_input]
 
    # update the scene graph for rendering
    @scene.update_geometric_state 0.0, true
    @scene.update_render_state
  end
 
  def build_player
    begin
      model = BinaryImporter.new.load resource("data/model/bike.jme").openStream
      model.model_bound = BoundingBox.new
      model.update_model_bound
      model.local_scale = 0.0025  # Make it tiny for a tiny world
    rescue java.io.IOException => e
      puts "Trouble loading model? #{e}"
    end
 
    # set the marbles attributes (these numbers can be thought of as Unit/s).
    @player = Vehicle.new("Bike", model, :acceleration => 15, :braking => 25, :turn_speed => 5,
                          :weight => 25, :max_speed => 25, :min_speed => 15)
        
    @player.local_translation = Vector3f.new(100, 0, 100)
    @scene << @player
    @scene.updateGeometricState 0, true
    @agl = @player.world_bound.yExtent
    @player.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
  end

  def build_environment
    @walls = Node.new "bouncing walls"
    @scene << @walls

    @fence = ForceFieldFence.new
    
    # we will do a little 'tweaking' by hand to make it fit in the terrain a 
    # bit better. first we'll scale the entire "model" by a factor of 5
    @fence.setLocalScale(Vector3f.new(5,4,4))
    # let's move the fence to to the height of the terrain and in a little bit.
    @fence.setLocalTranslation(Vector3f.new(25, @terrain.getHeight(25,25) + 15, 25))

    @walls << @fence
  end
 
  # creates a light for the terrain.
  def build_lighting
    # Set up a basic, default light.
    light = DirectionalLight.new.set! :enabled => true,
      :diffuse => ColorRGBA.new(1.0, 1.0, 1.0, 1.0),
      :ambient => ColorRGBA.new(0.5, 0.5, 0.5, 1.0),
      :direction => Vector3f.new(1, -1,0)
 
    # Attach the light to a lightState and the lightState to rootNode.
    lightState = display.renderer.createLightState()
    lightState.enabled = true
    lightState.attach(light)

    @scene.setRenderState(lightState)
  end
 
  # build the height map and terrain block.
  def build_terrain
    # Generate a random terrain data
    heightMap = MidPointHeightMap.new 64, 1.0
    # Scale the data
    terrainScale = Vector3f.new(4, 0.0575, 4)
    # create a terrainblock
    @terrain = TerrainBlock.new("Terrain", heightMap.size, terrainScale,
                          heightMap.height_map, Vector3f.new(0, 0, 0))
 
    @terrain.setModelBound(BoundingBox.new)
    @terrain.updateModelBound
 
    # generate a terrain texture with 3 textures using a texture size of 32
    terrain_image = ProceduralTextureGenerator.create(heightMap, 32,
       [["data/texture/grassb.png", -128, 0, 128],
        ["data/texture/dirt.jpg", 0, 128, 255],
        ["data/texture/highest.jpg", 128, 255, 384]]).image_icon.image
 
    # assign the texture to the terrain
    ts = display.renderer.create_texture_state
    ts.enabled = true
    ts.setTexture(TextureManager.load_from_image(terrain_image), 0)
 
    @terrain.setRenderState(ts)
    @terrain.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
    @scene.attachChild(@terrain)
  end

  def build_skybox
    @skybox = Skybox.new("skybox", 10, 10, 10, 
       "data/texture/north.jpg", "data/texture/south.jpg",
       "data/texture/east.jpg", "data/texture/west.jpg",
       "data/texture/top.jpg", "data/texture/bottom.jpg")
    @scene << @skybox
  end

  def build_chase_camera
    # Why is their interface HashMap and not Map?
    props = java.util.HashMap.new
    props.put ThirdPersonMouseLook::PROP_MAXROLLOUT, "6"
    props.put ThirdPersonMouseLook::PROP_MINROLLOUT, "3"
    props.put ThirdPersonMouseLook::PROP_MAXASCENT, "#{45 * FastMath::DEG_TO_RAD}"
    props.put ChaseCamera::PROP_INITIALSPHERECOORDS, Vector3f.new(5, 0, 30 * FastMath::DEG_TO_RAD)
    props.put ChaseCamera::PROP_DAMPINGK, "4"
    props.put ChaseCamera::PROP_SPRINGK, "9"
# Once my HashMap -> Map patch gets accepted I can use this:
#     props = {ThirdPersonMouseLook::PROP_MAXROLLOUT => "6",
#       ThirdPersonMouseLook::PROP_MINROLLOUT => "3",
#       ThirdPersonMouseLook::PROP_MAXASCENT => "#{45 * FastMath::DEG_TO_RAD}",
#       ChaseCamera::PROP_INITIALSPHERECOORDS => Vector3f.new(5, 0, 30 * FastMath::DEG_TO_RAD),
#       ChaseCamera::PROP_DAMPINGK => "4",
#       ChaseCamera::PROP_SPRINGK => "9"
#     }

    @chaser = ChaseCamera.new(@cam, @player, props)
    @chaser.max_distance = 8
    @chaser.min_distance = 2
  end

  def build_input
    @input = FlagRushHandler.new(@player, settings.renderer)
  end
 
  # will be called if the resolution changes
  def reinit
    @display.recreateWindow(settings.width, settings.height, settings.depth, settings.frequency, settings.fullscreen?)
  end

  def quit
    super
    java.lang.System.exit 0
  end
 
  # clean up the textures.
  def cleanup
  end
end

app = Driving.new.start
