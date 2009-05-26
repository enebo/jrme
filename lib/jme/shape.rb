
class Box
  def initialize(*args)
    super
    bound BoundingBox.new
  end
end

class Sphere
  def initialize(*args)
    super
    bound BoundingSphere.new
  end
end
