# Vehicle will be a node that handles the movement of a vehicle in the
# game. It has parameters that define its acceleration and speed as well
# as braking. The turn speed defines what kind of handling it has, and the
# weight will define things such as friction for drifting, how fast it falls
# etc. (originally from Mark Powell)
class Vehicle < Node
  LEAN_BUFFER = 0.05
    
  # Basic constructor takes the model that represents the graphical 
  # aspects of this Vehicle.
  def initialize(id, model, maxSpeed, minSpeed, weight, acceleration, braking, turnSpeed)
    super(id)
    setModel(model)
    @velocity = 0
    @maxSpeed = maxSpeed
    @minSpeed = minSpeed
    @weight = weight
    @acceleration = acceleration
    @braking = braking
    @turnSpeed = turnSpeed
    @tempVa = Vector3f.new()
    @leanAxis = Vector3f.new(0,0,1)
    @q = Quaternion.new()
    @wheelAxis = Vector3f.new(0, 1, 0)
    @angle = 0
    @rotQuat = Quaternion.new()
    @lean = 0
    @leanAngle = 0
  end
    
  # update applies the translation to the vehicle based on the time passed.
  def update(time)
    self.localTranslation.addLocal(self.localRotation.getRotationColumn(2, @tempVa).multLocal(@velocity * time))
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
      @rotQuat.fromAngleAxis(@angle, @wheelAxis)
      @frontwheel.getLocalRotation().multLocal(@rotQuat)
      @backwheel.setLocalRotation(@frontwheel.getLocalRotation())
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
      if(@lean == -1 && @leanAngle < 0)
        @leanAngle += -@lean * 4 * time
      elsif(@lean == 1 && @leanAngle > 0)
        @leanAngle += -@lean * 4 * time;
      else
        @leanAngle += -@lean * 2 * time;
      end
      # max lean is 1 and -1
      if(@leanAngle > 1)
        @leanAngle = 1;
      elsif(@leanAngle < -1)
        @leanAngle = -1
      end
    else # we are not leaning, so right ourself back up.
      if(@leanAngle < LEAN_BUFFER && @leanAngle > -LEAN_BUFFER)
        @leanAngle = 0
      elsif(@leanAngle < -FastMath::FLT_EPSILON)
        @leanAngle += time * 4
      elsif(@leanAngle > FastMath::FLT_EPSILON)
        @leanAngle -= time * 4
      else
        @leanAngle = 0
      end
    end
       
    @q.fromAngleAxis(@leanAngle, @leanAxis)
    @model.setLocalRotation(@q)
        
    @lean = 0;
  end
    
  # set the weight of this vehicle
  def setWeight(weight)
    @weight = weight
  end
    
  # retrieves the weight of this vehicle.
  def getWeight
    return @weight
  end

  # the acceleration of this vehicle.
  def getAcceleration
    return @acceleration
  end

  # set the acceleration rate of this vehicle
  def setAcceleration(acceleration)
    @acceleration = acceleration
  end

  # retrieves the braking speed of this vehicle.
  def getBraking()
    return @braking
  end

  # set the braking speed of this vehicle
  def setBraking(braking)
    @braking = braking
  end

  # retrieves the model Spatial of this vehicle.
  def getModel
    return @model
  end

  # sets the model spatial of this vehicle. It first
  # detaches any previously attached models.
  def setModel(model)
    detachChild(@model)
    @model = model
    attachChild(@model)
    #obtain references to the front and back wheel
        
    @backwheel = model.getChild("backwheel")
    @frontwheel = model.getChild("frontwheel")
  end

  # retrieves the velocity of this vehicle.
  def getVelocity()
    return @velocity
  end

  # set the velocity of this vehicle
  def setVelocity(velocity)
    @velocity = velocity
  end
    
  # retrieves the turn speed of this vehicle.
  def getTurnSpeed()
    return @turnSpeed
  end

  # set the turn speed of this vehicle
  def setTurnSpeed(turnSpeed)
    @turnSpeed = turnSpeed
  end
    
  # retrieves the maximum speed of this vehicle.
  def getMaxSpeed()
    return @maxSpeed
  end

  # sets the maximum speed of this vehicle.
  def setMaxSpeed(maxSpeed)
    @maxSpeed = maxSpeed;
  end

  # retrieves the minimum speed of this vehicle.
  def getMinSpeed()
    return @minSpeed
  end

  # sets the minimum speed of this vehicle.
  def setMinSpeed(minSpeed)
    @minSpeed = minSpeed
  end
    
  # brake adjusts the velocity of the vehicle based on the braking speed. If the
  # velocity reaches 0, braking will put the vehicle in reverse up to the minimum 
  # speed.
  def brake(time)
    @velocity -= time * @braking
    if(@velocity < -@minSpeed)
      @velocity = -@minSpeed
    end
  end
    
  # accelerate adjusts the velocity of the vehicle based on the acceleration. The velocity
  # will continue to raise until maxSpeed is reached, at which point it will stop.
  def accelerate(time)
    @velocity += time * @acceleration
    if(@velocity > @maxSpeed)
      @velocity = @maxSpeed
    end
  end
    
  # drift calculates what happens when the vehicle is neither braking or accelerating. 
  # The vehicle will slow down based on its weight.
  def drift(time)
    if(@velocity < -FastMath::FLT_EPSILON)
      @velocity += ((@weight/5) * time);
      # we are drifting to a stop, so we shouldn't go
      # above 0
      if(@velocity > 0)
        @velocity = 0
      end
    elsif(@velocity > FastMath::FLT_EPSILON)
      @velocity -= ((@weight/5) * time)
      # we are drifting to a stop, so we shouldn't go
      # below 0
      if(@velocity < 0)
          @velocity = 0
      end
    end
  end

  def setRotateOn(modifier)
    @lean = modifier;
  end
end
