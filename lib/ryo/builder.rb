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
  # @param [<Hash, #each_pair>] props
  #  A Hash object, or an object that implements "#each_pair" and yields a key-value pair.
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
    props.each_pair { ryo[_1] = _2 }
    ryo
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object, or an Array of Hash objects.
  #
  # @example
  #   objects = Ryo.from([{x: 0, y: 0}, "foo", {point: {x: 0, y: 0}}])
  #   objects[0].x       # => 0
  #   objects[1]         # => "foo"
  #   objects[2].point.x # => 0
  #
  # @param buildee (see Ryo::Builder.build)
  #
  # @param [<Hash, #each<Hash, #each_pair>, #each_pair>] props
  #   An object that implements "#each_pair", or an array of objects that implement "#each_pair".
  #
  # @param prototype (see Ryo::Builder.build)
  #
  # @return (see Ryo::Builder.build)
  def self.recursive_build(buildee, props, prototype = nil)
    if eachless?(props)
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

  ##
  # @private
  def self.map_value(buildee, value)
    if Ryo.ryo?(value) || eachless?(value)
      value
    elsif value.respond_to?(:each_pair)
      recursive_build(buildee, value)
    elsif value.respond_to?(:each)
      map(value) { map_value(buildee, _1) }
    end
  end
  private_class_method :map_value

  ##
  # @private
  def self.eachless?(value)
    !value.respond_to?(:each) && !value.respond_to?(:each_pair)
  end
  private_class_method :eachless?

  ##
  # @private
  def self.map(obj)
    ary = []
    obj.each { ary.push(yield(_1)) }
    ary
  end
  private_class_method :map
end
