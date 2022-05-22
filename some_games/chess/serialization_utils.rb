require 'json'

# mixin
module BasicSerializable
  # should point to a class; change to a different class (e.g. MessagePack, JSON, YAML) to get a different serialization
  @@serializer = JSON
  @@default_classes = [Integer, Float, String, Array, Hash, NilClass, Symbol, FalseClass]
  @@default_classes_name = ['Integer', 'Float', 'String', 'Array', 'Hash', 'NilClass', 'Symbol', 'FalseClass']

  def serialize(to_serialize = self)
    obj = {}

    to_serialize.instance_variables.map do |var|
      class_of_var = to_serialize.instance_variable_get(var).class
      obj[var] = {}
      obj[var]['class_name'] = class_of_var

      if @@default_classes.include?(class_of_var)
        obj[var]['data'] = to_serialize.instance_variable_get(var)
      else
        obj[var]['data'] = serialize(to_serialize.instance_variable_get(var))
      end
    end

    @@serializer.dump obj
  end

  def unserialize(string, to_unserialize = self)
    obj = @@serializer.parse(string)

    obj.keys.each do |key|
      class_of_var = obj[key]['class_name']
      if @@default_classes_name.include?(class_of_var)
        data = obj[key]['data']
        to_unserialize.instance_variable_set(key, data)
      else
        to_unserialize.instance_variable_set(key, Kernel.const_get(class_of_var).new)
        unserialize(obj[key]['data'], to_unserialize.instance_variable_get(key))
      end
    end
  
  end
end