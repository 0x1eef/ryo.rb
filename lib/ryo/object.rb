# frozen_string_literal: true

class Ryo::Object
  extend Ryo::ObjectMixin

  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Object<Ryo>]
  #  Returns an instance of Object - extended by
  #  the Ryo module.
  def self.create(prototype, props = {})
    super(prototype, props, klass: self)
  end
end
