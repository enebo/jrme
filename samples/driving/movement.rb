module Movement
  field :weight => 10.0, :acceleration => 9.68, :braking => 4.34, 
    :velocity => 10.0, :turn_speed => 5.0, 
    :max_speed => 30.0, :min_speed => 10.0

  # Process attributes which contain any information about movement
  #
  # max_speed:: the maximum speed it vehicle can reach. (Unit/s)
  # min_speed:: the minimum speed it can reach while moving in reverse. (Unit/s)
  # weight:: the weight of the vehicle.
  # acceleration:: how fast it can reach max speed
  # braking:: how fast it can slow down and if held long enough reverse
  # turn_speed:: how quickly this vehicle can rotate.
  def process_movement_attributes(attributes)
    # Should probably allow default values and probably encapsulate the logic
    @max_speed = attributes[:max_speed]
    @min_speed = attributes[:min_speed]
    @weight = attributes[:weight]
    @acceleration = attributes[:acceleration]
    @velocity = 10.0
    @braking = attributes[:braking]
    @turn_speed = attributes[:turn_speed]
  end

  # brake adjusts the velocity of the vehicle based on the braking speed. If 
  # the velocity reaches 0, braking will put the vehicle in reverse up to the 
  # minimum speed.
  # @param time the time between frames.
  def brake(time)
    @velocity -= time * @braking
    @velocity = -@min_speed if @velocity < -@min_speed
  end
    
  # accelerate adjusts the velocity of the vehicle based on the acceleration. 
  # The velocity will continue to raise until maxSpeed is reached, at which 
  # point it will stop.
  # @param time the time between frames.
  def accelerate(time) 
    @velocity += time * @acceleration;
    @velocity = @max_speed if @velocity > @max_speed
  end
    
  # drift calculates what happens when the vehicle is neither braking or 
  # accelerating.  The vehicle will slow down based on its weight.
  # @param time the time between frames.
  def drift(time)
    if @velocity < 0
      @velocity += ((@weight/5) * time)
    else
      @velocity -= ((@weight/5) * time)
    end
  end
end
