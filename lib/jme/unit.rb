class Numeric
  MM_SIZE = 0.00025

  [:mm, :cm, :dm, :m, :dam, :hm, :km, :Mm].inject(MM_SIZE) do |memo, unit|
    size = memo
    define_method(unit) { self * size }
    memo *= 10
  end

  def deg_in_rad
    self * FastMath::DEG_TO_RAD
  end

  def rad_in_deg
    self * FastMath::RAD_TO_DEG
  end
end
