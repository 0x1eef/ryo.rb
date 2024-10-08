# frozen_string_literal: true

##
# The {Ryo::Builder Ryo::Builder} module is responsible for
# the creation of instances of {Ryo::Object Ryo::Object},
# and {Ryo::BasicObject Ryo::BasicObject}. This module is
# not intended to be used directly.
# @api private
module Ryo::Builder
  ##
  # @note
  #  When "props" is given as a Ryo object, a duplicate Ryo object is
  #  returned in its place
  # @param [<Ryo::Object, Ryo::BasicObject>] buildee
  # @param [<#each_pair>] props
  # @param [<Ryo::Object, Ryo::BasicObject>, nil] prototype
  # @return [<Ryo::Object, Ryo::BasicObject>]
  #  Returns a Ryo object
  def self.build(buildee, props, prototype = nil)
    if Ryo.ryo?(props)
      build(buildee, Ryo.table_of(props), prototype || Ryo.prototype_of(props))
    else
      ryo = buildee.new
      Ryo.set_prototype_of(ryo, prototype)
      Ryo.set_table_of(ryo, {})
      Ryo.extend!(ryo, Ryo)
      props.each_pair { ryo[_1] = _2 }
      ryo
    end
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object, or
  # an Array of Hash objects
  #
  # @example
  #   objects = Ryo.from([{x: 0, y: 0}, "foo", {point: {x: 0, y: 0}}])
  #   objects[0].x       # => 0
  #   objects[1]         # => "foo"
  #   objects[2].point.x # => 0
  #
  # @note (see Ryo::Builder.build)
  # @param (see Ryo::Builder.build)
  # @return (see Ryo::Builder.build)
  def self.recursive_build(buildee, props, prototype = nil)
    if Ryo.ryo?(props)
      recursive_build(buildee, Ryo.table_of(props), prototype || Ryo.prototype_of(props))
    elsif !respond_to_each?(props)
      raise TypeError, "The provided object does not implement #each / #each_pair"
    elsif !props.respond_to?(:each_pair)
      map(props) do
        noop = Ryo.ryo?(_1) || !_1.respond_to?(:each_pair)
        noop ? _1 : recursive_build(buildee, _1)
      end
    else
      visited = {}
      props.each_pair { visited[_1] = map_value(buildee, _2) }
      build(buildee, visited, prototype)
    end
  end

  module Private
    private

    def map_value(buildee, value)
      if Ryo.ryo?(value) || !respond_to_each?(value)
        value
      elsif value.respond_to?(:each_pair)
        recursive_build(buildee, value)
      elsif value.respond_to?(:each)
        map(value) { map_value(buildee, _1) }
      end
    end

    def respond_to_each?(value)
      value.respond_to?(:each) || value.respond_to?(:each_pair)
    end

    def map(obj)
      ary = []
      obj.each { ary.push(yield(_1)) }
      ary
    end
  end
  private_constant :Private
  extend Private
end
