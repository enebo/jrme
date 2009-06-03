# ForceFieldFence creates a new Node that contains all the objects that make up the 
# fence object in the game. (from tutorial form Mark Powell)
class ForceFieldFence < Node
  def initialize(name)
    super(name)
    build_fence
  end
    
  def update(interpolation)
    # We will use the interpolation value to keep the speed of the forcefield 
    # consistent between computers. y coord to show motion.
    @t.translation.y += 0.3 * interpolation
    @t.translation.y = 0 if @t.translation.y > 1
  end
    
  # create all the fence geometry.
  def build_fence
    # This cylinder will act as the four main posts at each corner
    post_geometry = Cylinder.new("post", 10, 10, 1, 10)
    q = Quaternion.new
    # rotate the cylinder to be vertical
    q.fromAngleAxis FastMath::PI/2, Vector3f.new(1,0,0)
    post_geometry.local_rotation = q
    post_geometry.model_bound = BoundingBox.new
    post_geometry.update_model_bound
        
    # We will share the post 4 times (one for each post)
    # It is *not* a good idea to add the original geometry 
    # as the sharedmeshes will alter its local values.
    # We then translate the posts into position. 
    # Magic numbers are bad, but help illustrate the point.:)
    post1 = SharedMesh.new "post1", post_geometry
    post1.local_translation = Vector3f.new(0,0.5,0)
    post2 = SharedMesh.new("post2", post_geometry)
    post2.local_translation = Vector3f.new(32,0.5,0)
    post3 = SharedMesh.new("post3", post_geometry)
    post3.local_translation = Vector3f.new(0,0.5,32)
    post4 = SharedMesh.new("post4", post_geometry)
    post4.local_translation = Vector3f.new(32,0.5,32)
        
    # This cylinder will be the horizontal struts that hold
    # the field in place.
    strut_geometry = Cylinder.new("strut", 10,10, 0.125, 32);
    strut_geometry.model_bound = BoundingBox.new
    strut_geometry.update_model_bound
        
    # again, we'll share this mesh.
    # Some we need to rotate to connect various posts.
    strut1 = SharedMesh.new("strut1", strut_geometry)
    rotate90 = Quaternion.new()
    rotate90.from_angle_axis FastMath::PI/2, Vector3f.new(0,1,0)
    strut1.local_rotation = rotate90
    strut1.local_translation = Vector3f.new(16,3,0)
    strut2 = SharedMesh.new("strut2", strut_geometry)
    strut2.local_translation = Vector3f.new(0,3,16)
    strut3 = SharedMesh.new("strut3", strut_geometry)
    strut3.local_translation = Vector3f.new(32,3,16)
    strut4 = SharedMesh.new("strut4", strut_geometry)
    strut4.local_rotation = rotate90
    strut4.local_translation = Vector3f.new(16,3,32)
        
    # Create the actual forcefield 
    # The first box handles the X-axis, the second handles the z-axis.
    # We don't rotate the box as a demonstration on how boxes can be 
    # created differently.
    forceFieldX = Box.new("forceFieldX", Vector3f.new(-16, -3, -0.1), Vector3f.new(16, 3, 0.1))
    forceFieldX.model_bound = BoundingBox.new
    forceFieldX.update_model_bound
    # We are going to share these boxes as well
    forceFieldX1 = SharedMesh.new("forceFieldX1",forceFieldX)
    forceFieldX1.local_translation = Vector3f.new(16,0,0)
    forceFieldX2 = SharedMesh.new("forceFieldX2",forceFieldX)
    forceFieldX2.local_translation = Vector3f.new(16,0,32)
        
    # The other box for the Z axis
    forceFieldZ = Box.new("forceFieldZ", Vector3f.new(-0.1, -3, -16), Vector3f.new(0.1, 3, 16))
    forceFieldZ.model_bound = BoundingBox.new
    forceFieldZ.update_model_bound
    # and again we will share it
    forceFieldZ1 = SharedMesh.new("forceFieldZ1",forceFieldZ)
    forceFieldZ1.local_translation = Vector3f.new(0,0,16)
    forceFieldZ2 = SharedMesh.new("forceFieldZ2",forceFieldZ)
    forceFieldZ2.local_translation = Vector3f.new(32,0,16)
        
    # add all the force fields to a single node and make this node part of
    # the transparent queue.
    forceFieldNode = Node.new("forceFieldNode")
    forceFieldNode.setRenderQueueMode(Renderer::QUEUE_TRANSPARENT)
    forceFieldNode.attach_child forceFieldX1
    forceFieldNode.attach_child forceFieldX2
    forceFieldNode.attach_child forceFieldZ1
    forceFieldNode.attach_child forceFieldZ2
        
    # Add the alpha values for the transparent node
    as1 = DisplaySystem.display_system.renderer.create_blend_state
    as1.blend_enabled = true
    as1.source_function = BlendState::SourceFunction::SourceAlpha
    as1.destination_function = BlendState::DestinationFunction::One
    as1.test_enabled = true
    as1.test_function = BlendState::TestFunction::GreaterThan
    as1.enabled = true
        
    forceFieldNode.setRenderState(as1)
        
    # load a texture for the force field elements
    ts = DisplaySystem.display_system.renderer.create_texture_state
    @t = TextureManager.loadTexture(resource("data/texture/reflector.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    @t.wrap = Texture::WrapMode::Repeat
    @t.translation = Vector3f.new
    ts.texture = @t
        
    forceFieldNode.setRenderState ts
        
    # put all the posts into a tower node
    towerNode = Node.new "tower"
    towerNode.attach_child post1
    towerNode.attach_child post2
    towerNode.attach_child post3
    towerNode.attach_child post4
        
    # add the tower to the opaque queue (we don't want to be able to see 
    # through them) and we do want to see them through the forcefield.
    towerNode.render_queue_mode = Renderer::QUEUE_OPAQUE
        
    # load a texture for the towers
    ts2 = DisplaySystem.getDisplaySystem().getRenderer().createTextureState()
    t2 = TextureManager.loadTexture(resource("data/texture/post.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    ts2.texture = t2
        
    towerNode.setRenderState(ts2)
        
    # put all the struts into a single node.
    strutNode = Node.new("strutNode")
    strutNode.attach_child strut1
    strutNode.attach_child strut2
    strutNode.attach_child strut3
    strutNode.attach_child strut4
    # this too is in the opaque queue.
    strutNode.render_queue_mode = Renderer::QUEUE_OPAQUE
        
    # load a texture for the struts
    ts3 = DisplaySystem.display_system.renderer.create_texture_state
    t3 = TextureManager.loadTexture(resource("data/texture/rust.jpg"),
                  Texture::MinificationFilter::Trilinear, Texture::MagnificationFilter::Bilinear)
        
    ts3.texture = t3
        
    strutNode.setRenderState(ts3)
        
    # Attach all the pieces to the main fence node
    attach_child forceFieldNode
    attach_child towerNode
    attach_child strutNode
  end
end
