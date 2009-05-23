
class Box
  def initialize(*args)
    super
    bound BoundingBox.new
  end
end

class Sphere
  def initialize(name, samples, radius)
    super(name, samples, samples, radius)
    bound BoundingSphere.new
  end
end
