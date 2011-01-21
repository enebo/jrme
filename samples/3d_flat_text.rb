require 'jmephysics'

game = StandardGame.new "Test 3D Flat Text"
game.start

GameTaskQueueManager.getManager.update do
  debug = DebugGameState.new
  GameStateManager.get_instance.attach_child debug
  debug.active = true

  font = Font3D.new Font.new("Arial", Font::PLAIN, 24), 0.001, true, true, true
  text = font.createText("Testing 1, 2, 3", 50, 0)
  text.local_scale = Vector3f.new(5, 5, 0.01)
  debug.root_node << text
  nil
end
