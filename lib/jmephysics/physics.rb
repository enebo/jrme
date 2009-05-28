class PhysicsSpace
  def create_dynamic(&block)
    dynamic_node = createDynamicNode
    dynamic_node.instance_eval &block if block_given?
    dynamic_node.frobnicate
    dynamic_node
  end

  def create_static(&block)
    static_node = createStaticNode
    static_node.instance_eval &block if block_given?
    static_node.frobnicate
    static_node
  end
end

class PhysicsNode
  # Give this physics node a geometrical shape
  def geometry(physical_node)
    attach_child physical_node
    @geometry = true
    physical_node
  end

  # What material is this node made of
  def made_of(material)
    self.material = material
    @material = true
  end

  def frobnicate
    if @geometry
      generate_physics_geometry 
      compute_mass if @material
    end
  end
end
