module Ryo::ObjectMixin
  ##
  # @param [Ryo, nil] prototype
  #  The prototype, or nil for none.
  #
  # @param [Object,BasicObject] superclass
  #  The superclass of the object.
  #  Options are either Object (default) or BasicObject.
  def create(prototype, props = {})
    ryo = new
    Ryo.assign_prototype!(ryo, prototype)
    Ryo.assign_table!(ryo, {})
    Ryo.extend_object!(ryo)
    props.each { ryo[_1] = _2 }
    ryo
  end
end
