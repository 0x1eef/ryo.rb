class Object
  extend Ryo::ObjectMixin

  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Object<Ryo>]
  #  Returns an instance of Object, with
  #  the Ryo module extended into it.
  def self.create(prototype, props = {})
    super(prototype, props, klass: self)
  end
end
