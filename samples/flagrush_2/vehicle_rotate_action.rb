java_import com.jme.input.action.InputActionEvent
java_import com.jme.input.action.KeyInputAction
java_import com.jme.math.FastMath
java_import com.jme.math.Matrix3f

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
    @incr = Matrix3f.new()
    @tempMa = Matrix3f.new()
    @tempMb = Matrix3f.new()

    # we are using +Y as our up
    @upAxis = Vector3f.new(0,1,0)
    @modifier = 1
  end

  # turn the vehicle by its turning speed. If the vehicle is traveling 
  # backwards, swap direction.
  def performAction(evt)
    if(@vehicle.getVelocity() > -FastMath::FLT_EPSILON && @vehicle.getVelocity() < FastMath::FLT_EPSILON)
        return
    end
    # affect the direction
    if(@direction == LEFT)
      @modifier = 1
    elsif(@direction == RIGHT)
      @modifier = -1;
    end
    # we want to turn differently depending on which direction we are traveling in.
    if(@vehicle.getVelocity < 0)
      @incr.fromAngleNormalAxis(-@modifier * @vehicle.getTurnSpeed() * evt.getTime(), @upAxis)
    else
      @incr.fromAngleNormalAxis(@modifier * @vehicle.getTurnSpeed() * evt.getTime(), @upAxis)
    end
    @vehicle.getLocalRotation().fromRotationMatrix(@incr.mult(@vehicle.getLocalRotation().toRotationMatrix(@tempMa), @tempMb))
    @vehicle.getLocalRotation().normalize()
    @vehicle.setRotateOn(@modifier)
  end
end
