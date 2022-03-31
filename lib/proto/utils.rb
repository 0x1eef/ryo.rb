##
# The purpose of the Proto::Utils module is to provide a
# separate namespace for methods that would othermise be
# defined as instance private methods on the Proto module.
#
# @api private
module Proto::Utils
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
  #  An object who has included the Proto module.
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
      .bind(proto)
      .call(method, &b)
  end
end
