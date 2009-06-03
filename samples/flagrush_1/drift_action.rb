class DriftAction < KeyInputAction
  def initialize(vehicle)
    super()
    @vehicle = vehicle
  end

  def performAction(evt)
    @vehicle.drift(evt.getTime())
  end
end
