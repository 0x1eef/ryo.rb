# frozen_string_literal: true

##
# The {Ryo::Reflect Ryo::Reflect} module mirrors
# JavaScript's [`Relfect` object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect),
# and some of the static methods on JavaScript's
# [`Object`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object)
# as well.
#
# {Ryo::Reflect Ryo::Reflect} also implements Ryo-specific
# reflection features. The instance methods of this module
# are available as singleton methods on the {Ryo Ryo}
# module.
module Ryo::Reflect
  extend self

  ##
  # @group JavaScript equivalents (Reflect)

  ##
  # Equivalent to JavaScript's `Reflect.getPrototypeOf`
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
  # Equivalent to JavaScript's `Reflect.setPrototypeOf`
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
  # Equivalent to JavaScript's `Reflect.defineProperty`
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  The name of a property
  # @param [Object, BasicObject] value
  #  The property's value
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
  # JavaScript's `Object.keys`
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @return [Array<String>]
  #  Returns the properties defined on a Ryo object
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
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  The name of a property
  # @return [Boolean]
  #  Returns true when the property is a member of a Ryo object
  def property?(ryo, property)
    table_of(ryo).key?(property.to_s)
  end

  ##
  # Equivalent to JavaScript's `Object.assign`.
  #
  # @param [Ryo, Hash, #to_hash] target
  #  The target object
  # @param [Ryo, Hash, #to_hash] sources
  #  A variable number of source objects that
  #  will be merged with the target object
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
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @return [Array<Ryo::Object, Ryo::BasicObject>]
  #  Returns the prototype chain of a Ryo object
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
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [Boolean] recursive
  #  When true, nested Ryo objects are replaced by
  #  their table as well
  # @return [Hash]
  #  Returns the table of a Ryo object
  def table_of(ryo, recursive: false)
    table = kernel(:instance_variable_get).bind_call(ryo, :@_table)
    if recursive
      table.each do |key, value|
        if ryo?(value)
          table[key] = table_of(value, recursive:)
        elsif value.respond_to?(:each)
          table[key] = value.respond_to?(:each_pair) ?
                       value : value.map { table_of(_1, recursive:) }
        end
      end
    end
    table
  end

  ##
  # Sets the table of a Ryo object
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [Hash] table
  #  The table
  # @return [nil]
  def set_table_of(ryo, table)
    kernel(:instance_variable_set)
      .bind_call(ryo, :@_table, table)
    nil
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, Symbol>] method
  #  The name of a method
  # @param [::Object, ::BasicObject] args
  #  Zero or more method arguments
  # @param [Proc] b
  #  An optional block
  # @return [::Object, ::BasicObject]
  def call_method(ryo, method, *, &b)
    kernel(:__send__)
      .bind_call(ryo, method, *, &b)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @return [Class]
  #  Returns the class of a Ryo object
  def class_of(ryo)
    kernel(:class).bind_call(ryo)
  end

  ##
  # @param [Ryo::Function, Object, BasicObject] obj
  #  An object
  # @return [Boolean]
  #  Returns true when given a Ryo function
  def function?(obj)
    Ryo::Function === obj
  end

  ##
  # @param [Ryo::Function, Object, BasicObject] obj
  #  An object
  # @return [Boolean]
  #  Returns true when given a Ryo memo
  def memo?(obj)
    Ryo::Memo === obj
  end
  alias_method :lazy?, :memo?

  ##
  # @example
  #  Ryo.ryo?(Ryo::Object(x: 5, y: 12))       # => true
  #  Ryo.ryo?(Ryo::BasicObject(x: 10, y: 20)) # => true
  #  Ryo.ryo?(Object.new) # => false
  #
  # @param [Object, BasicObject] obj
  #  An object
  # @return [Boolean]
  #  Returns true when given a Ryo object
  def ryo?(obj)
    Ryo === obj
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo1
  #  A Ryo object
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo2
  #  A Ryo object
  # @return [Boolean]
  #  Returns true when the two Ryo objects are strictly equal
  def equal?(ryo1, ryo2)
    kernel(:equal?).bind_call(ryo1, ryo2)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @return [String]
  #  Returns a String representation of a Ryo object
  def inspect_object(ryo)
    format(
      "#<Ryo object=%{object} proto=%{proto} table=%{table}>",
      object: Object.instance_method(:to_s).bind_call(ryo),
      proto: prototype_of(ryo).inspect,
      table: table_of(ryo).inspect
    )
  end
  # @endgroup

  include Ryo::Utils
end
