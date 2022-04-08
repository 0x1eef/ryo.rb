# frozen_string_literal: true

module Ryo
  require_relative "ryo/brain"
  require_relative "ryo/object_mixin"
  require_relative "ryo/object"

  extend Ryo::Brain

  ##
  # @param [Ryo, nil] prototype
  #  The prototype.
  #
  # @return [Object, BasicObject]
  def initialize(prototype)
    @proto = prototype
    @table = {}
  end

  ##
  # Returns the prototype of self, or "nil" if self
  # has no prototype.
  #
  # @return [Ryo, nil]
  def __proto__
    @proto
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
      @table[property]
    else
      return unless @proto
      Ryo.call_method(@proto, property)
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
    Ryo.define_property!(self, property.to_s, value)
  end

  ##
  # @param [Ryo] other
  #  An object to compare against.
  #
  # @return [Boolean]
  #  Returns true when *other* is a Ryo
  #  object with the same internal lookup
  #  table.
  def ==(other)
    return unless Ryo === other
    @table == Ryo.unbox_table(other)
  end
  alias_method :eql?, :==

  def inspect
    klass = Ryo.class_of(self) == ::Object ? "Object" : "BasicObject"
    "#<Ryo (#{klass}) @proto=#{@proto.inspect} @table=#{@table.inspect}>"
  end

  def pretty_print(q)
    q.text(inspect)
  end

  def respond_to?(property, include_all = false)
    respond_to_missing?(property, include_all)
  end

  def respond_to_missing?(property, include_all = false)
    true
  end

  ##
  # @api private
  def method_missing(name, *args, &b)
    property = name.to_s
    if property[-1] == "="
      property = property[0..-2]
      self[property] = args.first
    elsif Ryo.property?(self, property)
      self[property]
    elsif @proto.respond_to?(name)
      Ryo.call_method(@proto, name, *args, &b)
    end
  end
end
