module Ryo::Brain
  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String, to_s] property
  #  The name of the property.
  #
  # @param [Object, BasicObject]
  #  The value of the property.
  #
  # @return [void]
  # @api private
  def define_property!(ryo, property, value)
    table = unbox_table(ryo)
    table[property] = value
    return if method_defined?(ryo, "#{property}=")
    define_method!(ryo, property) { ryo[property] }
    define_method!(ryo, "#{property}=") { ryo[property] = _1 }
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @return [Hash]
  #  Returns the internal lookup table used by
  #  *ryo*.
  def unbox_table(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@table)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @return [Ryo, nil]
  #  Returns the prototype of the *ryo*
  #  object.
  #
  # @note
  #  This method will return the prototype
  #  of an object, even if "__proto__" has
  #  been redefined on the mentioned object.
  def unbox_proto(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@proto)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String, Symbol] method
  #  The name of a method.
  #
  # @param [Object, BasicObject] *args
  #  A variable number of arguments for *method*.
  #
  # @param [Proc] &b
  #  An optional block for *method*.
  #
  # @return [Object, BasicObject]
  #  Returns the return value of the method call.
  def call_method(ryo, method, *args, &b)
    module_method(:__send__)
      .bind_call(ryo, method, *args, &b)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String, Symbol]
  #  The name of the method.
  #
  # @param [Proc] &b
  #  The method's body.
  #
  # @return [void]
  def define_method!(ryo, method, &b)
    module_method(:define_singleton_method)
      .bind_call(ryo, method, &b)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method.
  #
  # @return [Method]
  #  Returns a Method object for *method*.
  def method(ryo, method)
    module_method(:method)
      .bind_call(ryo, method)
  end

  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method.
  #
  # @return [String, nil]
  #  Returns the path to the file that defined *method*.
  def method_file(ryo, method)
    method(ryo, method).source_location.dig(0)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [Symbol, String] method
  #  The name of the method
  #
  # @return [Boolean]
  #  Returns true when *method* is defined on
  def method_defined?(ryo, method)
    (class << ryo; self; end).method_defined?(method, false)
  end

  ##
  # Equivalent to JavaScript's hasOwnProperty.
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The property.
  #
  # @return [Boolean]
  #  Returns true when *property* is a member of
  #  *ryo*.
  def property?(ryo, property)
    unbox_table(ryo).key?(property.to_s)
  end

  ##
  # Equivalent to JavaScript's "in" operator.
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The property.
  #
  # @return [Boolean]
  #  Returns true when *property* is a member of *ryo*,
  #  or its prototype chain.
  def in?(ryo, property)
    property?(ryo, property) ||
    property?(unbox_proto(ryo), property)
  end

  ##
  # Deletes a property from *ryo*
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The property to delete.
  #
  # @return [void]
  def delete(ryo, property)
    property = property.to_s
    if property?(ryo, property)
      unbox_table(ryo).delete(property)
    else
      return if method_defined?(ryo, property) &&
                method_file(ryo, property) == __FILE__
      define_method!(ryo, property) { ryo[property] }
    end
  end

  ##
  # Delete all properties from *ryo*.
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @return [void]
  def clear!(ryo)
    unbox_table(ryo).clear
    true
  end

  def module_method(name)
    Module.instance_method(name)
  end
end
