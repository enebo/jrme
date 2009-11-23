$textures = {} unless $textures

module JRME
  module Textures
    class TextureBinder < Struct.new(:texture_state)
      def setup(object)
        object.render_state texture_state
      end
    end

    def texture(url, scale=nil, repeat=Texture::WrapMode::Repeat)
      key = "#{url}:#{scale}:#{repeat}"  # TODO: scale+repeat values norm.
      $textures[key] = texture_binder_for(url, scale, repeat) unless $textures[key]
      $textures[key].setup(self)
    end

    def texture_binder_for(url, scale, repeat)
      texture_state = DisplaySystem.display_system.renderer.createTextureState
      texture = TextureManager.load(resource(url))
      texture.wrap = repeat
      texture.scale = scale if scale
      texture_state.texture = texture
      TextureBinder.new texture_state
    end
  end
end
