# Assumes 'settings' method exists
module ScreenSettings
  def create_camera(display)
    display.renderer.createCamera settings.width, settings.height
  rescue JmeException => e
    puts e
    exit 1
  end

  def create_display
    display = DisplaySystem.getDisplaySystem settings.renderer
    display.createWindow settings.width, settings.height, settings.depth, settings.frequency, settings.fullscreen?
    display
  rescue JmeException => e
    puts e
    exit 1
  end
end
