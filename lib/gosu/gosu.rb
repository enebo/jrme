module Gosu
  # Returns the horizontal distance between the origin and the point to which 
  # you would get if you moved radius pixels in the direction specified by 
  # angle.
  def offset_x(angle, dist)
    dist * Math::sin(degrees_to_radians(angle))
  end
  module_function :offset_x

  # Returns the vertical distance between the origin and the point to which
  # you would get if you moved radius pixels in the direction specified by 
  # angle.
  def offset_y(angle, dist)
    dist * Math::cos(degrees_to_radians(angle))
  end
  module_function :offset_y

  def degrees_to_radians(angle)
    (angle / 180.0) * Math::PI
  end
  module_function :degrees_to_radians

  # Returns the angle between two points in degrees, where 0.0 means upwards.
  # Returns 0 if both points are equal. 
  def angle(x1, y1, x2, y2)
  end

  # Returns the smallest angle that can be added to angle1 to get to angle2 
  # (can be negative if counter-clockwise movement is shorter). 
  def angle_diff(angle1, angle2)
  end

  # Returns the distance between two points. 
  def distance(x1, y1, x2, y2)
    Math.sqrt((y2 - y1)**2 + (x2 - x1)**2)
  end

  # Incrementing, possibly wrapping millisecond timer. 
  def milliseconds()
    java.lang.System.currentTimeMillis
  end

  # Returns a font name that will work on any system. 
  def default_font_name()
  end

  # Return the dimensions of the system's primary screen. Can be used to 
  # choose the size of your windowed resolution. 
  def screen_width()
  end

  def screen_height()
  end
end
