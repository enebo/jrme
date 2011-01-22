# -*- coding: utf-8 -*-
require 'jmephysics'

module Gosu
  class Image
    def box_for_image(filename)
      puts "WIDTHxHEIGHT #{width}x#{height}"
      Box(filename, width, height, 1).tap do |box|
        texture_state = DisplaySystem.display_system.renderer.createTextureState
        texture = TextureManager.load_from_image(@image)
#        texture.wrap = true if @tileable
        texture_state.texture = texture
        box.render_state texture_state
      end
    end

    # [srcX, srcY, srcWidth, srcHeight]
    def initialize(window, filename, tileable, *src)
      @window, @filename, @tileable = window, filename, tileable
      @image = ImageIcon.new(filename).image

      # Variables for rotating the image
      @rotation_vector = Vector3f.new
      @quaternion = Quaternion.new
      @rotation_vector.set Vector3f::UNIT_Z
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def draw(x, y, z, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
      setup_holder
      @holder.local_translation.x = x
      @holder.local_translation.y = y
      @holder.local_translation.z = z

      @window.update_scene_graph
    end

    # center_x Relative horizontal position of the rotation center on the 
    # image. 0 is the left border, 1 is the right border, 0.5 is the center 
    # (and default)—the same applies to center_y, respectively.
    def draw_rot(x, y, z, angle, center_x=0.5, center_y=0.5, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
      setup_holder
      @holder.local_translation.x = x
      @holder.local_translation.y = y
      @holder.local_translation.z = z

      @quaternion.fromAngleAxis Gosu.degrees_to_radians(angle), @rotation_vector
      @holder.local_rotation.set @quaternion

      @window.update_scene_graph
    end

    # Like Window#draw_quad, but with this texture instead of a solid color.
    # Can be used to implement advanced, non-rectangular drawing techniques.
    def draw_as_quad(x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4, z, mode=:default)
    end

    # Creates a line of text. font_name can either be the name of a system font, or a filename (must contain '/').
    def self.from_text(window, text, font_name, font_height, *rest)
    end

    # Creates a block of text of width max_width. Each line will take 
    # font_height + line_spacing pixels of vertical space.`: align must be
    # one of :left, :right, :center oder :justify. : font_name can either be
    # the name of a system font, or a filename (must contain '/', does not 
    # work on Linux yet).
    def self.from_text(window, text, font_name, font_height, line_spacing, max_width, align)
    end

    # tile_width can either be the width of one tile in pixels or the number
    # of columns multiplied by -1. tile_height is its vertical equivalent
    def self.load_tiles(window, filename_or_rmagick_image, tile_width, tile_height, tileable)
    end

    def gl_tex_info
    end

    def setup_holder
      unless @holder # Setup late to know game has bootstrapped
        @holder = box_for_image('file:' + @filename)
        @window.scene_graph << @holder
      end
    end
    private :setup_holder
  end
end
