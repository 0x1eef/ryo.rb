class BasicObject
  extend ::Ryo::ObjectMixin

  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [BasicObject<Ryo>]
  #  Returns an instance of BasicObject, with
  #  the Ryo module extended into it.
  def self.create(prototype, props={})
    super(prototype, props, klass: self)
  end
end
