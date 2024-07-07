# frozen_string_literal: true

##
# The {Ryo::Utils Ryo::Utils} module provides utility
# methods that are internal to Ryo. This module
# and its methods should not be used directly.
# @api private
module Ryo::Utils
  private

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, Symbol>] method
  #  The name of a method
  # @param [Proc] b
  #  The method's implementation
  def define_method!(ryo, method, &b)
    kernel(:define_singleton_method)
      .bind_call(ryo, method, &b)
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  The name of a property
  # @return [Boolean]
  #  Returns true for a Ryo property that has a
  #  corresponding getter method implemented by Ryo
  def getter_defined?(ryo, property)
    path = kernel(:method)
      .bind_call(ryo, property)
      .source_location
      &.dig(0)
    path ? File.dirname(path) == File.dirname(__FILE__) : false
  end

  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  The name of a property
  # @return [Boolean]
  #  Returns true for a Ryo property that has a
  #  corresponding setter method implemented by Ryo
  def setter_defined?(ryo, property)
    getter_defined?(ryo, "#{property}=")
  end

  def merge!(obj1, obj2)
    obj1, obj2 = to_hash(obj1), to_hash(obj2)
    obj2.each { obj1[_1.to_s] = _2 }
    obj1
  end

  def to_hash(obj)
    if ryo?(obj)
      table_of(obj)
    else
      Hash.try_convert(obj)
    end
  end

  def kernel(name)
    Module.instance_method(name)
  end
end
