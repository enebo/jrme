require 'jme'
java_import java.io.IOException
java_import java.util.HashMap
java_import java.util.logging.Level
java_import java.util.logging.Logger

require 'drift_action'
require 'flag_rush_handler'
require 'force_field_fence'
require 'vehicle'
require 'flag'
require 'forward_and_backward_action'
require 'vehicle_rotate_action'
require 'shadow_tweaker'

# From flagrush tutorial in jmonkeyengine source
class FlagRush < BaseGame
  $logger = Logger.getLogger("Lesson9")

  def initialize
    super()
    @normal = Vector3f.new
    @shadowPass = ShadowedRenderPass.new
    setConfigShowMode(ConfigShowMode::AlwaysShow, resource("data/images/JMonkey.jpg"))
    ShadowTweaker.new(@shadowPass).setVisible(true)
  end
    
  def update(interpolation)
    # update the time to get the framerate
    @timer.update()
    interpolation = @timer.getTimePerFrame()
    #update the keyboard input (move the player around)
    @input.update(interpolation)
    #update the chase camera to handle the player moving around.
    @chaser.update(interpolation)
    #update the fence to animate the force field texture
    @fence.update(interpolation)
    #update the flag to make it flap in the wind
    @flag.update(interpolation)
        
    #we want to keep the skybox around our eyes, so move it with
    #the camera
    @skybox.setLocalTranslation(@cam.getLocation())
    @skybox.updateGeometricState(0, true)
        
    # if escape was pressed, we exit
    if (KeyBindingManager.getKeyBindingManager().isValidCommand("exit"))
      finished = true
    end
        
    #We don't want the chase camera to go below the world, so always keep 
    #it 2 units above the level.
    if(@cam.getLocation().y < (@tb.getHeight(@cam.getLocation())+2))
      @cam.getLocation().y = @tb.getHeight(@cam.getLocation()) + 2
      @cam.update()
    end
        
    #make sure that if the player left the level we don't crash. When we add collisions,
    #the fence will do its job and keep the player inside.
    characterMinHeight = @tb.getHeight(@player.getLocalTranslation())+@agl
    if (!java.lang.Float.isInfinite(characterMinHeight) && !java.lang.Float.isNaN(characterMinHeight))
      @player.getLocalTranslation().y = characterMinHeight
    end
        
    #get the normal of the terrain at our current location. We then apply it to the up vector
    #of the player.
    @tb.getSurfaceNormal(@player.getLocalTranslation(), @normal)
    if(@normal != nil)
      @player.rotateUpTo(@normal)
    end
        
    #Because we are changing the scene (moving the skybox and player) we need to update
    #the graph.
    @scene.updateGeometricState(interpolation, true)
  end

  def render(interpolation)
    # Clear the screen
    display.getRenderer().clearBuffers()
    # Have the PassManager render.
    @passManager.renderPasses(display.getRenderer())
  end

  def initSystem
    puts "A.1"
    # store the settings information
    @width = settings.getWidth()
    @height = settings.getHeight()
    @depth = settings.getDepth()
    @freq = settings.getFrequency()
    @fullscreen = settings.isFullscreen()
        
    begin
      self.display = DisplaySystem.getDisplaySystem(settings.getRenderer())
      self.display.setMinStencilBits(8)
      self.display.createWindow(@width, @height, @depth, @freq, @fullscreen)

      @cam = display.getRenderer().createCamera(@width, @height)
    rescue JmeException => e
      $logger.log(Level::SEVERE, "Could not create displaySystem", e)
      java.lang.System.exit(1)
    end

    # set the background to black
    self.display.getRenderer().setBackgroundColor(ColorRGBA.black.clone())

    # initialize the camera
    @cam.setFrustumPerspective(45.0, @width.to_f / @height.to_f, 1, 5000)
    @cam.setLocation(Vector3f.new(200,1000,200))
        
    # Signal that we've changed our camera's location/frustum.
    @cam.update()

    # Get a high resolution timer for FPS updates.
    @timer = Timer.getTimer()

    self.display.getRenderer().setCamera(@cam)

    KeyBindingManager.getKeyBindingManager().set("exit", KeyInput::KEY_ESCAPE)
  end

  def initGame
    puts "B.1"
    display.setTitle("Flag Rush")
        
    @scene = Node.new("Scene graph node")
    # Create a ZBuffer to display pixels closest to the camera above farther ones.
    buf = display.getRenderer().createZBufferState()
    buf.setEnabled(true)
    buf.setFunction(ZBufferState::TestFunction::LessThanOrEqualTo)
    @scene.setRenderState(buf)
        
    #Time for a little optimization. We don't need to render back face triangles, so lets
    #not. This will give us a performance boost for very little effort.
    cs = display.getRenderer().createCullState()
    cs.setCullFace(CullState::Face::Back)
    @scene.setRenderState(cs)
        
    #Add terrain to the scene
    buildTerrain()
    #Add a flag randomly to the terrain
    buildFlag()
    #Light the world
    buildLighting()
    #add the force field fence
    buildEnvironment()
    #Add the skybox
    buildSkyBox()
    #Build the player
    buildPlayer()
    #build the chase cam
    buildChaseCamera()
    #build the player input
    buildInput()
        
    #set up passes
    buildPassManager()
        
    # update the scene graph for rendering
    @scene.updateGeometricState(0.0, true)
    @scene.updateRenderState()
    puts "B.2"
  end
    
  def buildPassManager()
    @passManager = BasicPassManager.new()

    # Add skybox first to make sure it is in the background
    rPass = RenderPass.new()
    rPass.add(@skybox)
    @passManager.add(rPass)

    @shadowPass.add(@scene)
    @shadowPass.addOccluder(@player)
    @shadowPass.setRenderShadows(true)
    @shadowPass.setLightingMethod(ShadowedRenderPass::LightingMethod::Modulative)
    @passManager.add(@shadowPass)
  end

  def buildFlag()
    #create the flag and place it
    @flag = Flag.new(@tb)
    @scene.attachChild(@flag)
    @flag.placeFlag()
  end
    
  def buildPlayer()
    model = nil

    begin
      bikeFile = resource("data/model/bike.jme")
      importer = BinaryImporter.new()
      model = importer.load(bikeFile.openStream())
      model.setModelBound(BoundingBox.new())
      model.updateModelBound()
      #scale it to be MUCH smaller than it is originally
      model.setLocalScale(0.0025)
    rescue IOException => e
      $logger.throwing(this.getClass().toString(), "buildPlayer()", e)
    end
        
    #set the vehicles attributes (these numbers can be thought
    #of as Unit/Second).
    @player = Vehicle.new("Player Node", model, 25, 15, 25, 15, 15, 2.5)
    @player.setLocalTranslation(Vector3f.new(100,0, 100))
    @scene.attachChild(@player)
    @scene.updateGeometricState(0, true)
    #we now store this initial value, because we are rotating the wheels the bounding box will
    #change each frame.
    @agl = @player.getWorldBound().yExtent
    @player.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
  end
    
  def buildEnvironment()
    #This is the main node of our fence
    @fence = ForceFieldFence.new("fence")
        
    #we will do a little 'tweaking' by hand to make it fit in the terrain a bit better.
    #first we'll scale the entire "model" by a factor of 5
    @fence.setLocalScale(5)
    #now let's move the fence to to the height of the terrain and in a little bit.
    @fence.setLocalTranslation(Vector3f.new(25, @tb.getHeight(25,25)+10, 25))

    @scene.attachChild(@fence)
  end

  def buildLighting()
    # Set up a basic, default light.
    light = DirectionalLight.new()
    light.setDiffuse(ColorRGBA.new(1.0, 1.0, 1.0, 1.0))
    light.setAmbient(ColorRGBA.new(0.5, 0.5, 0.5, 0.5))
    light.setDirection(Vector3f.new(1,-1,0))
    light.setShadowCaster(true)
    light.setEnabled(true)

    # Attach the light to a lightState and the lightState to rootNode.
    lightState = display.getRenderer().createLightState()
    lightState.setEnabled(true)
    lightState.setGlobalAmbient(ColorRGBA.new(0.2, 0.2, 0.2, 1))
    lightState.attach(light)
    @scene.setRenderState(lightState)
  end

  def buildTerrain()
    heightMap = MidPointHeightMap.new(64, 1)
    # Scale the data
    terrainScale = Vector3f.new(4, 0.0575, 4)
    # create a terrainblock
    @tb = TerrainBlock.new("Terrain", heightMap.getSize(), terrainScale,
                heightMap.getHeightMap(), Vector3f.new(0, 0, 0))

    @tb.setModelBound(BoundingBox.new())
    @tb.updateModelBound()

    # generate a terrain texture with 2 textures
    pt = ProceduralTextureGenerator.new(heightMap)
    pt.addTexture(ImageIcon.new(resource("data/texture/grassb.png")), -128, 0, 128)
    pt.addTexture(ImageIcon.new(resource("data/texture/dirt.jpg")), 0, 128, 255)
    pt.addTexture(ImageIcon.new(resource("data/texture/highest.jpg")), 128, 255, 384)
    pt.createTexture(32)
        
    # assign the texture to the terrain
    ts = display.getRenderer().createTextureState()
    t1 = TextureManager.loadTexture(pt.getImageIcon().getImage(),
                Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear, true)
    ts.setTexture(t1, 0)
        
    #load a detail texture and set the combine modes for the two terrain textures.
    t2 = TextureManager.loadTexture(resource("data/texture/Detail.jpg"),
                Texture::MinificationFilter::Trilinear,
                Texture::MagnificationFilter::Bilinear)

    ts.setTexture(t2, 1)
    t2.setWrap(Texture::WrapMode::Repeat)

    t1.setApply(Texture::ApplyMode::Combine)
    t1.setCombineFuncRGB(Texture::CombinerFunctionRGB::Modulate)
    t1.setCombineSrc0RGB(Texture::CombinerSource::CurrentTexture)
    t1.setCombineOp0RGB(Texture::CombinerOperandRGB::SourceColor)
    t1.setCombineSrc1RGB(Texture::CombinerSource::PrimaryColor)
    t1.setCombineOp1RGB(Texture::CombinerOperandRGB::SourceColor)

    t2.setApply(Texture::ApplyMode::Combine)
    t2.setCombineFuncRGB(Texture::CombinerFunctionRGB::AddSigned)
    t2.setCombineSrc0RGB(Texture::CombinerSource::CurrentTexture)
    t2.setCombineOp0RGB(Texture::CombinerOperandRGB::SourceColor)
    t2.setCombineSrc1RGB(Texture::CombinerSource::Previous)
    t2.setCombineOp1RGB(Texture::CombinerOperandRGB::SourceColor)

    @tb.setRenderState(ts)
    #set the detail parameters.
    @tb.setDetailTexture(1, 16)
    @tb.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
    @scene.attachChild(@tb)
  end
    
  def buildSkyBox()
    @skybox = Skybox.new("skybox", 10, 10, 10)

    north = TextureManager.loadTexture(
            resource("data/texture/north.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)
    south = TextureManager.loadTexture(
            resource("data/texture/south.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)
    east = TextureManager.loadTexture(
            resource("data/texture/east.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)
    west = TextureManager.loadTexture(
            resource("data/texture/west.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)
    up = TextureManager.loadTexture(
            resource("data/texture/top.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)
    down = TextureManager.loadTexture(
            resource("data/texture/bottom.jpg"),
            Texture::MinificationFilter::BilinearNearestMipMap,
            Texture::MagnificationFilter::Bilinear)

    @skybox.setTexture(Skybox::Face::North, north)
    @skybox.setTexture(Skybox::Face::West, west)
    @skybox.setTexture(Skybox::Face::South, south)
    @skybox.setTexture(Skybox::Face::East, east)
    @skybox.setTexture(Skybox::Face::Up, up)
    @skybox.setTexture(Skybox::Face::Down, down)
    @skybox.preloadTextures()
    @skybox.updateRenderState()
  end
    
  def buildChaseCamera()
    props = HashMap.new
    props.put(ThirdPersonMouseLook::PROP_MAXROLLOUT, "6")
    props.put(ThirdPersonMouseLook::PROP_MINROLLOUT, "3")
    props.put(ThirdPersonMouseLook::PROP_MAXASCENT, "#{45 * FastMath::DEG_TO_RAD}")
    props.put(ChaseCamera::PROP_INITIALSPHERECOORDS, Vector3f.new(5, 0, 30 * FastMath::DEG_TO_RAD))
    props.put(ChaseCamera::PROP_DAMPINGK, "4")
    props.put(ChaseCamera::PROP_SPRINGK, "9")
    @chaser = ChaseCamera.new(@cam, @player, props)
    @chaser.setMaxDistance(8)
    @chaser.setMinDistance(2)
  end

  def buildInput()
    @input = FlagRushHandler.new(@player, settings.getRenderer())
  end
    
  def reinit()
    display.recreateWindow(@width, @height, @depth, @freq, @fullscreen)
  end
    
  def quit()
    super
    java.lang.System.exit(0)
  end

  def cleanup()
  end
end

FlagRush.new().start()
