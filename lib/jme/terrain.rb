class ProceduralTextureGenerator
  # DRY'd way of producing a texture from the generator
  #
  # height_map:: some type of +HeightMap+
  # size:: size of the texture to generate
  def self.create(height_map, size, texture_list)
    generator = ProceduralTextureGenerator.new height_map
    texture_list.each do |image_url, low, optimal, high|
      puts "image_url: #{image_url}"
      generator.add_texture image_icon(image_url), low, optimal, high
    end
    generator.create_texture(size)
    generator
  end
end
