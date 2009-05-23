class AccelerateAction < InputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
    @tempVa = Vector3f.new
  end

  def performAction(evt)
    @vehicle.accelerate evt.time
    loc = @vehicle.local_translation
    loc.addLocal(@vehicle.local_rotation.getRotationColumn(2, @tempVa).multLocal(@vehicle.velocity * evt.time))
    @vehicle.setLocalTranslation(loc)
  end
end

class BrakeAction < InputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
    @tempVa = Vector3f.new;
  end

  def performAction(evt)
    @vehicle.brake evt.time
    loc = @vehicle.local_translation
    loc.addLocal(@vehicle.local_rotation.getRotationColumn(2, @tempVa).multLocal(@vehicle.velocity * evt.time))
    @vehicle.local_translation = loc
  end
end

class VehicleTurnLeftAction < InputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
    @tempMa = Matrix3f.new
    @tempMb = Matrix3f.new
    @incr = Matrix3f.new
    @upAxis = Vector3f.new 0, 1, 0
  end

  def performAction(evt)
    # We want to turn differently depending on which direction we are traveling in.
    if (@vehicle.velocity < 0)
      @incr.fromAngleNormalAxis(-@vehicle.turn_speed * evt.time, @upAxis)
    else
      @incr.fromAngleNormalAxis(@vehicle.turn_speed * evt.time, @upAxis)
    end
    @vehicle.local_rotation.fromRotationMatrix(@incr.mult(@vehicle.local_rotation.toRotationMatrix(@tempMa), @tempMb))
    @vehicle.local_rotation.normalize
  end
end

class VehicleTurnRightAction < InputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
    @tempMa = Matrix3f.new
    @tempMb = Matrix3f.new
    @incr = Matrix3f.new
    @upAxis = Vector3f.new 0, 1, 0
  end

  def performAction(evt)
    # We want to turn differently depending on which direction we are traveling in.
    if (@vehicle.velocity < 0)
      @incr.fromAngleNormalAxis(@vehicle.turn_speed * evt.time, @upAxis)
    else
      @incr.fromAngleNormalAxis(-@vehicle.turn_speed * evt.time, @upAxis)
    end
    @vehicle.local_rotation.fromRotationMatrix(@incr.mult(@vehicle.local_rotation.toRotationMatrix(@tempMa), @tempMb))
    @vehicle.local_rotation.normalize
  end
end

class DriftAction < InputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
    @tempVa = Vector3f.new
  end

  def performAction(evt)
    @vehicle.drift evt.time
    loc = @vehicle.local_translation
    loc.addLocal(@vehicle.local_rotation.getRotationColumn(2, @tempVa).multLocal(@vehicle.velocity * evt.time))
    @vehicle.setLocalTranslation(loc)
  end
end

class FlagRushHandler < InputHandler
  def initialize(vehicle, api)
    super()
    set_key_bindings(api)
    set_actions(vehicle)
  end

  def update(time)
    super
    # we always want to allow friction to control the drift
    @drift.performAction event
  end

  def set_key_bindings(api)
    keyboard = KeyBindingManager.define "forward" => :W, "backward" => :S,
      "turnRight" => :D, "turnLeft" => :A
   end
 
  def set_actions(vehicle)
    add_action AccelerateAction.new(vehicle), "forward", true
    add_action BrakeAction.new(vehicle), "backward", true
    add_action VehicleTurnRightAction.new(vehicle), "turnRight", true
    add_action VehicleTurnLeftAction.new(vehicle), "turnLeft", true
    
    @drift = DriftAction.new(vehicle)
  end
end
