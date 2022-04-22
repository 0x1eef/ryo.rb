class Ryo::BasicObject < BasicObject
  extend ::Ryo::ObjectMixin

  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [BasicObject<Ryo>]
  #  Returns an instance of BasicObject - extended by
  #  the Ryo module.
  def self.create(prototype, props = {})
    super(prototype, props, klass: BasicObject)
  end
end
