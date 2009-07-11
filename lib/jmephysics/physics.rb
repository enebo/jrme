class PhysicsSpace
  def create_dynamic(&code)
    node = createDynamicNode
    code.arity == 1 ? code[self] : node.instance_eval(&code) if block_given?
    node.frobnicate
  end

  def create_static(&code)
    node = createStaticNode
    code.arity == 1 ? code[self] : node.instance_eval(&code) if block_given?
    node.frobnicate
  end
end

class PhysicsNode
  # Give this physics node a geometrical shape
  def geometry(physical_node)
    attach_child physical_node
    physical_node
  end

  # What material is this node made of
  def made_of(material)
    self.material = material
    @material = true
  end

  def frobnicate
    generate_physics_geometry
    compute_mass if @material && self.kind_of?(DynamicPhysicsNode)
    self
  end
end
