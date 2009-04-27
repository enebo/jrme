class Effects
  def self.explosion_manager
    # TODO: lame
    @@explosion_manager ||= ExplosionManager.new
  end

  #
  # Provide an explosion effect at the location of the item
  #
  def self.explosion_for(item)
    explosion = explosion_manager.explosion
    explosion.setOriginOffset(item.local_translation.clone)
    explosion.forceRespawn
    item.parent << explosion
  end
end

#
# Any object which has a velocity, radius, and local_rotation can include
# this to rotate based on its current velocity.
#
module Rotating
  def rotate(tpf)
    @quaternion ||= Quaternion.new
    @vector ||= Vector3f.new

    # get axis of rotation (worldup).direction
    @vector.set(Vector3f::UNIT_Y).crossLocal(velocity.normalize)
    # create per frame rotation
    @quaternion.fromAngleAxis((velocity.length / radius) * tpf, @vector)
    # rotate ball
    local_rotation.set(@quaternion.multLocal(local_rotation))
  end
end

module Explosions
  def explosion
    Effects.explosion_for(self)
  end
end
