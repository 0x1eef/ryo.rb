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
    proto_chain = [ryo, *Ryo.prototype_chain_of(ryo)]
    each(ryo) do |key, value|
      ryo = proto_chain.find { |ryo| Ryo.property?(ryo, key) }
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
  # @private
  def each_ryo(ryo)
    [ryo, *prototype_chain_of(ryo)].each do |ryo|
      properties_of(ryo).each do |key|
        yield(ryo, key, ryo[key])
      end
    end
    ryo
  end
end
