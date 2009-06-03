java_import com.jme.input.InputHandler
java_import com.jme.input.KeyBindingManager
java_import com.jme.input.KeyInput

class FlagRushHandler < InputHandler
  def update(time)
    return if ( !isEnabled() ) 

    super(time)
    # we always want to allow friction to control the drift
    @drift.performAction(event)
    @vehicle.update(time)
  end
    
  def initialize(vehicle, api)
    super()
    @vehicle = vehicle
    setKeyBindings(api)
    setActions(vehicle)
  end

  def setKeyBindings(api)
    keyboard = KeyBindingManager.getKeyBindingManager()

    keyboard.set("forward", KeyInput::KEY_W)
    keyboard.set("backward", KeyInput::KEY_S)
    keyboard.set("turnRight", KeyInput::KEY_D)
    keyboard.set("turnLeft", KeyInput::KEY_A)
  end

  def setActions(node)
    forward = ForwardAndBackwardAction.new(node, ForwardAndBackwardAction::FORWARD)
    addAction(forward, "forward", true)
    backward = ForwardAndBackwardAction.new(node, ForwardAndBackwardAction::BACKWARD)
    addAction(backward, "backward", true)
    rotateLeft = VehicleRotateAction.new(node, VehicleRotateAction::LEFT)
    addAction(rotateLeft, "turnLeft", true)
    rotateRight = VehicleRotateAction.new(node, VehicleRotateAction::RIGHT)
    addAction(rotateRight, "turnRight", true);
        
    #not triggered by keyboard
    @drift = DriftAction.new(node)
  end
end
