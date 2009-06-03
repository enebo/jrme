java_import com.jme.bounding.BoundingBox
java_import com.jme.image.Texture
java_import com.jme.math.FastMath
java_import com.jme.math.Quaternion
java_import com.jme.math.Vector3f
java_import com.jme.renderer.Renderer
java_import com.jme.scene.Node
java_import com.jme.scene.SharedMesh
java_import com.jme.scene.shape.Box
java_import com.jme.scene.shape.Cylinder
java_import com.jme.scene.state.BlendState
java_import com.jme.scene.state.TextureState
java_import com.jme.system.DisplaySystem
java_import com.jme.util.TextureManager

# ForceFieldFence creates a new Node that contains all the objects that make up the 
# fence object in the game. (from tutorial form Mark Powell)
class ForceFieldFence < Node
  def initialize(name)
    super(name)
    buildFence()
  end
    
  def update(interpolation)
    #We will use the interpolation value to keep the speed
    # of the forcefield consistent between computers.
    # we update the Y have of the texture matrix to give
    # the appearance the forcefield is moving.
    @t.getTranslation().y += 0.3 * interpolation
    # if the translation is over 1, it's wrapped, so go ahead
    # and check for this (to keep the vector's y value from getting
    # too large.)
    if(@t.getTranslation().y > 1)
      @t.getTranslation().y = 0
    end
  end
    
  # create all the fence geometry.
  def buildFence()
    # This cylinder will act as the four main posts at each corner
    postGeometry = Cylinder.new("post", 10, 10, 1, 10);
    q = Quaternion.new()
    # rotate the cylinder to be vertical
    q.fromAngleAxis(FastMath::PI/2, Vector3f.new(1,0,0))
    postGeometry.setLocalRotation(q)
    postGeometry.setModelBound(BoundingBox.new())
    postGeometry.updateModelBound()
        
    # We will share the post 4 times (one for each post)
    # It is *not* a good idea to add the original geometry 
    # as the sharedmeshes will alter its local values.
    # We then translate the posts into position. 
    # Magic numbers are bad, but help illustrate the point.:)
    post1 = SharedMesh.new("post1", postGeometry)
    post1.setLocalTranslation(Vector3f.new(0,0.5,0))
    post2 = SharedMesh.new("post2", postGeometry)
    post2.setLocalTranslation(Vector3f.new(32,0.5,0))
    post3 = SharedMesh.new("post3", postGeometry)
    post3.setLocalTranslation(Vector3f.new(0,0.5,32))
    post4 = SharedMesh.new("post4", postGeometry)
    post4.setLocalTranslation(Vector3f.new(32,0.5,32))
        
    # This cylinder will be the horizontal struts that hold
    # the field in place.
    strutGeometry = Cylinder.new("strut", 10,10, 0.125, 32);
    strutGeometry.setModelBound(BoundingBox.new())
    strutGeometry.updateModelBound();
        
    # again, we'll share this mesh.
    # Some we need to rotate to connect various posts.
    strut1 = SharedMesh.new("strut1", strutGeometry)
    rotate90 = Quaternion.new()
    rotate90.fromAngleAxis(FastMath::PI/2, Vector3f.new(0,1,0))
    strut1.setLocalRotation(rotate90)
    strut1.setLocalTranslation(Vector3f.new(16,3,0))
    strut2 = SharedMesh.new("strut2", strutGeometry)
    strut2.setLocalTranslation(Vector3f.new(0,3,16))
    strut3 = SharedMesh.new("strut3", strutGeometry)
    strut3.setLocalTranslation(Vector3f.new(32,3,16))
    strut4 = SharedMesh.new("strut4", strutGeometry)
    strut4.setLocalRotation(rotate90)
    strut4.setLocalTranslation(Vector3f.new(16,3,32));
        
    # Create the actual forcefield 
    # The first box handles the X-axis, the second handles the z-axis.
    # We don't rotate the box as a demonstration on how boxes can be 
    # created differently.
    forceFieldX = Box.new("forceFieldX", Vector3f.new(-16, -3, -0.1), Vector3f.new(16, 3, 0.1))
    forceFieldX.setModelBound(BoundingBox.new())
    forceFieldX.updateModelBound()
    # We are going to share these boxes as well
    forceFieldX1 = SharedMesh.new("forceFieldX1",forceFieldX)
    forceFieldX1.setLocalTranslation(Vector3f.new(16,0,0))
    forceFieldX2 = SharedMesh.new("forceFieldX2",forceFieldX)
    forceFieldX2.setLocalTranslation(Vector3f.new(16,0,32))
        
    # The other box for the Z axis
    forceFieldZ = Box.new("forceFieldZ", Vector3f.new(-0.1, -3, -16), Vector3f.new(0.1, 3, 16))
    forceFieldZ.setModelBound(BoundingBox.new())
    forceFieldZ.updateModelBound()
    # and again we will share it
    forceFieldZ1 = SharedMesh.new("forceFieldZ1",forceFieldZ)
    forceFieldZ1.setLocalTranslation(Vector3f.new(0,0,16))
    forceFieldZ2 = SharedMesh.new("forceFieldZ2",forceFieldZ)
    forceFieldZ2.setLocalTranslation(Vector3f.new(32,0,16))
        
    # add all the force fields to a single node and make this node part of
    # the transparent queue.
    forceFieldNode = Node.new("forceFieldNode")
    forceFieldNode.setRenderQueueMode(Renderer::QUEUE_TRANSPARENT)
    forceFieldNode.attachChild(forceFieldX1)
    forceFieldNode.attachChild(forceFieldX2)
    forceFieldNode.attachChild(forceFieldZ1)
    forceFieldNode.attachChild(forceFieldZ2)
        
    # Add the alpha values for the transparent node
    as1 = DisplaySystem.getDisplaySystem().getRenderer().createBlendState();
    as1.setBlendEnabled(true)
    as1.setSourceFunction(BlendState::SourceFunction::SourceAlpha)
    as1.setDestinationFunction(BlendState::DestinationFunction::One)
    as1.setTestEnabled(true)
    as1.setTestFunction(BlendState::TestFunction::GreaterThan)
    as1.setEnabled(true)
        
    forceFieldNode.setRenderState(as1)
        
    # load a texture for the force field elements
    ts = DisplaySystem.getDisplaySystem().getRenderer().createTextureState()
    @t = TextureManager.loadTexture(resource("data/texture/reflector.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    @t.setWrap(Texture::WrapMode::Repeat)
    @t.setTranslation(Vector3f.new())
    ts.setTexture(@t)
        
    forceFieldNode.setRenderState(ts)
        
    # put all the posts into a tower node
    towerNode = Node.new("tower")
    towerNode.attachChild(post1)
    towerNode.attachChild(post2)
    towerNode.attachChild(post3)
    towerNode.attachChild(post4)
        
    # add the tower to the opaque queue (we don't want to be able to see through them)
    # and we do want to see them through the forcefield.
    towerNode.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
        
    # load a texture for the towers
    ts2 = DisplaySystem.getDisplaySystem().getRenderer().createTextureState()
    t2 = TextureManager.loadTexture(resource("data/texture/post.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    ts2.setTexture(t2)
        
    towerNode.setRenderState(ts2)
        
    # put all the struts into a single node.
    strutNode = Node.new("strutNode")
    strutNode.attachChild(strut1)
    strutNode.attachChild(strut2)
    strutNode.attachChild(strut3)
    strutNode.attachChild(strut4)
    # this too is in the opaque queue.
    strutNode.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
        
    # load a texture for the struts
    ts3 = DisplaySystem.getDisplaySystem().getRenderer().createTextureState()
    t3 = TextureManager.loadTexture(resource("data/texture/rust.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    ts3.setTexture(t3)
        
    strutNode.setRenderState(ts3)
        
    # Attach all the pieces to the main fence node
    attachChild(forceFieldNode)
    attachChild(towerNode)
    attachChild(strutNode)
  end
end
