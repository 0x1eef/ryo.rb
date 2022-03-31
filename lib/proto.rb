# frozen_string_literal: true

module Proto
  require_relative "proto/kernel"
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
      @proto&.__send__(property)
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
    Proto::Kernel.define_property!(self, property.to_s, value)
  end

  ##
  # @param [Hash, #to_h] other
  #
  def ==(other)
    @table == other&.to_h
  end
  alias_method :eql?, :==

  ##
  # @param [String] property
  #  The property.
  #
  # @return [Boolean]
  #  Returns true when *property* is a member of self.
  def property?(property)
    @table.key?(property.to_s)
  end

  ##
  # Delete all properties from self.
  #
  # @return [void]
  def clear
    @table.clear
    true
  end

  ##
  # Deletes a property from self.
  #
  # @param [String] property
  #  The property to delete.
  #
  # @return [void]
  def delete(property)
    property = property.to_s
    if property?(property)
      @table.delete(property)
    else
      return if Proto::Kernel.method_defined?(self, property) &&
                Proto::Kernel.method_file(self, property) == __FILE__
      Proto::Kernel.define_singleton_method!(self, property) { self[property] }
    end
  end

  ##
  # @return [Hash]
  #  A shallow copy of the lookup table used by self.
  def to_h
    @table.dup
  end

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
  def __table__
    @table
  end

  ##
  # @api private
  def method_missing(name, *args, &block)
    property = name.to_s
    if property[-1] == "="
      property = property[0..-2]
      self[property] = args.first
    elsif property?(property)
      self[property]
    elsif @proto.respond_to?(name)
      @proto.__send__(name, *args, &block)
    end
  end
end
