
class AbsoluteMouse
  def initialize(display, title, cursor_texture=nil, limit_width=display.width, limit_height=display.height)
    super(title, limit_width, limit_height)

    if cursor_texture
      texture_state = display.renderer.createTextureState
      resource = resource(cursor_texture)
      texture = TextureManager.load(resource, :NearestNeighborNoMipMaps)
      texture_state.setTexture(texture)
      setRenderState(texture_state)

      blend_state = display.renderer.createBlendState
      blend_state.set!(:blend_enabled => true, 
        :source_function => BlendState::SourceFunction::SourceAlpha,
        :destination_function => BlendState::DestinationFunction::OneMinusSourceAlpha,
        :test_enabled => true,
        :test_function => BlendState::TestFunction::GreaterThan)
      setRenderState(blend_state)
    end

    # Enebo: reusing this is bad if someone has not finished consuming last
    @display, @picks = display, BoundingPickResults.new
    @picks.setCheckDistance(true)
  end

  def picks
    screen_pos = Vector2f.new
    # Get the position that the mouse is pointing to
    screen_pos.set hot_spot_position.x, hot_spot_position.y
    # Get the world location of that X,Y value
    world_coords = @display.getWorldCoordinates screen_pos, 0
    world_coords2 = @display.getWorldCoordinates screen_pos, 1

    # Make ray from camera to mouse point
    ray = Ray.new(world_coords, world_coords2.subtractLocal(world_coords).normalizeLocal)

    @picks.clear
    # Assume mouse is attached to root
    parent.findPick(ray, @picks)
    @picks
  end

  def center
    setLocalTranslation(Vector3f.new(@display.width/2, @display.height/2, 0))
  end
end

class InputHandler
  field_accessor :event, :mouse
end

class KeyBindingManager
  def self.define(bindings)
    manager = KeyBindingManager.key_binding_manager
    bindings.keys.each do |key| 
      value = eval "KeyInput::KEY_" + bindings[key].to_s
      manager.set(key, value)
    end
    manager
  end

  alias orig_remove remove
  def remove(arg)
    if arg.kind_of? Array
      arg.each { |name| orig_remove(name) }
    else 
      orig_remove(arg)
    end
  end

  def valid?(name)
    isValidCommand(name, true)
  end
end

class InputAction
  # Make an action which will invoke the supplied block every time there
  # is an action event:
  #   forward = InputAction.create { |event| node.accelerate event.time }
  def self.create(&block)
    BlockBasedInputAction.new(&block)
  end
end

class BlockBasedInputAction < InputAction
  def initialize(&block)
    super()
    @block = block
  end
    
  def performAction(event)
    @block.call event
  end
end

class ChaseCamera
  def self.create(camera, target, &code)
    camera = ChaseCamera.new camera, target
    code.arity == 1 ? code[self] : camera.instance_eval(&code) if block_given?
    camera
  end
end
