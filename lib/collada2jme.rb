require 'jme'

import java.net.MalformedURLException
import java.io.FileNotFoundException
import java.io.FileInputStream
import java.io.IOException

class ColladaToJme < BaseSimpleGame
  JFile = java.io.File

  def initialize(model_file, texture_directory)
    super()
    @model_file, @texture_directory = model_file, texture_directory
  end

  def simpleInitGame
    write_file @model_file, @texture_directory
    puts "Done writing model file"
  end
    
  def write_file(inputFile, texture_directory)
    in_file = JFile.new(inputFile)
    if File.directory?(inputFile)
      inputFile += "/" if inputFile !~ /\/$/

      in_file.list.to_a.each do |file|
        puts "Sending: #{inputFile}#{file}"
        write_file inputFile+file, texture_directory
      end
      return
    end
        
    if in_file.name =~ /.dae$/i
      puts "Found Collada file, converting: #{inputFile}"
      model_name = inputFile.sub(/.dae$/i, '')
      out = model_name + ".jme"
      puts "Storing as: #{out}"
#       begin
#         url = JFile.new(texture_directory).toURI.toURL
#       rescue MalformedURLException => e2
#         puts "Error creating File: #{e2}"
#       end
      begin
        input = FileInputStream.new in_file
      rescue FileNotFoundException => e1
        puts "Error creating FileInputStream " + e1
      end
      if input == nil
        puts "Unable to find file"
        exit 0
      end
            
      begin
        ColladaImporter.load(input, model_name)
        collada = ColladaImporter.getModel
        ColladaImporter.clean_up
      rescue Exception => e
        puts "Error loading Collada file: " + e
      end
            
      collada.updateGeometricState(0, true)
      collada.updateRenderState
            
      begin
        File.delete(out) if File.exists?(out)

        puts "Exporting to #{out}"
        BinaryExporter.instance.save(collada, java.io.File.new(out))
        puts "Done"
      rescue IOException => e
        puts "Error saving Collada file: " + e
      end
    end
  end
end

if ARGV.length != 2
  puts "USAGE: ColladaToJme <COLLADA File> <Texture Directory>"
  exit 1
end

ColladaToJme.new(*ARGV).start
