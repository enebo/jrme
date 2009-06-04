# Will lean any model based on this ugly lean logic....
module Leans
  LEAN_BUFFER = 0.05

  def initialize_lean
    @lean_axis, @lean, @lean_angle = Vector3f.new(0,0,1), 0, 0
    @q = Quaternion.new()
  end

  attr_writer :lean

  # Vehicle is worried about position about the terrain.
  def update_lean(time, model)
    # check if we are leaning at all
    if @lean != 0
      if @lean == -1 && @lean_angle < 0
        @lean_angle += -@lean * 4 * time
      elsif @lean == 1 && @lean_angle > 0
        @lean_angle += -@lean * 4 * time
      else
        @lean_angle += -@lean * 2 * time
      end
      # max lean is 1 and -1
      if @lean_angle > 1
        @lean_angle = 1
      elsif @lean_angle < -1
        @lean_angle = -1
      end
    else # we are not leaning, so right ourself back up.
      if @lean_angle < LEAN_BUFFER && @lean_angle > -LEAN_BUFFER
        @lean_angle = 0
      elsif @lean_angle < -FastMath::FLT_EPSILON
        @lean_angle += time * 4
      elsif @lean_angle > FastMath::FLT_EPSILON
        @lean_angle -= time * 4
      else
        @lean_angle = 0
      end
    end
       
    @q.from_angle_axis @lean_angle, @lean_axis
    model.local_rotation = @q
    @lean = 0
  end
end
