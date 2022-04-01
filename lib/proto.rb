# frozen_string_literal: true

module Proto
  require_relative "proto/brain"
  require_relative "proto/object_mixin"
  require_relative "proto/object"

  ##
  # @param [Proto, nil] prototype
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
  # @return [Proto, nil]
  def prototype
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
    if property?(property)
      @table[property]
    else
      return unless @proto
      Proto.brain.call_method(@proto, property)
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
    Proto.brain.define_property!(self, property.to_s, value)
  end

  ##
  # @param [Proto] other
  #  An object to compare against.
  #
  # @return [Boolean]
  #  Returns true when *other* is a Proto
  #  object with the same internal lookup
  #  table.
  def ==(other)
    return unless Proto === other
    @table == Proto.brain.unbox_table(other)
  end
  alias_method :eql?, :==

  ##
  # @return [Class]
  #  Returns the class of self.
  def class
    Module
      .instance_method(:class)
      .bind_call(self)
  end

  def inspect
    superclass = self.class < Object ? "Object" : "BasicObject"
    "#<Proto (#{superclass}) @proto=#{@proto.inspect} table=#{@table.inspect}>"
  end

  def pretty_print(q)
    q.pp(inspect)
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
    elsif Proto.brain.property?(self, property)
      self[property]
    elsif @proto.respond_to?(name)
      Proto.brain.call_method(@proto, name, *args, &b)
    end
  end
end
