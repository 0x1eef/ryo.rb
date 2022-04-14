module Ryo::Brain
  VITAL_METHODS = %w[
    method_missing
    pretty_print
    respond_to?
    respond_to_missing?
  ].freeze
  private_constant :VITAL_METHODS

  ##
  # @group JavaScript equivalents
  #
  # Equivalent to JavaScript's "Object.hasOwn",
  # "Object.prototype.hasOwnProperty".
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

  ##
  # @example
  #   person = Object.create(nil, {greet: Ry.fn { puts "Hello #{name}" }})
  #   tim = Object.create(person, {name: "Tim"})
  #   tim.greet.()
  #
  # @param [Proc] b
  #  The functions body (as a Proc)
  #
  # @return [Ryo::Function]
  #  Returns a Ryo function that is bound to the
  #  self of the Ryo object it is assigned to.
  def function(&b)
    Ryo::Function.new(&b)
  end
  alias_method :fn, :function

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
  # Equivalent to JavaScript's "delete" operator.
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
  # @endgroup

  ##
  # @group Public interface
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @return [Hash]
  #  Returns the internal lookup table of
  #  the *ryo* object.
  def unbox_table(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@_table)
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
  #  of an object, even when "__proto__" has
  #  been redefined on the mentioned object.
  def unbox_proto(ryo)
    module_method(:instance_variable_get)
      .bind_call(ryo, :@_proto)
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
  #  Returns true when *obj* is a Ryo function.
  def function?(obj)
    Ryo::Function === obj
  end

  ##
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
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
      proto: unbox_proto(ryo).inspect,
      table: unbox_table(ryo).inspect
    )
  end
  # @endgroup

  ##
  # @group Private interface
  #
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
    table[property] = value.tap { _1.bind!(ryo) if function?(_1) }
    # Define setter
    if !setter_defined?(ryo, property) && property[-1] != "?"
      define_method!(ryo, "#{property}=") { ryo[property] = _1 }
    end
    # Define getter
    return if getter_defined?(ryo, property)
    if VITAL_METHODS.include?(property)
      define_method!(ryo, property) { |*args, &b| args.empty? ? ryo[property] : super(*args, &b) }
    else
      define_method!(ryo, property) { ryo[property] }
    end
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
      .bind_call(ryo, :@_proto, prototype)
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
      .bind_call(ryo, :@_table, table)
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
  #  An object who has included the Ryo
  #  module.
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
    obj1 = unbox_table(obj1) if Ryo === obj1
    obj2 = unbox_table(obj2) if Ryo === obj2
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
