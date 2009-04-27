# Simple Explosion code taken from jME tutorials
class ExplosionManager
  def initialize
    @explosions = []
    warmup
  end

  def explosion
    @explosions.each { |explosion| return explosion unless explosion.active? }

    create_explosion
  end
  
  #Way too specific...actual explosion management migt  be a general class?
  def create_explosion
    explosion = ParticleFactory.buildParticles("big", 80).set! :emission_direction => Vector3f.new(0, 1, 0),
      :maximum_angle => FastMath::PI, :speed => 1, :minimum_life_time => 600, 
      :start_size => 3, :end_size => 7, 
      :start_color => ColorRGBA.new(1, 0.312, 0.121, 1), 
      :end_color => ColorRGBA.new(1, 0.24313726, 0.03137255, 0), 
      :control_flow => false,
      :initial_velocity => 0.02, :particle_spin_speed => 0, :repeat_type => Controller::RT_CLAMP

    explosion.warmUp 1000
    explosion.render_state(@ts, @bs, @zstate)

    @explosions << explosion
    explosion
  end
    
  def clean_explosions(explosions)
    count = 0
    explosions.collect do |explosion|
      unless explosion.active?
        explosion.remove_from_parent if explosion.parent
        count = count + 1
        count <= 5  # collect only first non-active
      else
        true
      end
    end
  end

  def warmup
    display = DisplaySystem.getDisplaySystem
    @bs = display.renderer.createBlendState.set! :blend_enabled => true,
      :source_function => BlendState::SourceFunction::SourceAlpha,
      :destination_function => BlendState::DestinationFunction::One, 
      :test_enabled => true,
      :test_function => BlendState::TestFunction::GreaterThan

    @ts = display.renderer.createTextureState
    @ts.setTexture(TextureManager.load(display.resource("data/texture/flaresmall.jpg")))

    @zstate = display.renderer.createZBufferState.set! :enabled => false

    3.times { create_explosion }
  end
end

