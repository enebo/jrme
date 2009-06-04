class FlagRushHandler < InputHandler
  def update(time)
    return unless enabled?

    super(time)
    # we always want to allow friction to control the drift
    @drift.performAction event
    @vehicle.update time
  end
    
  def initialize(vehicle, api)
    super()
    @vehicle = vehicle
    set_key_bindings api
    setActions vehicle
  end

  def set_key_bindings(api)
    keyboard = KeyBindingManager.key_binding_manager

    keyboard.set("forward", KeyInput::KEY_W)
    keyboard.set("backward", KeyInput::KEY_S)
    keyboard.set("turnRight", KeyInput::KEY_D)
    keyboard.set("turnLeft", KeyInput::KEY_A)
  end

  def setActions(node)
    forward = ForwardAndBackwardAction.new(node, ForwardAndBackwardAction::FORWARD)
    add_action forward, "forward", true
    backward = ForwardAndBackwardAction.new(node, ForwardAndBackwardAction::BACKWARD)
    add_action backward, "backward", true
    rotate_left = VehicleRotateAction.new(node, VehicleRotateAction::LEFT)
    add_action rotate_left, "turnLeft", true
    rotate_right = VehicleRotateAction.new(node, VehicleRotateAction::RIGHT)
    add_action rotate_right, "turnRight", true
        
    #not triggered by keyboard
    @drift = DriftAction.new(node)
  end
end
