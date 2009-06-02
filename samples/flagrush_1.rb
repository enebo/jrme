java_import java.io.IOException
java_import java.net.URL
java_import java.util.HashMap
java_import java.util.logging.Level
java_import java.util.logging.Logger
java_import javax.swing.ImageIcon
java_import jmetest.renderer.ShadowTweaker
java_import jmetest.renderer.TestSkybox
java_import jmetest.terrain.TestTerrain
java_import com.jme.app.BaseGame
java_import com.jme.bounding.BoundingBox
java_import com.jme.image.Texture
java_import com.jme.input.ChaseCamera
java_import com.jme.input.InputHandler
java_import com.jme.input.KeyBindingManager
java_import com.jme.input.KeyInput
java_import com.jme.input.thirdperson.ThirdPersonMouseLook
java_import com.jme.light.DirectionalLight
java_import com.jme.math.FastMath
java_import com.jme.math.Vector3f
java_import com.jme.renderer.Camera
java_import com.jme.renderer.ColorRGBA
java_import com.jme.renderer.Renderer
java_import com.jme.renderer.pass.BasicPassManager
java_import com.jme.renderer.pass.RenderPass
java_import com.jme.renderer.pass.ShadowedRenderPass
java_import com.jme.scene.Node
java_import com.jme.scene.Skybox
java_import com.jme.scene.Spatial
java_import com.jme.scene.state.CullState
java_import com.jme.scene.state.LightState
java_import com.jme.scene.state.TextureState
java_import com.jme.scene.state.ZBufferState
java_import com.jme.system.DisplaySystem
java_import com.jme.system.JmeException
java_import com.jme.util.TextureManager
java_import com.jme.util.Timer
java_import com.jme.util.export.binary.BinaryJava_Importer
java_import com.jmex.terrain.TerrainBlock
java_import com.jmex.terrain.util.MidPointHeightMap
java_import com.jmex.terrain.util.ProceduralTextureGenerator

# From flagrush tutorial in jmonkeyengine source
class Lesson9 < BaseGame
  $logger = Logger.getLogger("Lesson9")

  def initialize
    super()
    @normal = Vector3f.new
    @shadowPass = ShadowedRenderPass.new
    setConfigShowMode(ConfigShowMode.AlwaysShow, Lesson9.class.getClassLoader().getResource("jmetest/data/images/FlagRush.png"))
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
    @skybox.setLocalTranslation(cam.getLocation())
    @skybox.updateGeometricState(0, true)
        
    # if escape was pressed, we exit
    if (KeyBindingManager.getKeyBindingManager().isValidCommand("exit"))
      finished = true
    end
        
    #We don't want the chase camera to go below the world, so always keep 
    #it 2 units above the level.
    if(@cam.getLocation().y < (@tb.getHeight(cam.getLocation())+2))
      @cam.getLocation().y = @tb.getHeight(cam.getLocation()) + 2
      @cam.update()
    end
        
    #make sure that if the player left the level we don't crash. When we add collisions,
    #the fence will do its job and keep the player inside.
    characterMinHeight = @tb.getHeight(@player.getLocalTranslation())+@agl
    if (!Float.isInfinite(characterMinHeight) && !Float.isNaN(characterMinHeight))
      @player.getLocalTranslation().y = characterMinHeight
    end
        
    #get the normal of the terrain at our current location. We then apply it to the up vector
    #of the player.
    @tb.getSurfaceNormal(@player.getLocalTranslation(), @normal)
    if(@normal != null)
      @player.rotateUpTo(@normal)
    end
        
    #Because we are changing the scene (moving the skybox and player) we need to update
    #the graph.
    @scene.updateGeometricState(interpolation, true)
  end

  def render(float interpolation)
      # Clear the screen
      display.getRenderer().clearBuffers()
      # Have the PassManager render.
      @passManager.renderPasses(display.getRenderer())
  end

  def initSystem
    # store the settings information
    @width = settings.getWidth()
    @height = settings.getHeight()
    @depth = settings.getDepth()
    @freq = settings.getFrequency()
    @fullscreen = settings.isFullscreen()
        
    begin
      display = DisplaySystem.getDisplaySystem(settings.getRenderer())
      display.setMinStencilBits(8)
      display.createWindow(@width, @height, @depth, @freq, @fullscreen)

      @cam = display.getRenderer().createCamera(@width, @height)
    rescue (JmeException => e)
      $logger.log(Level.SEVERE, "Could not create displaySystem", e)
      java.lang.System.exit(1)
    end

    # set the background to black
    display.getRenderer().setBackgroundColor(ColorRGBA.black.clone())

    # initialize the camera
    @cam.setFrustumPerspective(45.0f, @width.to_f / @height.to_f, 1, 5000)
    @cam.setLocation(new Vector3f(200,1000,200))
        
    # Signal that we've changed our camera's location/frustum.
    @cam.update()

    # Get a high resolution timer for FPS updates.
    @timer = Timer.getTimer()

    display.getRenderer().setCamera(@cam)

    KeyBindingManager.getKeyBindingManager().set("exit", KeyInput.KEY_ESCAPE)
  end

  def initGame
    display.setTitle("Flag Rush")
        
    @scene = new Node("Scene graph node")
    # Create a ZBuffer to display pixels closest to the camera above farther ones.
    buf = display.getRenderer().createZBufferState()
    buf.setEnabled(true)
    buf.setFunction(ZBufferState.TestFunction.LessThanOrEqualTo)
    @scene.setRenderState(buf)
        
    #Time for a little optimization. We don't need to render back face triangles, so lets
    #not. This will give us a performance boost for very little effort.
    cs = display.getRenderer().createCullState()
    cs.setCullFace(CullState.Face.Back)
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
    @scene.updateGeometricState(0.0f, true)
    @scene.updateRenderState()
  end
    
  def buildPassManager()
    @passManager = BasicPassManager.new()

    # Add skybox first to make sure it is in the background
    RenderPass rPass = RenderPass.new()
    rPass.add(@skybox)
    @passManager.add(rPass)

    @shadowPass.add(@scene)
    @shadowPass.addOccluder(@player)
    @shadowPass.setRenderShadows(true)
    @shadowPass.setLightingMethod(ShadowedRenderPass.LightingMethod.Modulative)
    @passManager.add(@shadowPass)
  end

  def buildFlag()
    #create the flag and place it
    @flag = Flag.new(@tb)
    @scene.attachChild(@flag)
    @flag.placeFlag()
  end
    
  def buildPlayer()
     model = null
        try {
            URL bikeFile = Lesson9.class.getClassLoader().getResource("jmetest/data/model/bike.jme")
            BinaryImporter import = new BinaryImporter()
            model = (Spatial)importer.load(bikeFile.openStream())
            model.setModelBound(new BoundingBox())
            model.updateModelBound()
            #scale it to be MUCH smaller than it is originally
            model.setLocalScale(.0025f)
        } catch (IOException e) {
            logger
                    .throwing(this.getClass().toString(), "buildPlayer()",
                            e)
        }
        
        #set the vehicles attributes (these numbers can be thought
        #of as Unit/Second).
        @player = new Vehicle("Player Node", model)
        @player.setAcceleration(15)
        @player.setBraking(15)
        @player.setTurnSpeed(2.5f)
        @player.setWeight(25)
        @player.setMaxSpeed(25)
        @player.setMinSpeed(15)
        
        @player.setLocalTranslation(new Vector3f(100,0, 100))
        @scene.attachChild(@player)
        @scene.updateGeometricState(0, true)
        #we now store this initial value, because we are rotating the wheels the bounding box will
        #change each frame.
        @agl = ((BoundingBox)player.getWorldBound()).yExtent
        @player.setRenderQueueMode(Renderer.QUEUE_OPAQUE)
    }
    
    /**
     * buildEnvironment will create a fence. 
     */
    private void buildEnvironment() {
        #This is the main node of our fence
        @fence = new ForceFieldFence("fence")
        
        #we will do a little 'tweaking' by hand to make it fit in the terrain a bit better.
        #first we'll scale the entire "model" by a factor of 5
        @fence.setLocalScale(5)
        #now let's move the fence to to the height of the terrain and in a little bit.
        @fence.setLocalTranslation(new Vector3f(25, @tb.getHeight(25,25)+10, 25))
        
        @scene.attachChild(@fence)
    }

    /**
     * creates a light for the terrain.
     */
    private void buildLighting() {
        /** Set up a basic, default light. */
        DirectionalLight light = new DirectionalLight()
        light.setDiffuse(new ColorRGBA(1.0f, 1.0f, 1.0f, 1.0f))
        light.setAmbient(new ColorRGBA(0.5f, 0.5f, 0.5f, .5f))
        light.setDirection(new Vector3f(1,-1,0))
        light.setShadowCaster(true)
        light.setEnabled(true)

          /** Attach the light to a lightState and the lightState to rootNode. */
        LightState lightState = display.getRenderer().createLightState()
        lightState.setEnabled(true)
        lightState.setGlobalAmbient(new ColorRGBA(.2f, .2f, .2f, 1f))
        lightState.attach(light)
        @scene.setRenderState(lightState)
    }

    /**
     * build the height map and terrain block.
     */
    private void buildTerrain() {
        
        
        MidPointHeightMap heightMap = new MidPointHeightMap(64, 1f)
        # Scale the data
        Vector3f terrainScale = new Vector3f(4, 0.0575f, 4)
        # create a terrainblock
         @tb = new TerrainBlock("Terrain", heightMap.getSize(), terrainScale,
                heightMap.getHeightMap(), new Vector3f(0, 0, 0))

        @tb.setModelBound(new BoundingBox())
        @tb.updateModelBound()

        # generate a terrain texture with 2 textures
        ProceduralTextureGenerator pt = new ProceduralTextureGenerator(
                heightMap)
        pt.addTexture(new ImageIcon(TestTerrain.class.getClassLoader()
                .getResource("jmetest/data/texture/grassb.png")), -128, 0, 128)
        pt.addTexture(new ImageIcon(TestTerrain.class.getClassLoader()
                .getResource("jmetest/data/texture/dirt.jpg")), 0, 128, 255)
        pt.addTexture(new ImageIcon(TestTerrain.class.getClassLoader()
                .getResource("jmetest/data/texture/highest.jpg")), 128, 255,
                384)
        pt.createTexture(32)
        
        # assign the texture to the terrain
        TextureState ts = display.getRenderer().createTextureState()
        Texture t1 = TextureManager.loadTexture(pt.getImageIcon().getImage(),
                Texture.MinificationFilter.Trilinear, Texture.MagnificationFilter.Bilinear, true)
        ts.setTexture(t1, 0)
        
        #load a detail texture and set the combine modes for the two terrain textures.
        Texture t2 = TextureManager.loadTexture(
                TestTerrain.class.getClassLoader().getResource(
                "jmetest/data/texture/Detail.jpg"),
                Texture.MinificationFilter.Trilinear,
                Texture.MagnificationFilter.Bilinear)

        ts.setTexture(t2, 1)
        t2.setWrap(Texture.WrapMode.Repeat)

        t1.setApply(Texture.ApplyMode.Combine)
        t1.setCombineFuncRGB(Texture.CombinerFunctionRGB.Modulate)
        t1.setCombineSrc0RGB(Texture.CombinerSource.CurrentTexture)
        t1.setCombineOp0RGB(Texture.CombinerOperandRGB.SourceColor)
        t1.setCombineSrc1RGB(Texture.CombinerSource.PrimaryColor)
        t1.setCombineOp1RGB(Texture.CombinerOperandRGB.SourceColor)

        t2.setApply(Texture.ApplyMode.Combine)
        t2.setCombineFuncRGB(Texture.CombinerFunctionRGB.AddSigned)
        t2.setCombineSrc0RGB(Texture.CombinerSource.CurrentTexture)
        t2.setCombineOp0RGB(Texture.CombinerOperandRGB.SourceColor)
        t2.setCombineSrc1RGB(Texture.CombinerSource.Previous)
        t2.setCombineOp1RGB(Texture.CombinerOperandRGB.SourceColor)

        @tb.setRenderState(ts)
        #set the detail parameters.
        @tb.setDetailTexture(1, 16)
        @tb.setRenderQueueMode(Renderer.QUEUE_OPAQUE)
        @scene.attachChild(@tb)
        
        
    }
    
    /**
     * buildSkyBox creates a new skybox object with all the proper textures. The
     * textures used are the standard skybox textures from all the tests.
     *
     */
    private void buildSkyBox() {
        @skybox = new Skybox("skybox", 10, 10, 10)

        Texture north = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/north.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)
        Texture south = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/south.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)
        Texture east = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/east.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)
        Texture west = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/west.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)
        Texture up = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/top.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)
        Texture down = TextureManager.loadTexture(
            TestSkybox.class.getClassLoader().getResource(
            "jmetest/data/texture/bottom.jpg"),
            Texture.MinificationFilter.BilinearNearestMipMap,
            Texture.MagnificationFilter.Bilinear)

        @skybox.setTexture(Skybox.Face.North, north)
        @skybox.setTexture(Skybox.Face.West, west)
        @skybox.setTexture(Skybox.Face.South, south)
        @skybox.setTexture(Skybox.Face.East, east)
        @skybox.setTexture(Skybox.Face.Up, up)
        @skybox.setTexture(Skybox.Face.Down, down)
        @skybox.preloadTextures()
        @skybox.updateRenderState()
    }
    
    /**
     * set the basic parameters of the chase camera. This includes the offset. We want
     * to be behind the vehicle and a little above it. So we will the offset as 0 for
     * x and z, but be 1.5 times higher than the node.
     * 
     * We then set the roll out parameters (2 units is the closest the camera can get, and
     * 5 is the furthest).
     *
     */
    private void buildChaseCamera() {
        HashMap<String, Object> props = new HashMap<String, Object>()
        props.put(ThirdPersonMouseLook.PROP_MAXROLLOUT, "6")
        props.put(ThirdPersonMouseLook.PROP_MINROLLOUT, "3")
        props.put(ThirdPersonMouseLook.PROP_MAXASCENT, ""+45 * FastMath.DEG_TO_RAD)
        props.put(ChaseCamera.PROP_INITIALSPHERECOORDS, new Vector3f(5, 0, 30 * FastMath.DEG_TO_RAD))
        props.put(ChaseCamera.PROP_DAMPINGK, "4")
        props.put(ChaseCamera.PROP_SPRINGK, "9")
        @chaser = new ChaseCamera(@cam, @player, props)
        @chaser.setMaxDistance(8)
        @chaser.setMinDistance(2)
    }

    /**
     * create our custom input handler.
     *
     */
    private void buildInput() {
        @input = new FlagRushHandler(@player, settings.getRenderer())
    }
    


    /**
     * will be called if the resolution changes
     * 
     * @see com.jme.app.BaseGame#reinit()
     */
    protected void reinit() {
        display.recreateWindow(@width, @height, @depth, @freq, @fullscreen)
    }
    
    /**
     * close the window and also exit the program.
     */
    protected void quit() {
        super.quit()
        System.exit(0)
    }

    /**
     * clean up the textures.
     * 
     * @see com.jme.app.BaseGame#cleanup()
     */
    protected void cleanup() {

    }
}

Lesson9.new().start()
