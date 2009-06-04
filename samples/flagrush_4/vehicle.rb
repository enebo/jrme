require 'simple_physics'
require 'lean'
require 'wheel_rotator'

# Vehicle will be a node that handles the movement of a vehicle in the
# game. It has parameters that define its acceleration and speed as well
# as braking. The turn speed defines what kind of handling it has, and the
# weight will define things such as friction for drifting, how fast it falls
# etc. (originally from Mark Powell)
class Vehicle < Node
  include SimplePhysics, Leans

  attr_reader :model
    
  def initialize(id, model, max_speed, min_speed, weight, acceleration, braking, turn_speed)
    super(id)
    initialize_physics(max_speed, min_speed, weight, acceleration, braking, turn_speed)
    initialize_lean
    initialize_model model
    setup_wheels    
  end
    
  def update(time)
    update_position time
    @frontwheel.update time, self
    @backwheel.update time, self
    update_lean time, model
  end

  def initialize_model(model)
    detachChild @model
    @model = model
    attachChild @model
  end

  def setup_wheels
    # Need front and back wheel references so we can rotate them
    @backwheel = @model.get_child "backwheel"
    @frontwheel = @model.get_child "frontwheel"

    class << @backwheel
      include WheelRotator
    end
    class << @frontwheel
      include WheelRotator
    end

    @backwheel.initialize_wheel
    @frontwheel.initialize_wheel
  end
end
