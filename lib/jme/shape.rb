
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

class Cube < Box
  def initialize(name, vector, size)
    super(name, vector, size, size, size)
  end
end
