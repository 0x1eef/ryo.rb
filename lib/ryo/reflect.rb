# frozen_string_literal: true

##
# The {Ryo::Reflect Ryo::Reflect} module implements equivalents
# from JavaScript's [`Relfect` object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect),
# and equivalents for some of the static methods on JavaScript's
# [`Object`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object) constructor.
#
# This module also implements Ryo-specific reflection features as well. The
# instance methods of this module are available as singleton methods
# on the {Ryo Ryo} module.
module Ryo::Reflect
  extend self

  ##
  # @group JavaScript equivalents (Reflect)

  ##
  # Equivalent to JavaScript's `Reflect.getPrototypeOf`.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [Ryo, nil]
  #  Returns the prototype of the *ryo* object.
  def prototype_of(ryo)
    kernel(:instance_variable_get)
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
    kernel(:instance_variable_set)
      .bind_call(ryo, :@_proto, prototype)
    nil
  end

  ##
  # Equivalent to JavaScript's `Reflect.defineProperty`.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, #to_s>] property
  #  The name of the property.
  #
  # @param [Object, BasicObject] value
  #  The value of the property.
  #
  # @return [void]
  def define_property(ryo, property, value)
    table, property = table_of(ryo), property.to_s
    kernel(:tap).bind_call(value) { _1.bind!(ryo) if function?(_1) }
    table[property] = value
    # Define setter
    if !setter_defined?(ryo, property) && property[-1] != "?"
      define_method!(ryo, "#{property}=") { ryo[property] = _1 }
    end
    # Define getter
    return if getter_defined?(ryo, property)
    define_method!(ryo, property) { |*args, &b|
      (args.empty? && b.nil?) ? ryo[property] :
                              super(*args, &b)
    }
    nil
  end

  ##
  # Equivalent to JavaScript's `Reflect.ownKeys`, and
  # JavaScript's `Object.keys`.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [Array<String>]
  #  Returns the properties defined on a Ryo object.
  def properties_of(ryo)
    table_of(ryo).keys
  end

  # @endgroup

  ##
  # @group JavaScript equivalents (Object)

  ##
  # Equivalent to JavaScript's `Object.hasOwn`,
  # and `Object.prototype.hasOwnProperty`.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, #to_s>] property
  #  A property name.
  #
  # @return [Boolean]
  #  Returns true when **property** is a member of a Ryo object.
  def property?(ryo, property)
    table_of(ryo).key?(property.to_s)
  end

  ##
  # Equivalent to JavaScript's `Object.assign`.
  #
  #
  # @param [Ryo, Hash, #to_hash] target
  #  The target object.
  #
  # @param [Ryo, Hash, #to_hash] sources
  #  A variable number of source objects that
  #  will be merged into the target object.
  #
  # @return [Ryo]
  #  Returns the modified target object.
  def assign(target, *sources)
    sources.each do |source|
      to_hash(source).each { target[_1.to_s] = _2 }
    end
    target
  end
  # @endgroup

  ##
  # @group Ryo-specific

  ##
  # The {#delete!} method deletes a property from a Ryo object,
  # and from the prototypes in its prototype chain.
  #
  # @see Ryo::Keywords#delete
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, #to_s>] property
  #  A property name.
  #
  # @return [void]
  def delete!(ryo, property)
    [ryo, *prototype_chain_of(ryo)].each do
      Ryo.delete(_1, property.to_s)
    end
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [Array<Ryo::Object, Ryo::BasicObject>]
  #  Returns the prototype chain of a Ryo object.
  def prototype_chain_of(ryo)
    prototypes = []
    loop do
      ryo = prototype_of(ryo)
      break unless ryo
      prototypes.push(ryo)
    end
    prototypes
  end

  ##
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [Hash]
  #  Returns the table of a Ryo object.
  def table_of(ryo)
    kernel(:instance_variable_get)
      .bind_call(ryo, :@_table)
  end

  ##
  # Sets the table of a Ryo object.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [Hash] table
  #  The table to assign to a Ryo object.
  #
  # @return [nil]
  def set_table_of(ryo, table)
    kernel(:instance_variable_set)
      .bind_call(ryo, :@_table, table)
    nil
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, Symbol>] method
  #  The name of a method.
  #
  # @param [::Object, ::BasicObject] args
  #  Zero or more arguments to call **method** with.
  #
  # @param [Proc] b
  #  An optional block to pass to **method**.
  #
  # @return [::Object, ::BasicObject]
  #  Returns the return value of the method call.
  def call_method(ryo, method, *args, &b)
    kernel(:__send__)
      .bind_call(ryo, method, *args, &b)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [Class]
  #  Returns the class of a Ryo object.
  def class_of(ryo)
    kernel(:class).bind_call(ryo)
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
  # @example
  #  Ryo.ryo?(Ryo::Object(x: 5, y: 12))       # => true
  #  Ryo.ryo?(Ryo::BasicObject(x: 10, y: 20)) # => true
  #  Ryo.ryo?(Object.new) # => false
  #
  # @param [Object, BasicObject] obj
  #  An object.
  #
  # @return [Boolean]
  #  Returns true when the given object is a Ryo object.
  def ryo?(obj)
    Ryo === obj
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo1
  #  A Ryo object.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo2
  #  A Ryo object.
  #
  # @return [Boolean]
  #  Returns true when two Ryo objects are the same object.
  def equal?(ryo1, ryo2)
    kernel(:equal?).bind_call(ryo1, ryo2)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [String]
  #  Returns a String representation of a Ryo object.
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
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, Symbol>] method
  #  The name of the method.
  #
  # @param [Proc] b
  #  The method's body.
  #
  # @private
  private def define_method!(ryo, method, &b)
    kernel(:define_singleton_method)
      .bind_call(ryo, method, &b)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, #to_s>] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has been
  #  defined with a getter method.
  #
  # @private
  private def getter_defined?(ryo, property)
    kernel(:method)
      .bind_call(ryo, property)
      .source_location
      &.dig(0) == __FILE__
  end

  ##
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [<String, #to_s>] property
  #  The name of the property.
  #
  # @return [Boolean]
  #  Returns true when the property has been
  #  defined with a setter method.
  #
  # @private
  private def setter_defined?(ryo, property)
    getter_defined?(ryo, "#{property}=")
  end

  ##
  # @private
  private def merge!(obj1, obj2)
    obj1, obj2 = to_hash(obj1), to_hash(obj2)
    obj2.each { obj1[_1.to_s] = _2 }
    obj1
  end

  ##
  # @private
  private def to_hash(obj)
    if ryo?(obj)
      table_of(obj)
    else
      Hash.try_convert(obj)
    end
  end

  ##
  # @private
  def kernel(name)
    Module.instance_method(name)
  end
  # @endgroup
end
