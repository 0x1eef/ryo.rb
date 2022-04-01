module Proto::ObjectMixin
  ##
  # @param [Proto, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [Object,BasicObject] superclass
  #  The superclass of the object.
  #  Options are either Object (default) or BasicObject.
  def create(prototype, props = {}, superclass: Object)
    proto = Class.new(superclass) { include Proto }.new(prototype)
    props.each { proto[_1] = _2 }
    proto
  end
end
