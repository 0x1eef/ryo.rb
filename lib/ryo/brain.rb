module Ryo::Brain
  ##
  # @return [Array<String>]
  #  Returns an array of method names that one can
  #  reassign as properties, while their original
  #  functionality is still kept for when needed.
  PROTECTED_METHODS = %w[
    method_missing
    pretty_print
    respond_to?
    respond_to_missing?
  ]

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String, to_s] property
  #  The name of the property.
  #
  # @param [Object, BasicObject] value
  #  The value of the property.
  #
  # @return [void]
  #
  # @api private
  def define_property!(ryo, property, value)
    table = unbox_table(ryo)
    table[property] = value

    # Define setter
    if !setter_defined?(ryo, property) && property[-1] != "?"
      define_method!(ryo, "#{property}=") { ryo[property] = _1 }
    end

    # Define getter
    return if getter_defined?(ryo, property)
    if PROTECTED_METHODS.include?(property)
      define_method!(ryo, property) { |*args, &b| args.empty? ? ryo[property] : super(*args, &b) }
    else
      define_method!(ryo, property) { ryo[property] }
    end
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
  # @param [Object, BasicObject] args
  #  A variable number of arguments for *method*.
  #
  # @param [Proc] b
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
  # @param [String, Symbol] method
  #  The name of the method.
  #
  # @param [Proc] b
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
  # @param [String] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has a
  #  getter method defined.
  def getter_defined?(ryo, property)
    module_method(:method)
      .bind_call(ryo, property)
      .source_location
      &.dig(0) == __FILE__
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has a
  #  setter method defined.
  def setter_defined?(ryo, property)
    getter_defined?(ryo, "#{property}=")
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
      return if getter_defined?(ryo, property)
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

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @return [Class]
  #  Returns the class of *ryo*
  def class_of(ryo)
    module_method(:class).bind_call(ryo)
  end

  ##
  # @param [Object, BasicObject] ryo
  #  An object to extend with the "Ryo"
  #  module.
  #
  # @return [Ryo]
  #  Returns the same object, with Ryo
  #  extended into it.
  #
  # @api private
  def extend_object!(ryo)
    module_method(:extend)
      .bind_call(ryo, Ryo)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [Ryo] prototype
  #  The prototype to assign to *ryo*.
  #
  # @return [void]
  #
  # @api private
  def assign_prototype!(ryo, prototype)
    module_method(:instance_variable_set)
      .bind_call(ryo, :@proto, prototype)
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [Ryo] table
  #  The internal look table to assign to
  #  *ryo*.
  #
  # @return [void]
  #
  # @api private
  def assign_table!(ryo, table)
    module_method(:instance_variable_set)
      .bind_call(ryo, :@table, table)
  end

  def module_method(name)
    Module.instance_method(name)
  end
end
