require 'jme'
java_import java.io.IOException
java_import java.util.HashMap
java_import java.util.logging.Level
java_import java.util.logging.Logger

require 'flag_rush_handler'
require 'force_field_fence'
require 'vehicle'
require 'flag'
require 'vehicle_rotate_action'
require 'shadow_tweaker'

# From flagrush tutorial in jmonkeyengine source
class FlagRush < BaseGame
  $logger = Logger.getLogger("Lesson9")

  def initialize
    super()
    @normal = Vector3f.new
    @shadow_pass = ShadowedRenderPass.new
    set_config_show_mode(ConfigShowMode::AlwaysShow, resource("data/images/JMonkey.jpg"))
    ShadowTweaker.new(@shadow_pass).setVisible(true)
  end
    
  def update(interpolation)
    @timer.update                           # update time to get the framerate
    interpolation = @timer.time_per_frame
    @input.update interpolation             # move the player around?
    @chaser.update interpolation            # update the chase camera position
    @fence.update interpolation             # update force field animation
    @flag.update interpolation              # make flag flap in 'wind'
        
    # We want to keep the skybox around our eyes, so it moves with the camera
    @skybox.local_translation = @cam.location
    @skybox.update_geometric_state(0, true)
        
    # if escape was pressed, we exit
    quit if KeyBindingManager.key_binding_manager.is_valid_command("exit")
        
    # Make sure camera does not fall through the world
    if @cam.location.y < @tb.get_height(@cam.location) + 2
      @cam.location.y = @tb.get_height(@cam.location) + 2
      @cam.update
    end
        
    # Make sure that if the player left the level we don't crash. 
    character_min_height = @tb.get_height(@player.local_translation) + @agl
    if !character_min_height.infinite? && !character_min_height.nan?
      @player.local_translation.y = character_min_height
    end
        
    # Get the normal of the terrain and apply it to the bike
    @tb.get_surface_normal @player.local_translation, @normal
    @player.rotate_up_to @normal unless @normal.nil?
        
    # Things in the scene graph has changed update.
    @scene.update_geometric_state(interpolation, true)
  end

  def render(interpolation)
    display.renderer.clear_buffers               # Clear the screen
    @pass_manager.render_passes display.renderer # Have the PassManager render.
  end

  def initSystem
    # store the settings information
    @width, @height, @depth = settings.width, settings.height, settings.depth
    @freq, @fullscreen = settings.frequency, settings.isFullscreen
        
    begin
      self.display = DisplaySystem.display_system settings.renderer
      self.display.min_stencil_bits = 8
      self.display.create_window @width, @height, @depth, @freq, @fullscreen

      @cam = display.renderer.create_camera @width, @height
    rescue JmeException => e
      $logger.log Level::SEVERE, "Could not create displaySystem", e
      java.lang.System.exit(1)
    end

    # set the background to black
    self.display.renderer.background_color = ColorRGBA.black.clone

    # initialize the camera
    @cam.set_frustum_perspective 45.0, @width.to_f / @height.to_f, 1, 5000
    @cam.location = Vector3f.new(200,1000,200)
        
    # Signal that we've changed our camera's location/frustum.
    @cam.update

    # Get a high resolution timer for FPS updates.
    @timer = Timer.timer

    self.display.renderer.camera = @cam

    KeyBindingManager.key_binding_manager.set "exit", KeyInput::KEY_ESCAPE
  end

  def initGame
    display.title = "Flag Rush"
    renderer = display.renderer
        
    @scene = Node.new "Scene graph node"
    # Create a ZBuffer to display pixels closest to the camera above farther ones.
    buf = renderer.createZBufferState
    buf.enabled = true
    buf.function = ZBufferState::TestFunction::LessThanOrEqualTo
    @scene.setRenderState(buf)
        
    #Time for a little optimization. We don't need to render back face triangles, so lets
    #not. This will give us a performance boost for very little effort.
    cs = renderer.create_cull_state
    cs.cull_face = CullState::Face::Back
    @scene.setRenderState(cs)
        
    build_terrain       # Add terrain to the scene
    build_flag          # Add a flag randomly to the terrain
    build_lighting      # Light the world
    build_environment   # Add the force field fence
    build_sky_box       # Add the skybox
    build_player        # Build the player
    build_chase_camera  # Build the chase cam
    build_input         # Build the player input
    build_pass_manager  # Set up passes
        
    # update the scene graph for rendering
    @scene.update_geometric_state 0.0, true
    @scene.update_render_state
  end
    
  def build_pass_manager
    @pass_manager = BasicPassManager.new

    # Add skybox first to make sure it is in the background
    rPass = RenderPass.new
    rPass.add @skybox
    @pass_manager.add rPass

    @shadow_pass.add @scene
    @shadow_pass.add_occluder @player
    @shadow_pass.render_shadows = true
    @shadow_pass.lighting_method = ShadowedRenderPass::LightingMethod::Modulative
    @pass_manager.add @shadow_pass
  end

  def build_flag
    #create the flag and place it
    @flag = Flag.new @tb
    @scene.attach_child @flag
    @flag.place_flag
  end
    
  def build_player
    begin
      importer = BinaryImporter.new
      model = importer.load(resource("data/model/bike.jme").open_stream)
      model.model_bound = BoundingBox.new
      model.update_model_bound
      model.local_scale = 0.0025
    rescue IOException => e
      $logger.throwing(self.class.name, "buildPlayer()", e)
    end

    # Define the bike
    @player = Vehicle.new("Player Node", model, 25, 15, 25, 15, 15, 2.5)
    @player.local_translation = Vector3f.new(100,0, 100)
    @scene.attach_child @player
    @scene.update_geometric_state 0, true
    # We now store this initial value, because we are rotating the wheels the 
    # bounding box will change each frame.
    @agl = @player.world_bound.y_extent
    @player.render_queue_mode = Renderer::QUEUE_OPAQUE
  end
    
  def build_environment
    #This is the main node of our fence
    @fence = ForceFieldFence.new("fence")
        
    # tweak the fence a bit to make it look nicer with the terrain
    @fence.local_scale = 5
    # Let's move the fence to to the height of the terrain and in a little bit.
    @fence.local_translation = Vector3f.new(25, @tb.get_height(25, 25) + 10, 25)
    @scene.attach_child @fence
  end

  def build_lighting
    # Set up a basic, default light.
    light = DirectionalLight.new
    light.diffuse = ColorRGBA.new(1.0, 1.0, 1.0, 1.0)
    light.ambient = ColorRGBA.new(0.5, 0.5, 0.5, 0.5)
    light.direction = Vector3f.new(1,-1,0)
    light.shadow_caster = true
    light.enabled = true

    # Attach the light to a lightState and the lightState to rootNode.
    light_state = display.renderer.create_light_state
    light_state.enabled = true
    light_state.global_ambient = ColorRGBA.new(0.2, 0.2, 0.2, 1)
    light_state.attach light
    @scene.setRenderState light_state
  end

  def build_terrain
    height_map = MidPointHeightMap.new(64, 1)
    terrain_scale = Vector3f.new(4, 0.0575, 4) 

    @tb = TerrainBlock.new("Terrain", height_map.size, terrain_scale,
                height_map.height_map, Vector3f.new(0, 0, 0))
    @tb.model_bound = BoundingBox.new
    @tb.update_model_bound

    # generate a terrain texture with 2 textures
    pt = ProceduralTextureGenerator.new(height_map)
    pt.add_texture(ImageIcon.new(resource("data/texture/grassb.png")), -128, 0, 128)
    pt.add_texture(ImageIcon.new(resource("data/texture/dirt.jpg")), 0, 128, 255)
    pt.add_texture(ImageIcon.new(resource("data/texture/highest.jpg")), 128, 255, 384)
    pt.create_texture(32)
        
    # assign the texture to the terrain
    ts = display.renderer.create_texture_state
    t1 = TextureManager.load_texture(pt.image_icon.image,
                Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear, true)
    ts.set_texture(t1, 0)
        
    #load a detail texture and set the combine modes for the two terrain textures.
    t2 = TextureManager.load_texture(resource("data/texture/Detail.jpg"),
                Texture::MinificationFilter::Trilinear,
                Texture::MagnificationFilter::Bilinear)

    ts.set_texture(t2, 1)
    t2.wrap = Texture::WrapMode::Repeat

    t1.apply = Texture::ApplyMode::Combine
    t1.setCombineFuncRGB(Texture::CombinerFunctionRGB::Modulate)
    t1.setCombineSrc0RGB(Texture::CombinerSource::CurrentTexture)
    t1.setCombineOp0RGB(Texture::CombinerOperandRGB::SourceColor)
    t1.setCombineSrc1RGB(Texture::CombinerSource::PrimaryColor)
    t1.setCombineOp1RGB(Texture::CombinerOperandRGB::SourceColor)

    t2.apply = Texture::ApplyMode::Combine
    t2.setCombineFuncRGB(Texture::CombinerFunctionRGB::AddSigned)
    t2.setCombineSrc0RGB(Texture::CombinerSource::CurrentTexture)
    t2.setCombineOp0RGB(Texture::CombinerOperandRGB::SourceColor)
    t2.setCombineSrc1RGB(Texture::CombinerSource::Previous)
    t2.setCombineOp1RGB(Texture::CombinerOperandRGB::SourceColor)

    @tb.setRenderState ts
    #set the detail parameters.
    @tb.setDetailTexture 1, 16
    @tb.render_queue_mode = Renderer::QUEUE_OPAQUE
    @scene.attachChild @tb
  end
    
  def build_sky_box
    @skybox = Skybox.new("skybox", 10, 10, 10,
      "/data/texture/north.jpg", "/data/texture/south.jpg", 
      "/data/texture/east.jpg", "/data/texture/west.jpg", 
      "/data/texture/top.jpg", "/data/texture/bottom.jpg")
    @skybox.updateRenderState
  end
    
  def build_chase_camera
    # set up our chase camera so we can follow the bike
    @chaser = ChaseCamera.create(@cam, @player) do
      mouse_look.min_roll_out, mouse_look.max_roll_out = 3, 6
      mouse_look.max_ascent = 45.deg_in_rad
      damping_k, spring_k = 4, 9
      min_distance, max_distance = 8, 2
      set_ideal_sphere_coords Vector3f(5, 0, 30.deg_in_rad)
    end
  end

  def build_input
    @input = FlagRushHandler.new(@player, settings.renderer)
  end
    
  def reinit
    display.recreate_window(@width, @height, @depth, @freq, @fullscreen)
  end
    
  def quit
    super
    exit 0
  end

  def cleanup
  end
end

FlagRush.new.start
