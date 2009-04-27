require 'jme'

# ambient color
# diffuse color
# emissive color
# specular color
# shininess float (0-128)
# void 	setColorMaterial(MaterialState.ColorMaterial material)
# void 	setMaterialFace(MaterialState.MaterialFace face)

class Main < SimpleGame
  INCREMENT = 0.001

  def simpleInitGame
    @keys = KeyBindingManager.define "AMBIENT" => :A,
       "DIFFUSE" => :D, "EMISSIVE" => :E, "SPECULAR" => :S, 
       "SHINY+" => :N, "SHINY-" => :M, 
       "RED+" => :R, "RED-" => :T,
       "GREEN+" => :F, "GREEN-" => :G,
       "BLUE+" => :V, "BLUE-" => :B

    @ambient = IncrementingColor.new 0.5, 0.5, 0.5

    @sphere = Sphere.new "ColorSphere", 32, 5
    @material_state = @sphere.color(self, :ambient => @ambient)
    @sphere.local_translation.set(0, 0, 0)

    root_node << @sphere
  end

  def simpleUpdate
    color = @ambient

    color.increment_red(INCREMENT) if @keys.valid? "RED+"
    color.increment_red(-INCREMENT) if @keys.valid? "RED-"
    color.increment_green(INCREMENT) if @keys.valid? "GREEN+"
    color.increment_green(-INCREMENT) if @keys.valid? "GREEN-"
    color.increment_blue(INCREMENT) if @keys.valid? "BLUE+"
    color.increment_blue(-INCREMENT) if @keys.valid? "BLUE-"

#    @material_state.set!(:ambient => color)
#    @sphere.updateRenderState
    @sphere.color self, :ambient => color
  end
end

class IncrementingColor < ColorRGBA
  def initialize(red, green, blue, alpha = 1)
    super(red, green, blue, alpha)
  end

  def increment_red(amount = 0.1)
    set(r + amount, g, b, a)
  end

  def increment_green(amount = 0.1)
    set(r, g + amount, b, a)
  end

  def increment_blue(amount = 0.1)
    set(r, g, b + amount, a)
  end

  def increment_alpha(amount = 0.1)
    set(r, g, b, a  + amount)
  end
end

Main.new.start
