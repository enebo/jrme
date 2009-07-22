
class Box
  def initialize(*args)
    super
    bound BoundingBox.new
  end
end

class MultiFaceBox
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

class MultiFaceCube < MultiFaceBox
  def initialize(name, vector, size)
    super(name, vector, size, size, size)
  end
end

class Dome
  def initialize(*args)
    super
    bound BoundingSphere.new
  end
end

class RoundedBox
  def initialize(*args)
    super
    bound BoundingBox.new
  end
end

module Kernel
  def Sphere(name, z_samples, radial_samples, radius)
    Sphere.new(name, Vector3f.new, z_samples, radial_samples, radius)
  end

  def Cube(name, size)
    Cube.new(name, Vector3f.new, size)
  end

  def MultiFaceCube(name, size)
    Cube.new(name, Vector3f.new, size)
  end
end
