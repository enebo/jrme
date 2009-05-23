class ForceFieldFence < Node
  def initialize
    super "fence"

    build_fence
  end

  def update(interpolation)
    # Speed of force field based on tpf value and it should always be [0-1]
    @texture.translation.y += 0.3 * interpolation
    @texture.translation.y = 0 if @texture.translation.y > 1
  end

  def build_fence
    # This cylinder will act as the four main posts at each corner
    postGeometry = Cylinder.new("post", 10, 10, 1, 10);
    q = Quaternion.new
    # rotate the cylinder to be vertical
    q.fromAngleAxis(FastMath::PI/2, Vector3f.new(1,0,0))
    postGeometry.setLocalRotation(q)
    postGeometry.setModelBound(BoundingBox.new)
    postGeometry.updateModelBound
 
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
 
    # This cylinder will be the horizontal struts that hold the field in place
    strutGeometry = Cylinder.new("strut", 10,10, 0.125, 32);
    strutGeometry.setModelBound(BoundingBox.new)
    strutGeometry.updateModelBound
 
    # again, we'll share this mesh.
    # Some we need to rotate to connect various posts.
    strut1 = SharedMesh.new("strut1", strutGeometry);
    rotate90 = Quaternion.new
    rotate90.fromAngleAxis(FastMath::PI/2, Vector3f.new(0,1,0))
    strut1.setLocalRotation(rotate90)
    strut1.setLocalTranslation(Vector3f.new(16,3,0))
    strut2 = SharedMesh.new("strut2", strutGeometry)
    strut2.setLocalTranslation(Vector3f.new(0,3,16))
    strut3 = SharedMesh.new("strut3", strutGeometry)
    strut3.setLocalTranslation(Vector3f.new(32,3,16))
    strut4 = SharedMesh.new("strut4", strutGeometry)
    strut4.setLocalRotation(rotate90)
    strut4.setLocalTranslation(Vector3f.new(16,3,32))
 
    # Create the actual forcefield 
    # The first box handles the X-axis, the second handles the z-axis.
    # We don't rotate the box as a demonstration on how boxes can be 
    # created differently.
    forceFieldX = Box.new("forceFieldX", Vector3f.new(-16, -3, -0.1), Vector3f.new(16, 3, 0.1))
    forceFieldX.setModelBound(BoundingBox.new)
    forceFieldX.updateModelBound
    # We are going to share these boxes as well
    forceFieldX1 = SharedMesh.new("forceFieldX1",forceFieldX)
    forceFieldX1.setLocalTranslation(Vector3f.new(16,0,0))
    forceFieldX2 = SharedMesh.new("forceFieldX2",forceFieldX)
    forceFieldX2.setLocalTranslation(Vector3f.new(16,0,32))
 
    # The other box for the Z axis
    forceFieldZ = Box.new("forceFieldZ", Vector3f.new(-0.1, -3, -16), Vector3f.new(0.1, 3, 16))
    forceFieldZ.setModelBound(BoundingBox.new)
    forceFieldZ.updateModelBound
    # and again we will share it
    forceFieldZ1 = SharedMesh.new("forceFieldZ1",forceFieldZ)
    forceFieldZ1.setLocalTranslation(Vector3f.new(0,0,16))
    forceFieldZ2 = SharedMesh.new("forceFieldZ2",forceFieldZ)
    forceFieldZ2.setLocalTranslation(Vector3f.new(32,0,16))
 
    # add all the force fields to a single node and make this node part of
    # the transparent queue.
    forceFieldNode = Node.new("forceFieldNode")
    forceFieldNode.setRenderQueueMode(Renderer::QUEUE_TRANSPARENT)
    forceFieldNode << forceFieldX1 << forceFieldX2 << forceFieldZ1 << forceFieldZ2
 
    # Add the alpha values for the transparent node
    as1 = DisplaySystem.display_system.renderer.createBlendState.set! :blend_enabled => true,
      :source_function => BlendState::SourceFunction::SourceAlpha,
      :destination_function => BlendState::DestinationFunction::One,
      :test_enabled => true, :enabled => true,
      :test_function => BlendState::TestFunction::GreaterThan
 
    forceFieldNode.setRenderState(as1)
 
    # load a texture for the force field elements
    ts = DisplaySystem.display_system.renderer.createTextureState
    @texture = TextureManager.load "data/texture/reflector.jpg"
    @texture.setWrap(Texture::WrapMode::Repeat);
    @texture.setTranslation(Vector3f.new)
    ts.setTexture @texture
 
    forceFieldNode.setRenderState(ts);
 
    # put all the posts into a tower node
    towerNode = Node.new("tower")
    towerNode << post1 << post2 << post3 << post4
 
    # add the tower to the opaque queue (we don't want to be able to see 
    # through them) and we do want to see them through the forcefield.
    towerNode.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
 
    # load a texture for the towers
    ts2 = DisplaySystem.display_system.renderer.createTextureState
    t2 = TextureManager.load "data/texture/post.jpg"
    ts2.setTexture(t2)
 
    towerNode.setRenderState(ts2)
 
    # put all the struts into a single node.
    strutNode = Node.new("strutNode")
    strutNode << strut1 << strut2 << strut3 << strut4
    # this too is in the opaque queue.
    strutNode.setRenderQueueMode(Renderer::QUEUE_OPAQUE)
 
    # load a texture for the struts
    ts3 = DisplaySystem.display_system.renderer.createTextureState
    t3 = TextureManager.load "data/texture/rust.jpg"
    ts3.setTexture(t3);
 
    strutNode.setRenderState(ts3);
  
    # Attach all the pieces to the main fence node
    self << forceFieldNode << towerNode << strutNode
  end
end
