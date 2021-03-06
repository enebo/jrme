require 'jme'

import com.jmex.physics.DynamicPhysicsNode
import com.jmex.physics.PhysicsNode
import com.jmex.physics.PhysicsSpace
import com.jmex.physics.StaticPhysicsNode
import com.jmex.physics.contact.MutableContactInfo
import com.jmex.physics.material.Material
import com.jmex.physics.util.SimplePhysicsGame

class SimplePhysicsGame
  field_accessor :cameraInputHandler => :camera_input_handler, 
    :showPhysics => :show_physics
end

require 'jmephysics/physics.rb'
require 'jmephysics/material.rb'
