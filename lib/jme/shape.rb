
class Box
  def initialize(name, x, y, z)
    super(name, Vector3f.new, x, y, z)
    bound BoundingBox.new
  end
end

class Sphere
  def initialize(name, samples, radius)
    super(name, samples, samples, radius)
    bound BoundingSphere.new
  end
end
