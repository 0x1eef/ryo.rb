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
  # @param [<Hash, #to_h>] props
  #  A Hash object, or an object that can be coerced into a Hash object.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] build
  #  The class of the object to build.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a Ryo object.
  def self.build(props, prototype = nil, build:)
    ryo = build.new
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
  def self.build_from(props, prototype = nil, build:)
    props = Hash.try_convert(props)
    if props.nil?
      raise TypeError, "The provided object can't be coerced into a Hash"
    end
    visited = {}
    props.each do |key, value|
      visited[key] = if Hash === value
        build_from(value, build: build)
      elsif Array === value
        value.map { build_from(_1, build: build) }
      else
        value
      end
    end
    obj = build(visited, prototype, build: build)
    Object === obj ? obj : Ryo.extend!(obj, Ryo::Tap)
  end
end
