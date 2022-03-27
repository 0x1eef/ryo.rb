# frozen_string_literal: true

module Proto
  require_relative "proto/object_mixin"

  def initialize(prototype = nil)
    @proto = prototype
    @table = {}
  end

  ##
  # Returns the prototype of self.
  #
  # @return [Proto]
  def prototype
    @proto
  end

  ##
  # @param [String] key
  #   The key.
  #
  # @return [Object, BasicObject]
  #   The value at *key*, or nil.
  def [](key)
    key = key.to_s
    key?(key) ? @table[key] : (@proto and @proto[key])
  end

  ##
  # Adds a key to self.
  #
  # @param [String] key
  #   The key.
  #
  # @param [Object,BasicObject] value
  #   The value.
  def []=(key, value)
    key = key.to_s
    __add(key, value)
  end

  ##
  # Removes a key from self.
  #
  # @param [String] key
  #  The key to delete.
  #
  # @return [void]
  def delete(key)
    key = key.to_s
    __delete(key)
  end

  ##
  # @param [Hash, #to_h, #to_hash] other
  #
  def ==(other)
    @table == __try_convert_to_hash(other)
  end
  alias_method :eql?, :==

  ##
  # @param [String] key
  #   The key.
  #
  # @return [Boolean]
  #   rReturns true when *key* is a member of self.
  #
  def key?(key)
    key = key.to_s
    @table.key?(key)
  end

  ##
  # Clear all properties in self.
  #
  # @return [void]
  #
  def clear
    @table.clear
    true
  end

  ##
  # @return [Hash]
  #   A shallow copy of the lookup table.
  #
  def to_hash
    @table.dup
  end
  alias_method :to_h, :to_hash

  def method_missing(name, *args, &block)
    key = name.to_s
    if key[-1] == "="
      short_key = key[0..-2]
      self[short_key] = args[0]
    elsif key?(key)
      self[key]
    elsif @proto.respond_to?(name)
      @proto.public_send(name, *args, &block)
    end
  end

  def respond_to_missing?(key, include_all = false)
    key?(key) or @proto.respond_to?(key) or super(key, include_all)
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

  def __add(key, value)
    unless singleton_class.method_defined? key
      define_singleton_method(key) { self[key] }
      define_singleton_method("#{key}=") { |val| @table[key] = val }
    end
    @table[key] = value
  end

  def __delete(key)
    @table.delete(key)
    @proto&.delete(key)
    return unless instance_of?(method(key).owner)
    define_singleton_method(key) { nil }
  rescue NameError
  end
end

class Object
  extend Proto::ObjectMixin
end

obj1 = Object.create(nil) do
  def bar
    42
  end
end

obj2 = Object.create(obj1) do
  def foo
    bar + 42
  end
end
