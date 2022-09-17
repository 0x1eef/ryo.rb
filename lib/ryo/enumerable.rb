##
# The {Ryo::Enumerable Ryo::Enumerable} module implements methods
# for iterating through, and performing operations on Ryo objects.
# The methods implemented by this module are available as singleton
# methods on the {Ryo} module.
module Ryo::Enumerable
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
  # A specialized version of map that mutates a Ryo object
  # using a map operation.
  #
  # @example
  #   point = Ryo.from(x: 2, y: 4)
  #   Ryo.map!(point) { _2 * 2 }
  #   ryo.x # => 4
  #   ryo.y # => 8
  #
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #    A Ryo object.
  #
  # @return [<Ryo::Object, Ryo::BasicObject>]
  def map!(ryo, &b)
    each(ryo) do
      if property?(ryo, _1)
        ryo[_1] = yield(_1, _2)
      else
        map!(prototype_of(ryo), &b)
      end
    end
    ryo
  end
end
