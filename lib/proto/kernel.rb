##
# The purpose of the Proto::Kernel module is to provide a
# separate namespace for methods that would otherwise be
# defined as instance private methods on the Proto module.
#
# @api private
module Proto::Kernel
  ##
  # @param [Proto] proto
  #  An object who has included the Proto module.
  #
  # @param [String, to_s] property
  #  The name of the property.
  #
  # @param [Object, BasicObject]
  #  The value of the property.
  #
  # @return [void]
  # @api private
  def self.define_property!(proto, property, value)
    table = proto.__table__
    table[property] = value
    return if proto.method_defined?(property)
    define_singleton_method!(proto, property) { proto[property] }
    define_singleton_method!(proto, "#{property}=") { proto[property] = _1 }
  end

  ##
  # @param [Proto] proto
  #  An object who has included the Proto
  #  module.
  #
  # @param [String, Symbol]
  #  The name of the method.
  #
  # @param [Proc] &b
  #  The method's body.
  #
  # @return [void]
  def self.define_singleton_method!(proto, method, &b)
    Module
      .instance_method(:define_singleton_method)
      .bind_call(proto, method, &b)
  end

  ##
  # @param [Proto] proto
  #  An object who has included the Proto
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method.
  #
  # @return [Method]
  #  Returns a Method object for *method*.
  def self.method(proto, method)
    Module
      .instance_method(:method)
      .bind_call(proto, method)
  end

  # @param [Proto] proto
  #  An object who has included the Proto
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method.
  #
  # @return [String, nil]
  #  Returns the path to the file that defined *method*.
  def self.method_file(proto, method)
    method(proto, method).source_location.dig(0)
  end

  ##
  # @param [Proto] proto
  #  An object who has included the Proto
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method
  #
  # @return [Boolean]
  #  Returns true when *method* is defined on self.
  def self.method_defined?(proto, method)
    (class << proto; self; end).method_defined?(method, false)
  end
end
