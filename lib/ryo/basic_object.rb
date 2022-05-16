# frozen_string_literal: true

class Ryo::BasicObject < BasicObject
  extend ::Ryo::ObjectMixin

  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::BasicObject]
  #  Returns an instance of Ryo::BasicObject.
  def self.create(props, prototype=nil)
    super(props, prototype, klass: BasicObject)
  end
end

##
# @example
#  point = Ryo::BasicObject(x: 0, y: 0)
#
# @param (see #Ryo)
#
# @return [Ryo::BasicObject]
#  returns an instance of {Ryo::BasicObject}
def Ryo::BasicObject(props, prototype=nil)
  Ryo::BasicObject.create(props, prototype)
end
