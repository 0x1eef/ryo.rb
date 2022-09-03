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
  # @param [<Hash, #to_h>] props
  #  A Hash object, or an object that can be coerced into a Hash object.
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
  # Recursively walks a Hash object, and then returns a Ryo object.
  #
  # @param (see Ryo::Builder.build)
  # @return (see Ryo::Builder.build)
  def self.recursive_build(buildee, props, prototype = nil)
    props = Hash.try_convert(props)
    if props.nil?
      raise TypeError, "The provided object can't be coerced into a Hash"
    end
    visited = {}
    props.each do |key, value|
      visited[key] = if Hash === value
        recursive_build(buildee, value)
      elsif Array === value
        value.map { recursive_build(buildee, _1) }
      else
        value
      end
    end
    obj = build(buildee, visited, prototype)
    Object === obj ? obj : Ryo.extend!(obj, Ryo::Tap)
  end
end
