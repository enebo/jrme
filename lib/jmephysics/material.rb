
class Material
  def self.create(name, &block)
    material = Material.new name
    material.instance_eval &block
    material
  end

  def contact(pairs)
    pairs.each do |contact_material, details|
      putContactHandlingDetails contact_material, details
    end
  end

  def density(value)
    self.density = value
  end
end
