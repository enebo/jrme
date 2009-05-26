require 'jme'

module RandomHelper
  def random_percent
    rand(100).to_f / 100
  end

  def random_color
    color = display.getRenderer.createMaterialState
    color.ambient = ColorRGBA.new(random_percent, random_percent, random_percent, random_percent)
    color
  end
end

class Pivot
  include RandomHelper

  def initialize(object)
    @node = Node.new "PivotNode"
    @node << object
    @quaternian = Quaternion.new
    @angle = rand(360.0)
    @axis = Vector3f.new(random_percent, random_percent, random_percent)
    @child = object
  end

  def attach_to(node)
    node.attach_child @node
    self
  end

  def update(time_per_frame)
    if time_per_frame < 1
      @angle = @angle + time_per_frame
      @angle = 0 if @angle > 360
    end

    @node.local_rotation = @quaternian.from_angle_axis(@angle, @axis)
  end
end

class TestSimpleGame < SimpleGame
  include RandomHelper

  def initialize
    super()
    @pivots, @count = [], 0
  end

  def simpleInitGame
    1.upto(MOONS) { |i| define_moon }
    cam.location = Vector3f.new(0, 0, 388)
    stat_node << @fps = Text.create_default_text_label("FPS", "FPS: 00.0")
  end

  def define_moon(distance=50+rand(100), radius=rand(10))
    moon = Sphere.new("Moon", 5+rand(20), 5+rand(20), radius)
    moon.setRenderState(random_color)
    moon.updateRenderState
    moon.setLocalTranslation(distance, 0, 0)

    @pivots << Pivot.new(moon).attach_to(root_node)
  end

  def simpleUpdate
    time_per_frame = tpf
    @pivots.each { |pivot| pivot.update(time_per_frame) }
    @count += 1
    @fps.text.replace(5, 9, format("%2.1f", timer.frame_rate)) if @count % 10 == 0
  end
end

MOONS = ARGV.shift.to_i || 50
TestSimpleGame.new.start
