module Gosu
  class Font
    attr_reader :height

    # font_name can either be the name of a system font, or a filename 
    # (must contain '/', does not work on Linux yet). height is the height 
    # of the font, in pixels.
    def initialize(window, font_name, height)
      @height = height
      @font_name = font_name
      @font_size = 12
      # Todo load font
      @font = BitmapFontLoader.loadDefaultFont
    end

    # Returns the width in pixels the given text would span.
    def text_width(text, factor_x=1)
    end

    def draw(text, x, y, z, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
    end

    # If relX is 0.0, the text will be to the right of x, if it is 1.0, the text
    # will be to the left of x, if it is 0.5, it will be centered on x. Of
    # course, all real numbers are possible values. The same applies to relY.
    def draw_rel(text, x, y, z, rel_x, rel_y, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
    end

    # Same as draw but rotated at the top left corner. 
    def draw_rot(text, x, y, z, angle, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
    end

    def make_bitmap_text(message, size, color, &block)
      BitmapText.new(@font, false).tap do |font|
        text.size = size
        text.default_color = color.clone
        text.box = Rectangle.new(10, -10, width - 20, height - 20)
        block.arity == 1 ? block[text] : text.instance_eval(&block)
        text.text = message
        text.update
      end
    end
    private :make_bitmap_text
  end
end
