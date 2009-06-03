java_import com.jme.input.action.InputActionEvent
java_import com.jme.input.action.KeyInputAction

# AccelerateAction defines the action that occurs when the key is pressed to 
# speed the Vehicle up. It obtains the velocity of the vehicle and 
# translates the vehicle by this value.
class ForwardAndBackwardAction < KeyInputAction
  FORWARD = 0
  BACKWARD = 1

  # The vehicle to accelerate is supplied during construction.
  # @param node the vehicle to speed up.
  def initialize(node, direction)
    super()
    @node = node
    @direction = direction
  end

  # the action calls the vehicle's accelerate or brake command which adjusts its velocity.
  def performAction(evt)
    if(@direction == FORWARD)
      @node.accelerate(evt.getTime())
    elsif(@direction == BACKWARD)
      @node.brake(evt.getTime())
    end
  end
end
