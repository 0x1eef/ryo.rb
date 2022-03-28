module Proto::ObjectMixin
  ##
  # @param [Proto, nil]
  #  The prototype, or nil for none.
  #
  # @param [Object,BasicObject] superclass
  #  The superclass of the object.
  #  Options are either Object (default) or BasicObject.
  def create(prototype, superclass: Object, &b)
    Class.new(superclass) do
      include Proto
      class_eval(&b) if b
    end.new(prototype)
  end
end
