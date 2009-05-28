class Quaternion
  def self.fromAngleAxis(angle, axis)
    quaternion = Quaternion.new
    quaternion.fromAngleAxis(angle, axis)
  end
end

class Vector3f
  def to_s
    "[#{format("%0.2d", x)}, #{format("%0.2d", y)}, #{format("%0.2d", z)}]"
  end
end

# Definition of normalized vectors about the main axis'
XAXIS = Vector3f.new(1, 0, 0)
NEG_XAXIS = Vector3f.new(-1, 0, 0)
class << XAXIS
  def -@
    NEG_XAXIS
  end
end

YAXIS = Vector3f.new(0, 1, 0)
NEG_YAXIS = Vector3f.new(0, -1, 0)
class << YAXIS
  def -@
    NEG_YAXIS
  end
end

ZAXIS = Vector3f.new(0, 0, 1)
NEG_ZAXIS = Vector3f.new(0, 0, -1)
class << ZAXIS
  def -@
    NEG_ZAXIS
  end
end

module Kernel
  def Vector3f(x, y, z)
    Vector3f.new x, y, z
  end
end
