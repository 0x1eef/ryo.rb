# frozen_string_literal: true

##
# The {Ryo::Enumerable Ryo::Enumerable} module implements methods
# for iterating through, and performing operations on Ryo objects.
# The methods implemented by this module are available as singleton
# methods on the {Ryo} module.
module Ryo::Enumerable
  include Ryo::Keywords
  include Ryo::Reflect

  ##
  # Iterates over a Ryo object, and yields a key-value pair.
  # When a block is not given, an Enumerator is returned.
  #
  # @example
  #  Ryo(foo: 1, bar: 2).each.map { _2 * 2 }
  #  # => [2, 4]
  #
  # @param [Ryo::Object, Ryo::BasicObject] ryo
  #  A Ryo object.
  #
  # @return [<Enumerator, Array>]
  #  Returns an Enumerator when a block is not given,
  #  otherwise returns an Array.
  def each(ryo)
    return enum_for(:each, ryo) unless block_given?
    props = [
      *properties_of(ryo),
      *prototype_chain_of(ryo).flat_map { properties_of(_1) }
    ].uniq
    props.each { yield(_1, ryo[_1]) }
  end

  ##
  # The {#each_ryo} method iterates through a Ryo object, and its prototypes.
  # {#each_ryo} yields three arguments: a Ryo object, a key, and a value.
  #
  # @example
  #  point_a = Ryo(x: 1, y: 2)
  #  point_b = Ryo({y: 3}, point_a)
  #  Ryo.each_ryo(point_b) { |ryo, key, value| p [ryo, key, value] }
  #  # [point_b, "y", 3]
  #  # [point_a, "x", 1]
  #  # [point_a, "y", 2]
  #
  # @param [<Ryo::BasicObject, Ryo::Object>] ryo
  #  A Ryo object.
  #
  # @return [<Ryo::BasicObject, Ryo::Object>]
  def each_ryo(ryo)
    [ryo, *prototype_chain_of(ryo)].each do |ryo|
      properties_of(ryo).each do |key|
        yield(ryo, key, ryo[key])
      end
    end
    ryo
  end

  ##
  # A specialized implementation of map that performs a map operation
  # and returns a *new* Ryo object.
  #
  # @param (see #map!)
  #
  # @return (see #map!)
  def map(ryo, &b)
    map!(Ryo.dup(ryo), &b)
  end

  ##
  # A specialized implementation of map that performs a map operation
  # that mutates a Ryo object.
  #
  # @example
  #   point = Ryo.from(x: 2, y: 4)
  #   Ryo.map!(point) { _2 * 2 }
  #   ryo.x # => 4
  #   ryo.y # => 8
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def map!(ryo)
    proto_chain = [ryo, *prototype_chain_of(ryo)]
    each(ryo) do |key, value|
      ryo = proto_chain.find { |ryo| property?(ryo, key) }
      ryo[key] = yield(key, value)
    end
    ryo
  end

  ##
  # A specialized implementation of select that performs a filter operation
  # and returns a *new* Ryo object.
  #
  # @param (see #select!)
  #
  # @return (see #select!)
  def select(ryo,  &b)
    select!(Ryo.dup(ryo), &b)
  end

  ##
  # A specialized implementation of select that performs a filter operation
  # that mutates a Ryo object.
  #
  # @example
  #  point = Ryo(x: 5, y: 5, z: 10)
  #  point = Ryo({z: 20}, point)
  #  Ryo.select!(point) { |key, value| %w(x y).include?(key) }
  #  [point.x, point.y, point.z] # => [5, 5, nil]
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def select!(ryo)
    each_ryo(ryo) do |ryo, key, value|
      delete(ryo, key) unless yield(key, value)
    end
  end

  ##
  # A specialized implementation of reject that performs a filter operation
  # and returns a *new* Ryo object.
  #
  # @param (see #reject!)
  #
  # @return (see #reject!)
  def reject(ryo, &b)
    reject!(Ryo.dup(ryo), &b)
  end

  ##
  # A specialized implementation of reject that performs a filter operation
  # that mutates a Ryo object.
  #
  # @example
  #  point = Ryo(x: 1, y: 2, z: 10)
  #  point = Ryo({z: 5}, point)
  #  Ryo.reject!(ryo) { |key, value| value > 2 }
  #  [point.x, point.y, point.z] # => [1, 2, nil]
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def reject!(ryo)
    each_ryo(ryo) do |ryo, key, value|
      delete(ryo, key) if yield(key, value)
    end
  end

  ##
  # The {#any?} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a truthy value, {#any?} will
  # break from the iteration and return true - otherwise false will be returned.
  #
  # @return [Boolean]
  def any?(ryo)
    each_ryo(ryo) do |_, key, value|
      return true if yield(key, value)
    end
    false
  end

  ##
  # The {#all?} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a falsey value, {#all?} will
  # break from the iteration and return false - otherwise true will be returned.
  #
  # @return [Boolean]
  def all?(ryo)
    each_ryo(ryo) do |_, key, value|
      return false unless yield(key, value)
    end
    true
  end

  ##
  # The {#find} method iterates through a Ryo object, and its prototypes - yielding a
  # key / value pair to a block. If the block ever returns a truthy value, {#find} will
  # break from the iteration and return a Ryo object - otherwise nil will be returned.
  #
  # @example
  #  point_a = Ryo(x: 5)
  #  point_b = Ryo({y: 10}, point_a)
  #  point_c = Ryo({z: 15}, point_b)
  #  ryo = Ryo.find(point_c) { |key, value| value == 5 }
  #  ryo == point_a # => true
  #
  # @return [<Ryo::Object, Ryo::BasicObject>, nil]
  def find(ryo)
    each_ryo(ryo) do |ryo, key, value|
      return ryo if yield(key, value)
    end
    nil
  end
end
