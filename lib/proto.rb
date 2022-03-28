# frozen_string_literal: true

module Proto
  require_relative "proto/object_mixin"

  def initialize(prototype = nil)
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
  #   The property.
  #
  # @return [Object, BasicObject]
  #   The value at *property*, or nil.
  #
  # @note
  #   This method will first try to read the property from self, and if
  #   the property is not found on self the chain of prototypes will be
  #   traversed through instead.
  def [](property)
    property = property.to_s
    if property?(property)
      @table[property]
    else
      return nil unless @proto
      @proto.public_send(property)
    end
  end

  ##
  # Adds a property to self.
  #
  # @param [String] property
  #   The property.
  #
  # @param [Object,BasicObject] value
  #   The value.
  def []=(property, value)
    property = property.to_s
    __add(property, value)
  end

  ##
  # @param [Hash, #to_h, #to_hash] other
  #
  def ==(other)
    @table == __try_convert_to_hash(other)
  end
  alias_method :eql?, :==

  ##
  # @param [String] property
  #   The property.
  #
  # @return [Boolean]
  #   Returns true when *property* is a member of self.
  #
  def property?(property)
    @table.key?(property.to_s)
  end

  ##
  # Delete all properties from self.
  #
  # @return [void]
  #
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
    __delete(property.to_s)
  end

  ##
  # @return [Hash]
  #   A shallow copy of the lookup table used by self.
  #
  def to_hash
    @table.dup
  end
  alias_method :to_h, :to_hash

  def method_missing(name, *args, &block)
    property = name.to_s
    if property[-1] == "="
      short_property = property[0..-2]
      self[short_property] = args[0]
    elsif property?(property)
      self[property]
    elsif @proto.respond_to?(name)
      @proto.public_send(name, *args, &block)
    end
  end

  def respond_to_missing?(property, include_all = false)
    property?(property) or @proto.respond_to?(property) or super(property, include_all)
  end

  private

  def __try_convert_to_hash(obj)
    if Hash === obj
      obj
    elsif obj.respond_to?(:to_h)
      obj.to_h
    elsif obj.respond_to?(:to_hash)
      obj.to_hash
    end
  end

  def __add(property, value)
    unless singleton_class.method_defined? property
      define_singleton_method(property) { self[property] }
      define_singleton_method("#{property}=") { |val| @table[property] = val }
    end
    @table[property] = value
  end

  def __delete(property)
    @table.delete(property)
    return unless instance_of?(method(property).owner)
    define_singleton_method(property) { self[property] }
  rescue NameError
  end
end

class Object
  extend Proto::ObjectMixin
end
