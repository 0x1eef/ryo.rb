module Ryo::ObjectMixin
  ##
  # @param [Ryo, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [Object,BasicObject] superclass
  #  The superclass of the object.
  #  Options are either Object (default) or BasicObject.
  def create(prototype, props = {}, superclass: Object)
    ryo = Class.new(superclass) { include Ryo }.new(prototype)
    props.each { ryo[_1] = _2 }
    ryo
  end
end
