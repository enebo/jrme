# Assumes 'settings' method exists
module ScreenSettings
  def populate_settings
    # store the properties information
    @width = settings.width
    @height = settings.height
    @depth = settings.depth
    @freq = settings.frequency
    @fullscreen = settings.isFullscreen
  end

  def create_camera(display)
    begin
      display.renderer.createCamera @width, @height
    rescue JmeException => e
      puts e
      java.lang.System.exit 1
    end
  end

  def create_display
    begin
      display = DisplaySystem.getDisplaySystem settings.renderer
      display.createWindow @width, @height, @depth, @freq, @fullscreen
      display
     rescue JmeException => e
      puts e
      java.lang.System.exit 1
    end
  end
end
