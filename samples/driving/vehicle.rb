class Vehicle < Node
  include Movement
    
  # @param id the id of the vehicle
  # @param model the model representing the graphical aspects.
  # @param attributes movement attributes....see Movement.populate_movement_attribtues
  def initialize(id, amodel, attributes={}) 
    super id
    self.model = amodel
    process_movement_attributes(attributes)
  end

  attr_reader :model
 
  def model=(model)
    detach_child @model
    @model = model
    attach_child @model
  end
end
