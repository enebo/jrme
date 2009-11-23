# Issues:
# 1. Multiple textures created, but they are the same....Does JME notice?
# 2. cannot blinkdly remove all elements in the scene since it may remove
#    more than we  want
# 3. We do not keep track of physics nodes but our Ruby objects...we hsould
#     Can I detach physics node and have it disappear from scene graph
# 4. Should I also add obstacles to floor?
require 'jmephysics'
require 'types'
require 'level'

class Madness < SimplePhysicsGame
  LEVEL_SIZE, START, CUBE_SIZE = 400.m, [370.m, 100.m, 370.m], 4.m
  CAMERA_START, LOSE_MESSAGE = [400.m, 100.m, 400.m], "You Lose!"

  attr_accessor :icecube, :chaser, :collision_action

  def simpleInitGame
    # Call execute on whatever object isn't the icecube
    @collision_action = InputAction.create do |event|
      contact = event.trigger_data
      (@icecube == contact.node1 ? contact.node2 : contact.node1).execute
    end
    @velocity_holder, @level = Vector3f.new, Level.new(self, 1)
    create_keybindings
    create_status

    @time = 0.0
    physics_space.add_to_update_callbacks do |space, time|
      @time += time
      return unless @time > 0.5
      return finish(LOSE_MESSAGE) if @icecube.scale.x < 1.mm
      @icecube.scale @icecube.scale.x - 1.cm
      @time = 0.0
    end
  end

  def simpleUpdate
    @chaser.update tpf # update chase camera for moving icecube
    @info_text.value = "Velocity: #{@icecube.get_linear_velocity(@velocity_holder)}"
    finish LOSE_MESSAGE if @icecube.local_translation.y < -20
  end

  def reset
    cam.location = Vector3f *@level.camera_location
    @icecube.at *@level.player_location
    @icecube.set_linear_velocity(Vector3f(0,0,0))
    @icecube.set_angular_velocity(Vector3f(0,0,0))
    @icecube.scale CUBE_SIZE
    self.pause = false
    flash ""
  end

  def flash(message)
    @flash_text.value = message
  end

  def finish(message)
    flash message
    self.pause = true
  end

  def create_keybindings
    KeyBindingManager.key_binding_manager.remove ["toggle_lights", "mem_report"]
    mag = 700
    n, s, w, e = -XAXIS * mag, XAXIS * mag, -ZAXIS * mag, ZAXIS * mag

    key(KeyInput::KEY_J, proc { |v| @icecube.add_force n if v.trigger_pressed })
    key(KeyInput::KEY_K, proc { |v| @icecube.add_force s if v.trigger_pressed })
    key(KeyInput::KEY_H, proc { |v| @icecube.add_force w if v.trigger_pressed })
    key(KeyInput::KEY_L, proc { |v| @icecube.add_force e if v.trigger_pressed })
    key(KeyInput::KEY_R, proc { |event| reset })
  end

  def create_status
    stat_node << @flash_text=Text.create_default_text_label("flash", LOSE_MESSAGE)
    local_scale = 5
    @flash_text.center_on(settings.width/2, settings.height/2)
    @flash_text.text_color = ColorRGBA.white
    flash ""
    stat_node << @info_text =Text.create_default_text_label("info", "Velocity:")
    @info_text.local_translation.set 0, 10, 0
  end

  def key(key, action)
    input.add_action action, InputHandler::DEVICE_KEYBOARD, key, InputHandler::AXIS_NONE, false
  end
end

Madness.new.start
