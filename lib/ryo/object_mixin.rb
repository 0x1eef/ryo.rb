module Ryo::ObjectMixin
  ##
  # @param [Ryo, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [Hash] props
  #  The properties to assign to the
  #  object.
  #
  # @param [Object,BasicObject] klass
  #  The class of the object.
  #  Options are either Object (default) or BasicObject.
  #
  # @private
  def create(prototype, props = {}, klass:)
    ryo = klass.new
    Ryo.assign_prototype!(ryo, prototype)
    Ryo.assign_table!(ryo, {})
    Ryo.extend!(ryo, Ryo)
    props.each { ryo[_1] = _2 }
    ryo
  end

  ##
  # Recursively walks through a Hash, and returns a
  # Ryo object (with no prototype) in its place.
  # This method is intended for those who want to use
  # Ryo as an alternative to OpenStruct.
  #
  # @param [Hash, #to_hash] props
  #  A Hash object.
  #
  # @return [Object<Ryo>, BasicObject<Ryo, Ryo::Tap>]
  #  Returns a Ryo object.
  def from(props)
    props   = props.to_hash
    visited = {}
    props.each do |key, value|
      visited[key] = if Hash === value
                       from(value)
                     elsif Array === value
                       value.map { from(_1) }
                     else
                       value
                     end
    end
    obj = create(nil, visited)
    Object === obj ? obj : Ryo.extend!(obj, Ryo::Tap)
  end
end
