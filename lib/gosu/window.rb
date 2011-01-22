require 'jmephysics'

module Gosu
  class MyHandler
    include com.jme.input.action.InputActionInterface
    
    def initialize(gosu_window)
      @gosu_window = gosu_window
    end

    def performAction(event)
      id = Gosu::Button::MAPPINGS[event.trigger_index]

      if event.trigger_pressed?
        @gosu_window.button_down(id)
      else
        @gosu_window.button_up(id)
      end
    end
  end

  class KeyWatcher < com.jme.input.keyboard.KeyboardInputHandlerDevice
    def initialize(jrme_game)
      super()
      @jrme_game = jrme_game
      @callback = MyHandler.new(jrme_game.gosu_window)
      @keys = []
    end

    def add(keycode)
      @keys << keycode
    end

    def commit(input_handler)
      @keys.each do |keycode|
        createTriggers @callback, -1, keycode, false, input_handler
      end
    end
  end

  class JRMEGame < SimplePhysicsGame
    ORIGIN = Vector3f.new 0, 0, 0
    FAR_PLANE = 20000.0

    attr_accessor :title, :gosu_window

    def initialize(gosu_window, width, height, fullscreen, update_interval)
      super()
      @gosu_window = gosu_window 
      @width, @height, @fullscreen = width, height, fullscreen
      @update_interval = update_interval * 1_000_000 # nanos
      @last_nanos = System.nano_time
      @watcher = KeyWatcher.new(self)
    end

    def camera
      cam.set_frustum_far(FAR_PLANE)
#      cam.set_frustum_perspective(90.0, display.width.to_f / display.height, 8.0, FAR_PLANE)
      cam.location = Vector3f.new(0, 0, 1400)
      cam.lookAt ORIGIN, Vector3f::UNIT_Y
      cam.update

      root_node.setRenderState(display.renderer.createCullState.set!(:cull_face => CullState::Face::Back))
    end

    def add_key(keycode)
      @watcher.add keycode
    end
    
    def getNewSettings
      super().tap do |settings|
        settings.width = @width
        settings.height = @height
        settings.fullscreen = @fullscreen
      end
    end

    def simpleInitGame
      KeyBindingManager.key_binding_manager.remove ["turnLeft", "strafeLeft", "turnRight", "forward", "strafeRight", "backward", "lookDown", "elevateUp", "lookUp", "elevateDown"]
      @watcher.commit(input)
      display.title = @title if @title
      camera
    end

    def simpleUpdate
      if time_to_update?
        @gosu_window.update
        @gosu_window.draw if @gosu_window.needs_redraw?
      end
    end

    def time_to_update?
      nanos = System.nano_time
      return false if nanos - @last_nanos <= @update_interval
      @last_nanos = nanos
    end
  end

  class Window
    attr_reader :update_interval

    def initialize(width, height, fullscreen, update_interval = 16.666666)
      @jrme_game = JRMEGame.new self, width, height, fullscreen, update_interval
      @update_interval = update_interval
      define_keybindings
    end

    def caption
      @jrme_game.title
    end

    def caption=(caption)
      @jrme_game.title = caption
    end

    def show
      @jrme_game.start
    end

    def close
      @jrme_game.quit
    end

    # Called by @jrme_game.simpleUpdate
    def update
    end

    # Called by @jrme_game.simpleUpdate after update
    def draw
    end

    def needs_redraw?
      true
    end

    # Called when the user presses the button with the given id.
    def button_down(id)
    end

    # Called when the user releases the button with the given id.
    def button_up(id)
    end

    def draw_line(x1, y1, c1, x2, y2, c2, z=0, mode=:default)
    end

    def draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z=0, mode=:default)
    end

    def draw_quad(x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4, z=0, mode=:default)
    end

    def mouse_x
    end

    def mouse_y
    end

    def mouse_x=(float)
    end

    def mouse_y=(float)
    end

    # To avoid intermediate position of calling mouse_x= followed by mouse_y=.
    def set_mouse_position(x, y)
    end

    def button_down?(id)
      @keys.valid? Gosu::Button::MAPPINGS[id]
    end

    # Returns the character a given id stands for, or nil.
    def self.button_id_to_char(id)
    end

    # Returns the id usually used for a character, or nil.
    def self.char_to_button_id(char)
    end

    def text_input
    end

    # Sets current text input object that builds an input string
    def text_input=
    end

    def width
      @jrme_game.settings.width
    end

    def height
      @jrme_game.settings.height
    end

    def gl(&block)
    end

    def clip_to(x, y, w, h, &block)
    end

    # Not part of Gosu API, but useful for implementation of Gosu
    def scene_graph
      @jrme_game.root_node
    end

    def update_scene_graph
      scene_graph.update_render_state
    end

    def define_keybindings
      @keys = KeyBindingManager.key_binding_manager
      Gosu::Button::MAPPINGS.each do |value, name|
        @keys.set(name, value)
        @jrme_game.add_key value
      end
    end
  end
end

