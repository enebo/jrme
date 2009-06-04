# This module assumes we are being included into a node which contains both
# a local_translation and a local_rotation method.
module SimplePhysics
  attr_accessor :velocity, :turn_speed, :min_speed, :max_speed
  attr_accessor :braking, :acceleration, :weight

  def initialize_physics(max_speed, min_speed, weight, acceleration, braking, turn_speed)
    @min_speed, @max_speed, @weight = min_speed, max_speed, weight
    @acceleration, @braking, @turn_speed = acceleration, braking, turn_speed
    @velocity = 0
    @temp_va = Vector3f.new
  end

  # Are we velocity zero (well approximately)
  def moving?
    @velocity > FastMath::FLT_EPSILON || @velocity < -FastMath::FLT_EPSILON
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

  def update_position(time)
    localTranslation.addLocal(localRotation.get_rotation_column(2, @temp_va).multLocal(@velocity * time))
  end
end
