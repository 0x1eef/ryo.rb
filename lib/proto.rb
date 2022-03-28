# frozen_string_literal: true

module Proto
  require_relative "proto/object_mixin"

  ##
  # @param [Proto, nil] prototype
  #   The prototype.
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
      @proto&.__send__(property)
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
    __add_property(property.to_s, value)
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
    __delete_property(property.to_s)
  end

  ##
  # @return [Hash]
  #   A shallow copy of the lookup table used by self.
  def to_hash
    @table.dup
  end
  alias_method :to_h, :to_hash

  def respond_to?(property, include_all = false)
    respond_to_missing?(property, include_all)
  end

  def respond_to_missing?(property, include_all = false)
    true
  end

  ##
  # @return [Class]
  #  Returns the class of self.
  def class
    Module
    .instance_method(:class)
    .bind(self)
    .call
  end

  ##
  # @return [Class]
  # Returns the singleton class of self.
  def singleton_class
    Module
      .instance_method(:singleton_class)
      .bind(self)
      .call
  end

  ##
  # @api private
  def method_missing(name, *args, &block)
    property = name.to_s
    if property[-1] == "="
      property = property[0..-2]
      __add_property(property, args.first)
    elsif property?(property)
      self[property]
    elsif @proto.respond_to?(name)
      @proto.__send__(name, *args, &block)
    end
  end

  ##
  # @api private
  def const_missing(const)
    Object.const_get(const)
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

  def __add_property(property, value)
    @table[property] = value
    return if __method_defined?(property)
    __define_singleton_method(property) { self[property] }
    __define_singleton_method("#{property}=") { __add_property(property, _1) }
  end

  def __delete_property(property)
    if property?(property)
      @table.delete(property)
    else
      return if __method_defined?(property) &&
                __method(property).source_location.dig(0) == __FILE__
      __define_singleton_method(property) { self[property] }
    end
  end

  def __define_singleton_method(method, &b)
    Module
      .instance_method(:define_singleton_method)
      .bind(self)
      .call(method, &b)
  end

  def __method_defined?(method)
    singleton_class.method_defined?(method, false)
  end

  def __method(method)
    Module
      .instance_method(:method)
      .bind(self)
      .call(method)
  end
end

class Object
  extend Proto::ObjectMixin
end
