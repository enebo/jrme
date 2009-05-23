class Module
  def field(fields)
    fields.each do |name, default_value|
      name = name.to_s
      attr_reader name
      define_method(name + '=') do |value|
        puts "NAME #{name} #{value} #{self}"
        self.set_attribute '@' + name, (value.nil? ? default_value : value)
      end
    end
  end
end
