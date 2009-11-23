$materials = {} unless $materials

module JRME
  module Colors
    # Setting up a particular color may require multiple calls on the
    # object that you want to setup.  This holds all the color states
    # and knows how to setup these states on an object
    class ColorBinder
      def initialize(material_state, blend_state=nil)
        @material_state, @blend_state = material_state, blend_state
      end

      def setup(object)
        if @blend_state
          object.set_render_state @blend_state
          object.set_render_queue_mode Renderer::QUEUE_TRANSPARENT
        end

        object.render_state @material_state
      end
    end

    # Make a new diffuse color if one has not already been created.
    # [Note: Not sure if sharing colors is good idea or not?]
    # FIXME: Not thread-safe?  Does it matter?
    def diffuse(color)
      key = color.asIntARGB
      $materials[key] = color_binder_for(:diffuse, color) unless $materials[key]
      $materials[key].setup(self)
    end

    def color_binder_for(color_type, color)
      renderer = DisplaySystem.display_system.renderer
      material_state = renderer.createMaterialState.set! color_type => color

      # Some alpha value.  We need to do more to make it look ok.
      if color.a < 1
        blend_state = renderer.createBlendState.set! :enabled => true,
        :blend_enabled => true, 
        :source_function => BlendState::SourceFunction::SourceAlpha,
        :destination_function => BlendState::DestinationFunction::OneMinusSourceAlpha
      else
        blend_state = nil
      end

      ColorBinder.new material_state, blend_state
    end
  end
end
