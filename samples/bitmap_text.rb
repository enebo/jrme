require 'jmephysics'

def make_bitmap_text(message, font, size, color, &block)
  text = BitmapText.new font, false
  text.size = size
  text.default_color = color.clone
  block.arity == 1 ? block[text] : text.instance_eval(&block)
  text.text = message
  text.update
  text
end

game = StandardGame.new "Test BitmapFont & BitmapText"
game.start

txtB = "This extension provides a mechanism\n to specify vertex attrib and element array locations using GPU addresses."
        
txtC = "This extension provides a mechanism to specify vertex attrib and element array locations using GPU addresses."

GameTaskQueueManager.getManager.update do
  debug = DebugGameState.new
  GameStateManager.getInstance.attach_child debug
  debug.active = true

  orthoNode = Node.new
  font = BitmapFontLoader.loadDefaultFont
  width, height = game.display.width, game.display.height
  txt = make_bitmap_text(txtB, font, 32, ColorRGBA.green) do |t|
    t.box = Rectangle.new(10, -10, width - 20, height - 20)
  end

  txt2 = make_bitmap_text(txtB, font, 32, ColorRGBA.orange) do |t|
    t.box = Rectangle.new(10, -height * 0.3, width - 20, height - 20)
    t.use_kerning = false
    t.alignment = BitmapFont::Align::Center
  end

  txt3 = make_bitmap_text(txtB, font, 32, ColorRGBA.blue) do |t|
    t.box = Rectangle.new(10, -height * 0.6, width - 20, height - 20)
    t.alignment = BitmapFont::Align::Right
  end

  text = "Text without restriction.\n Text without\n restriction.\n Text without restriction. Text without restriction"
  txt4 = make_bitmap_text(text, font, 32, ColorRGBA.red) do |t|
    t.render_queue_mode = Renderer::QUEUE_TRANSPARENT
    t.size = 3
    t.alignment = BitmapFont::Align::Center
    t.local_rotation = Quaternion.new.fromAngleAxis(55 * FastMath::DEG_TO_RAD, Vector3f.new(0, 1, 0))
  end

  txt4.text = "Shortened it!\n :)"
  txt4.update

  txt4.text = "Elongated\n it to test! :)"
  txt4.update
  
  debug.root_node << txt4

  orthoNode.setLocalTranslation(0, height, 0)
#  orthoNode.cull_hint = Spatial::CullHint::Never
  orthoNode << txt << txt2 << txt3

  debug.root_node << orthoNode
  nil
end
