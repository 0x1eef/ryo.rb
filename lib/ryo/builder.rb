# frozen_string_literal: true

##
# {Ryo::Builder Ryo::Builder} is a module that's used underneath Ryo's public
# interface when creating instances of {Ryo::Object Ryo::Object}, and
# {Ryo::BasicObject Ryo::BasicObject}. This module is not intended to be
# used directly.
#
# @api private
module Ryo::Builder
  ##
  # @param [<Ryo::Object, Ryo::BasicObject>] buildee
  #  The class of the object to build.
  #
  # @param [<Hash, #each>] props
  #  A Hash object, or an object that implements "#each" and yields a key-value pair.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>, nil] prototype
  #  The prototype, or nil for none.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a Ryo object.
  def self.build(buildee, props, prototype = nil)
    ryo = buildee.new
    Ryo.set_prototype_of(ryo, prototype)
    Ryo.set_table_of(ryo, {})
    Ryo.extend!(ryo, Ryo)
    props.each { ryo[_1] = _2 }
    ryo
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object.
  #
  # @example
  #   objects = Ryo.from([{x: 0, y: 0}, "foo", {point: {x: 0, y: 0}}])
  #   objects[0].x       # => 0
  #   objects[1]         # => "foo"
  #   objects[2].point.x # => 0
  #
  # @param buildee (see Ryo::Builder.build)
  #
  # @param [<Hash, Array<#each_key>, #each_key>] props
  #   A Hash object, or an object that implements "#each_key", or an array of objects that
  #   implement "#each_key".
  #
  # @param prototype (see Ryo::Builder.build)
  #
  # @return (see Ryo::Builder.build)
  def self.recursive_build(buildee, props, prototype = nil)
    if !props.respond_to?(:each) && !props.respond_to?(:each_key)
      raise TypeError, "The provided object does not implement #each / #each_key"
    elsif !props.respond_to?(:each_key)
      arr = []
      props.each do
        el = _1.respond_to?(:each_key) ? recursive_build(buildee, _1, prototype) : _1
        arr.push(el)
      end
      arr
    else
      recursive_build!(buildee, props, prototype)
    end
  end

  ##
  # @api private
  def self.recursive_build!(buildee, props, prototype)
    visited = {}
    props.each do |key, value|
      visited[key] = if value.respond_to?(:each_key)
        recursive_build(buildee, value)
      elsif value.respond_to?(:each)
        value.map { recursive_build(buildee, _1) }
      else
        value
      end
    end
    obj = build(buildee, visited, prototype)
    Object === obj ? obj : Ryo.extend!(obj, Ryo::Tap)
  end
  private_class_method :recursive_build!
end
