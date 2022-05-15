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
  def self.create(props, prototype = nil)
    super(props, prototype, klass: self)
  end
end

##
# @example
#  point = Ryo::Object(x: 0, y: 0)
#
# @param (see #Ryo)
# @return (see #Ryo)
def Ryo.Object(props, prototype = nil)
  Ryo::Object.create(props, prototype)
end
