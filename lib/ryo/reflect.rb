##
# The Reflect module's instance methods are available as
# singleton methods on the `Ryo` and `Ryo::Reflect` modules.
# The Reflect module follows a pattern where the first argument
# is a Ryo object, and the rest of the arguments are for the
# functionality the singleton method provides. It is similar to
# JavaScript's [`Reflect` object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect).
module Ryo::Reflect
  extend self

  ##
  # @group JavaScript equivalents
  #
  # Equivalent to JavaScript's "Object.hasOwn",
  # "Object.prototype.hasOwnProperty".
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [String] property
  #  The property.
  #
  # @return [Boolean]
  #  Returns true when *property* is a member of
  #  *ryo*.
  def property?(ryo, property)
    table_of(ryo).key?(property.to_s)
  end

  ##
  # Equivalent to JavaScript's `Reflect.getPrototypeOf`.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [Ryo, nil]
  #  Returns the prototype of the *ryo* object.
  def prototype_of(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@_proto)
  end

  ##
  # Equivalent to JavaScript's `Reflect.setPrototypeOf`.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [Ryo] prototype
  #  The prototype to assign to *ryo*.
  #
  # @return [nil]
  def set_prototype_of(ryo, prototype)
    module_method(:instance_variable_set)
      .bind_call(ryo, :@_proto, prototype)
    nil
  end

  ##
  # Equivalent to JavaScript's "Object.assign"
  #
  # @param [Ryo, Hash] objs
  #  A variable number of arguments to merge
  #  starting from right to left.
  #
  # @return [Ryo]
  #  Returns the first element of *objs*.
  def assign(*objs)
    robjs = objs.reverse
    robjs.each.with_index do |obj, i|
      n = robjs[i + 1]
      n ? merge!(n, obj) : merge!(objs[0], objs[1])
    end
    objs[0]
  end
  # @endgroup

  ##
  # @group Ryo-specific
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [Hash]
  #  Returns the lookup table used by a Ryo object.
  def table_of(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@_table)
  end

  ##
  # Sets the lookup table used by a Ryo object.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [Hash] table
  #  The lookup table to assign to a Ryo object.
  #
  # @return [nil]
  def set_table_of(ryo, table)
    module_method(:instance_variable_set)
      .bind_call(ryo, :@_table, table)
    nil
  end

  ##
  # @param [Ryo] ryo
  #  A Ryo object.
  #
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
  # Delete all properties from *ryo*.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [nil]
  def clear!(ryo)
    table_of(ryo).clear
    nil
  end

  ##
  #
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
  # @param [Ryo::Function, Object, BasicObject] obj
  #  An object.
  #
  # @return [Boolean]
  #  Returns true when the given object is a Ryo function.
  def function?(obj)
    Ryo::Function === obj
  end

  ##
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [String]
  #  Returns details about the *ryo* object
  #  as a String.
  #
  # @note
  #  This is primarily for nice output in IRB,
  #  Pry, etc. It is used by {Ryo#inspect}.
  def inspect_object(ryo)
    format(
      "#<Ryo object=%{object} proto=%{proto} table=%{table}>",
      object: Object.instance_method(:to_s).bind_call(ryo),
      proto: prototype_of(ryo).inspect,
      table: table_of(ryo).inspect
    )
  end
  # @endgroup

  ##
  # @group Private interface
  #
  # @param [Ryo] ryo
  #  A Ryo object.
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
    table = table_of(ryo)
    table[property] = value.tap { _1.bind!(ryo) if function?(_1) }
    # Define setter
    if !setter_defined?(ryo, property) && property[-1] != "?"
      define_method!(ryo, "#{property}=") { ryo[property] = _1 }
    end
    # Define getter
    return if getter_defined?(ryo, property)
    define_method!(ryo, property) { |*args, &b|
      args.empty? && b.nil? ? ryo[property] :
                              super(*args, &b)
    }
  end

  ##
  # @param [Ryo] ryo
  #  A Ryo object.
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
  #  A Ryo object.
  #
  # @param [String] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has been
  #  defined with a getter method.
  def getter_defined?(ryo, property)
    module_method(:method)
      .bind_call(ryo, property)
      .source_location
      &.dig(0) == __FILE__
  end

  ##
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @param [String] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has been
  #  defined with a setter method.
  def setter_defined?(ryo, property)
    getter_defined?(ryo, "#{property}=")
  end

  ##
  # @api private
  def merge!(obj1, obj2)
    obj1 = table_of(obj1) if Ryo === obj1
    obj2 = table_of(obj2) if Ryo === obj2
    obj2.each { obj1[_1.to_s] = _2 }
    obj1
  end

  ##
  # @api private
  def module_method(name)
    Module.instance_method(name)
  end
  # @endgroup
end
