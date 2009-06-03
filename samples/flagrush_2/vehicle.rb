# Vehicle will be a node that handles the movement of a vehicle in the
# game. It has parameters that define its acceleration and speed as well
# as braking. The turn speed defines what kind of handling it has, and the
# weight will define things such as friction for drifting, how fast it falls
# etc. (originally from Mark Powell)
class Vehicle < Node
  LEAN_BUFFER = 0.05
    
  # Basic constructor takes the model that represents the graphical 
  # aspects of this Vehicle.
  def initialize(id, model, max_speed, min_speed, weight, acceleration, braking, turn_speed)
    super(id)
    set_model(model)
    @velocity = 0
    @max_speed = max_speed
    @min_speed = min_speed
    @weight = weight
    @acceleration = acceleration
    @braking = braking
    @turn_speed = turn_speed
    @temp_va = Vector3f.new()
    @lean_axis = Vector3f.new(0,0,1)
    @q = Quaternion.new()
    @wheel_axis = Vector3f.new(0, 1, 0)
    @angle = 0
    @rot_quat = Quaternion.new()
    @lean = 0
    @lean_angle = 0
  end
    
  # update applies the translation to the vehicle based on the time passed.
  def update(time)
    localTranslation.addLocal(self.localRotation.get_rotation_column(2, @temp_va).multLocal(@velocity * time))
    rotateWheels(time);
    processLean(time);
  end
    
  # rotateWheels will rotate the wheel (front and back) a certain angle based on
  # the velocity of the bike.
  def rotateWheels(time)
    # Rotate the tires if the vehicle is moving.
    if (vehicleIsMoving())
      if(@velocity > FastMath::FLT_EPSILON)
        @angle = @angle - ((time) * @velocity * 0.5)
        if (@angle < -360)
            @angle = 0
        end
      else
        @angle = @angle + ((time) * @velocity * 0.5)
        if (@angle > 360)
          @angle = 0;
        end
      end
      @rot_quat.fromAngleAxis(@angle, @wheel_axis)
      @frontwheel.local_rotation.multLocal(@rot_quat)
      @backwheel.setLocalRotation(@frontwheel.local_rotation())
    end
  end

  # Convience method that determines if the vehicle is moving or not. This is
  # given if the velocity is approximately zero, taking float point rounding
  # errors into account.
  def vehicleIsMoving()
    return @velocity > FastMath::FLT_EPSILON || @velocity < -FastMath::FLT_EPSILON
  end

  # processlean will adjust the angle of the bike model based on 
  # a lean factor. We angle the bike rather than the Vehicle, as the
  # Vehicle is worried about position about the terrain.
  def processLean(time)
    # check if we are leaning at all
    if(@lean != 0)
      if(@lean == -1 && @lean_angle < 0)
        @lean_angle += -@lean * 4 * time
      elsif(@lean == 1 && @lean_angle > 0)
        @lean_angle += -@lean * 4 * time;
      else
        @lean_angle += -@lean * 2 * time;
      end
      # max lean is 1 and -1
      if(@lean_angle > 1)
        @lean_angle = 1;
      elsif(@lean_angle < -1)
        @lean_angle = -1
      end
    else # we are not leaning, so right ourself back up.
      if(@lean_angle < LEAN_BUFFER && @lean_angle > -LEAN_BUFFER)
        @lean_angle = 0
      elsif(@lean_angle < -FastMath::FLT_EPSILON)
        @lean_angle += time * 4
      elsif(@lean_angle > FastMath::FLT_EPSILON)
        @lean_angle -= time * 4
      else
        @lean_angle = 0
      end
    end
       
    @q.fromAngleAxis(@lean_angle, @lean_axis)
    @model.setLocalRotation(@q)
        
    @lean = 0;
  end
    
  # set the weight of this vehicle
  def setWeight(weight)
    @weight = weight
  end
    
  # retrieves the weight of this vehicle.
  def weight
    return @weight
  end

  # the acceleration of this vehicle.
  def acceleration
    return @acceleration
  end

  # set the acceleration rate of this vehicle
  def setAcceleration(acceleration)
    @acceleration = acceleration
  end

  # retrieves the braking speed of this vehicle.
  def braking()
    return @braking
  end

  # set the braking speed of this vehicle
  def setBraking(braking)
    @braking = braking
  end

  # retrieves the model Spatial of this vehicle.
  def model
    return @model
  end

  # sets the model spatial of this vehicle. It first
  # detaches any previously attached models.
  def set_model(model)
    detachChild(@model)
    @model = model
    attachChild(@model)
    #obtain references to the front and back wheel
        
    @backwheel = model.get_child("backwheel")
    @frontwheel = model.get_child("frontwheel")
  end

  # retrieves the velocity of this vehicle.
  def velocity
    return @velocity
  end

  # set the velocity of this vehicle
  def velocity=(velocity)
    @velocity = velocity
  end
    
  # retrieves the turn speed of this vehicle.
  def turn_speed
    return @turn_speed
  end

  # set the turn speed of this vehicle
  def turn_speed=(turn_speed)
    @turn_speed = turn_speed
  end
    
  # retrieves the maximum speed of this vehicle.
  def max_speed
    return @max_speed
  end

  # sets the maximum speed of this vehicle.
  def max_speed=(max_speed)
    @max_speed = max_speed;
  end

  # retrieves the minimum speed of this vehicle.
  def min_speed
    return @min_speed
  end

  # sets the minimum speed of this vehicle.
  def min_speed=(min_speed)
    @min_speed = min_speed
  end
    
  # brake adjusts the velocity of the vehicle based on the braking speed. If the
  # velocity reaches 0, braking will put the vehicle in reverse up to the 
  # minimum speed.
  def brake(time)
    @velocity -= time * @braking
    @velocity = -@min_speed if @velocity < -@min_speed
  end
    
  # accelerate adjusts the velocity of the vehicle based on the acceleration. 
  # The velocity will continue to raise until max_speed is reached, at which 
  # point it will stop.
  def accelerate(time)
    @velocity += time * @acceleration
    @velocity = @max_speed if @velocity > @max_speed
  end
    
  # drift calculates what happens when the vehicle is neither braking or 
  # accelerating. The vehicle will slow down based on its weight.
  def drift(time)
    if @velocity < -FastMath::FLT_EPSILON
      @velocity += ((@weight/5) * time)
      # we are drifting to a stop, so we shouldn't go above 0
      @velocity = 0 if @velocity > 0
    elsif @velocity > FastMath::FLT_EPSILON
      @velocity -= ((@weight/5) * time)
      # we are drifting to a stop, so we shouldn't go below 0
      @velocity = 0 if @velocity < 0
    end
  end

  def rotate_on=(modifier)
    @lean = modifier
  end
end
