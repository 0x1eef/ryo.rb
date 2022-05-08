# frozen_string_literal: true

module Ryo::Builder
  ##
  # @param [Ryo, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [Hash] props
  #  The properties to assign to the object.
  #
  # @param [Ryo::Object, Ryo::BasicObject] build_class
  #  The class of the object.
  #
  # @private
  def self.build(props, prototype = nil, build_class:)
    ryo = build_class.new
    Ryo.set_prototype_of(ryo, prototype)
    Ryo.set_table_of(ryo, {})
    Ryo.extend!(ryo, Ryo)
    props.each { ryo[_1] = _2 }
    ryo
  end

  ##
  # Recursively walks through a Hash, and returns a
  # Ryo object in its place.
  #
  # @example
  #  ryo = Ryo::BasicObject.from({foo: {bar: 42}})
  #  ryo.foo.bar # => 42
  #
  # @param [Hash, #to_hash] props
  #  A Hash object.
  #
  # @return [Ryo::Object, Ryo::BasicObject]
  #  Returns a Ryo object.
  def self.build_from(props, prototype = nil, build_class:)
    props = Hash.try_convert(props)
    if props.nil?
      raise TypeError, "The provided object can't be coerced into a Hash"
    end
    visited = {}
    props.each do |key, value|
      visited[key] = if Hash === value
        build_from(value, build_class: build_class)
      elsif Array === value
        value.map { build_from(_1, build_class: build_class) }
      else
        value
      end
    end
    obj = build(visited, prototype, build_class: build_class)
    Object === obj ? obj : Ryo.extend!(obj, Ryo::Tap)
  end
end
