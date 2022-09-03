# frozen_string_literal: true

module Ryo
  require_relative "ryo/reflect"
  require_relative "ryo/keywords"
  require_relative "ryo/builder"
  require_relative "ryo/basic_object"
  require_relative "ryo/object"
  require_relative "ryo/function"
  require_relative "ryo/tap"

  extend Ryo::Reflect
  extend Ryo::Keywords

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
    Module
      .instance_method(:extend)
      .bind_call(ryo, mod)
  end

  ##
  # Iterates over a Ryo object.
  #
  # @example
  #  Ryo(foo: 1, bar: 2).each.map { _2 * 2 }
  #  # => [2, 4]
  #
  # @param [Ryo::Object, Ryo::BasicObject] ryo
  #  A Ryo object.
  #
  # @return [Enumerator, Array]
  #  Returns an Enumerator when a block is not given,
  #  otherwise returns an Array.
  def self.each(ryo)
    return enum_for(:each, ryo) unless block_given?
    properties_of(ryo).each { yield(_1, ryo[_1]) }
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
  # Returns the prototype of self, or "nil" if self
  # has no prototype.
  #
  # @return [Ryo, nil]
  def __proto__
    @_proto
  end

  ##
  # @param [String] property
  #  The property.
  #
  # @return [Object, BasicObject]
  #  The value at *property*, or nil.
  #
  # @note
  #  This method will first try to read the property from self, and if
  #  the property is not found on self the chain of prototypes will be
  #  traversed through instead.
  def [](property)
    property = property.to_s
    if Ryo.property?(self, property)
      @_table[property]
    else
      return unless @_proto
      Ryo.call_method(@_proto, property)
    end
  end

  ##
  # Adds a property to self.
  #
  # @param [String] property
  #  The property.
  #
  # @param [Object,BasicObject] value
  #  The value.
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
    if Ryo === other
      @_table == Ryo.table_of(other)
    else
      other = Hash.try_convert(other)
      return false unless other
      @_table == other
    end
  end
  alias_method :eql?, :==

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
# @param [<.each>] each_obj
#  An object that implements each, and yields two arguments.
#
# @param [Ryo] prototype
#  The prototype.
#
# @return [Ryo::Object]
def Ryo(each_obj, prototype = nil)
  Ryo::Object.create(each_obj, prototype)
end
