# Rotate a wheel based on a supplied Physics Source.
module WheelRotator
  def initialize_wheel
    @wheel_axis = Vector3f.new 0, 1, 0
    @angle = 0
    @rot_quat = Quaternion.new
  end

  def update(time, physics_source)
    # Rotate the wheel if the vehicle is moving.
    if physics_source.moving?
      if physics_source.velocity > FastMath::FLT_EPSILON
        @angle = @angle - ((time) * physics_source.velocity * 0.5)
        @angle = 0 if @angle < -360
      else
        @angle = @angle + ((time) * physics_source.velocity * 0.5)
        @angle = 0 if @angle > 360
      end
      @rot_quat.fromAngleAxis(@angle, @wheel_axis)
      local_rotation.multLocal(@rot_quat)
    end
  end
end
