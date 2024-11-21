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
  require_relative "ryo/json"
  require_relative "ryo/yaml"
  require_relative "ryo/utils"
  require_relative "ryo/reflect"
  require_relative "ryo/keywords"
  require_relative "ryo/builder"
  require_relative "ryo/basic_object"
  require_relative "ryo/object"
  require_relative "ryo/function"
  require_relative "ryo/memo"
  require_relative "ryo/enumerable"

  extend Ryo::Reflect
  extend Ryo::Keywords
  extend Ryo::Enumerable

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [Module] mod
  #  The module to extend a Ryo object with
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns an extended Ryo object
  def self.extend!(ryo, mod)
    kernel(:extend).bind_call(ryo, mod)
  end

  ##
  # Duplicates a Ryo object, and its prototype(s).
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a duplicated Ryo object
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
  # Creates a memoized Ryo value
  #
  # @param [Proc] b
  #  A Proc that is memoized after being accessed for the first time
  # @return [Ryo::Memo]
  #  Returns an instance of {Ryo::Memo Ryo::Memo}
  def self.memo(&b)
    Ryo::Memo.new(&b)
  end
  class << Ryo
    alias_method :lazy, :memo
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object
  #
  # @param props (see Ryo::Builder.build)
  # @param prototype (see Ryo::Builder.build)
  # @return [Ryo::Object]
  #  Returns an instance of {Ryo::Object Ryo::Object}
  def self.from(props, prototype = nil)
    Ryo::Object.from(props, prototype)
  end

  ##
  # @return [<Ryo::Object, Ryo::BasicObject>, nil]
  #  Returns the prototype of self, or nil if self has no prototype
  def __proto__
    @_proto
  end

  ##
  # @note
  #  This method will first look for a property on self,
  #  and if it is not found then it will forward the query
  #  onto `Ryo#__proto__`
  # @param [String] property
  #  The name of a property
  # @return [<Object, BasicObject>, nil]
  #  Returns the property's value, or nil
  def [](property)
    property = property.to_s
    if Ryo.property?(self, property)
      v = @_table[property]
      Ryo.memo?(v) ? self[property] = v.call : v
    else
      return unless @_proto
      Ryo.call_method(@_proto, property)
    end
  end

  ##
  # Assign a property
  #
  # @param [String] property
  #  The name of a property
  # @param [<Object,BasicObject>] value
  # @return [void]
  def []=(property, value)
    Ryo.define_property(self, property.to_s, value)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>, Hash, #to_h] other
  # @return [Boolean]
  #  Returns true **other** is equal to self
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
  #  Returns a String representation of a Ryo object
  def inspect
    Ryo.inspect_object(self)
  end

  ##
  # @return [Hash]
  #  Returns the lookup table of a Ryo object
  def to_h
    Ryo.table_of(self, recursive: true)
  end
  alias_method :to_hash, :to_h

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
# @return [Ryo::Object]
#  Returns a Ryo object
def Ryo(props, prototype = nil)
  Ryo::Object.create(props, prototype)
end
