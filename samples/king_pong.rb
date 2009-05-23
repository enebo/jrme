require 'jme'
require 'domain'

class Main < SimplePassGame
  attr_reader :sky, :arena
  ORIGIN = Vector3f.new 0, 0, 0
  FAR_PLANE = 20000.0

  def simpleInitGame
    display.title = "King Pong"
    [lights, camera, action]

    @sky = Sky.new
    terrain = Terrain.new
    @goal_walls = GoalWalls.new
    @side_walls = SideWalls.new
    @ball = Ball.new terrain
    @paddle1 = Paddle.new "Player1", -Arena::SIZE
    @paddle2 = Paddle.new "Player2", Arena::SIZE
    @arena = Arena.new @side_walls, @goal_walls, @ball
    root_node << @sky << @arena << terrain << @paddle1 << @paddle2
    root_node.updateGeometricState(0.0, true)
    root_node.updateRenderState
    root_node.cull_hint = Spatial::CullHint::Never
    
    @water = Water.new(self)    
    pass_manager << @water << root_node
  end

  def simpleUpdate
    # Update environmental
    @sky.update(cam)
    @water.update(cam, FAR_PLANE)

    # Handle UI
    @paddle1.move_up(tpf) if @keys.valid? "1UP"
    @paddle1.move_down(tpf) if @keys.valid? "1DOWN"
    @paddle2.move_up(tpf) if @keys.valid? "2UP"
    @paddle2.move_down(tpf) if @keys.valid? "2DOWN"
    @ball.reset if @keys.valid? "RESET"

    # Collisions
    @ball.bounce if @paddle1.collides_with?(@ball) || @paddle2.collides_with?(@ball)
    @ball.reflected_bounce if @ball.collides_with? @side_walls
    @ball.reset if @ball.collides_with? @goal_walls
    @ball.move tpf
  end

  def lights
    light_state.detachAll
    light_state.attach DirectionalLight.new.set!(:enabled => true,
      :diffuse => ColorRGBA.new(1, 1, 1, 1), :ambient => ColorRGBA.new(0.5, 0.5, 0.7, 1),
      :direction => Vector3f.new(-0.8, -1.0, -0.8))
  end

  def camera
    cam.set_frustum_perspective(45.0, display.width.to_f / display.height, 8.0, FAR_PLANE)
    cam.location = Vector3f.new(-300, 600, 800)
    cam.lookAt ORIGIN, Vector3f::UNIT_Y
    cam.update

    root_node.setRenderState(display.renderer.createCullState.set!(:cull_face => CullState::Face::Back))
  end

  def action
    @keys = KeyBindingManager.define("RESET" => :G, "1UP" => 1, "1DOWN" => 2, "2UP" => 9, "2DOWN" => 0)
  end
end

Main.new.start
