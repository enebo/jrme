
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
