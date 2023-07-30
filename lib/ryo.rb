# frozen_string_literal: true

##
# The {Ryo Ryo} module implements most of its behavior as singleton methods
# that are inherited from the {Ryo::Reflect Ryo::Reflect}, and
# {Ryo::Keywords Ryo:Keywords} modules.
#
# @example
#   # Ryo.delete
#   point = Ryo(x: 0, y: 0)
#   Ryo.delete(point, "x")
#   point.x # => nil
#
#   # Ryo.assign
#   point = Ryo.assign(Ryo({}), {x: 0}, {y: 0})
#   point.x # => 0
module Ryo
  require_relative "ryo/reflect"
  require_relative "ryo/keywords"
  require_relative "ryo/builder"
  require_relative "ryo/basic_object"
  require_relative "ryo/object"
  require_relative "ryo/function"
  require_relative "ryo/lazy"
  require_relative "ryo/enumerable"

  extend Ryo::Reflect
  extend Ryo::Keywords
  extend Ryo::Enumerable

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @param [Module] mod
  #  A module to extend a Ryo object with.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a Ryo object extended by **mod**.
  def self.extend!(ryo, mod)
    kernel(:extend).bind_call(ryo, mod)
  end

  ##
  # Duplicates a Ryo object, and its prototype(s).
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a duplicated Ryo object.
  def self.dup(ryo)
    duplicate = extend!(
      kernel(:dup).bind_call(ryo),
      self
    )
    if proto = prototype_of(duplicate)
      set_prototype_of(duplicate, dup(proto))
    end
    duplicate
  end

  ##
  # Creates a lazy Ryo value.
  #
  # @param [Proc] &b
  #  A proc that is evaluated when a property is first accessed.
  #
  # @return [Ryo::Lazy]
  #  Returns an instance of {Ryo::Lazy Ryo::Lazy}.
  def self.lazy(&b)
    Ryo::Lazy.new(&b)
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object.
  #
  # @param props (see Ryo::Builder.build)
  # @param prototype (see Ryo::Builder.build)
  #
  # @return [Ryo::Object]
  #  Returns an instance of {Ryo::Object Ryo::Object}.
  def self.from(props, prototype = nil)
    Ryo::Object.from(props, prototype)
  end

  ##
  # Returns the prototype of self, or "nil" if self has no prototype.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>, nil]
  def __proto__
    @_proto
  end

  ##
  # @param [String] property
  #  A property name.
  #
  # @return [<Object, BasicObject>, nil]
  #  Returns the value at **property**, or nil.
  #
  # @note
  #  This method will first try to read **property** from self, and if
  #  it is not found on self the chain of prototypes will be traversed
  #  through instead.
  def [](property)
    property = property.to_s
    if Ryo.property?(self, property)
      v = @_table[property]
      Ryo.lazy?(v) ? self[property] = v.call : v
    else
      return unless @_proto
      Ryo.call_method(@_proto, property)
    end
  end

  ##
  # Assigns a property to self.
  #
  # @param [String] property
  #  A property name.
  #
  # @param [<Object,BasicObject>] value
  #  The value.
  #
  # @return [void]
  def []=(property, value)
    Ryo.define_property(self, property.to_s, value)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>, Hash, #to_h] other
  #  An object to compare against.
  #
  # @return [Boolean]
  #  Returns true **other** is equal to self.
  def ==(other)
    if Ryo.ryo?(other)
      @_table == Ryo.table_of(other)
    else
      other = Hash.try_convert(other)
      return false unless other
      @_table == other.map { [_1.to_s, _2] }.to_h
    end
  end
  alias_method :eql?, :==

  ##
  # @return [String]
  #  Returns a String representation of a Ryo object.
  def inspect
    Ryo.inspect_object(self)
  end

  ##
  # @private
  def pretty_print(q)
    q.text(inspect)
  end

  ##
  # @private
  def respond_to?(property, include_all = false)
    respond_to_missing?(property, include_all)
  end

  ##
  # @private
  def respond_to_missing?(property, include_all = false)
    true
  end

  ##
  # @private
  def method_missing(name, *args, &b)
    property = name.to_s
    if property[-1] == "="
      property = property[0..-2]
      self[property] = args.first
    elsif Ryo.property?(self, property)
      self[property]
    elsif @_proto
      Ryo.call_method(@_proto, name, *args, &b)
         .tap { _1.bind!(self) if Ryo.function?(_1) }
    end
  end
end

##
# @param props (see Ryo::Builder.build)
# @param prototype (see Ryo::Builder.build)
#
# @return [Ryo::Object]
#  Returns a Ryo object.
def Ryo(props, prototype = nil)
  Ryo::Object.create(props, prototype)
end
