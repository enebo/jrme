# VehicleRotateLeftAction turns the vehicle to the left (while 
class VehicleRotateAction < KeyInputAction
  RIGHT, LEFT = -1, 1
   
  # create a new action with the vehicle to turn.
  def initialize(vehicle, direction)
    super()
    @vehicle, @direction = vehicle, direction
    # temporary variables to handle rotation
    @incr, @tempMa, @tempMb = Matrix3f.new, Matrix3f.new, Matrix3f.new
  end

  # turn the vehicle by its turning speed. If the vehicle is traveling 
  # backwards, swap direction.
  def performAction(evt)
    return if @vehicle.velocity > -FastMath::FLT_EPSILON && @vehicle.velocity < FastMath::FLT_EPSILON

    # we want to turn differently depending on which direction we are traveling
    if @vehicle.velocity < 0
      @incr.from_angle_normal_axis -@direction * @vehicle.turn_speed * evt.time, YAXIS
    else
      @incr.from_angle_normal_axis @direction * @vehicle.turn_speed * evt.time, YAXIS
    end
    @vehicle.local_rotation.from_rotation_matrix @incr.mult(@vehicle.local_rotation.to_rotation_matrix(@tempMa), @tempMb)
    @vehicle.local_rotation.normalize
    @vehicle.lean = @direction
  end
end
