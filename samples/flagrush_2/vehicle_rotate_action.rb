# VehicleRotateLeftAction turns the vehicle to the left (while 
class VehicleRotateAction < KeyInputAction
  RIGHT = 0
  LEFT = 1
   
  # create a new action with the vehicle to turn.
  def initialize(vehicle, direction)
    super()
    @vehicle = vehicle
    @direction = direction
    # temporary variables to handle rotation
    @incr = Matrix3f.new
    @tempMa = Matrix3f.new
    @tempMb = Matrix3f.new

    # we are using +Y as our up
    @up_axis = Vector3f.new 0,1,0
    @modifier = 1
  end

  # turn the vehicle by its turning speed. If the vehicle is traveling 
  # backwards, swap direction.
  def performAction(evt)
    return if @vehicle.velocity > -FastMath::FLT_EPSILON && @vehicle.velocity < FastMath::FLT_EPSILON

    # affect the direction
    if(@direction == LEFT)
      @modifier = 1
    elsif(@direction == RIGHT)
      @modifier = -1
    end

    # we want to turn differently depending on which direction we are traveling
    if @vehicle.velocity < 0
      @incr.from_angle_normal_axis -@modifier * @vehicle.turn_speed * evt.time, @up_axis
    else
      @incr.from_angle_normal_axis @modifier * @vehicle.turn_speed * evt.time, @up_axis
    end
    @vehicle.local_rotation.from_rotation_matrix @incr.mult(@vehicle.local_rotation.to_rotation_matrix(@tempMa), @tempMb)
    @vehicle.local_rotation.normalize
    @vehicle.rotate_on = @modifier
  end
end
