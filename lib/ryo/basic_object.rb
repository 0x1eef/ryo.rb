# frozen_string_literal: true

class Ryo::BasicObject < BasicObject
  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::BasicObject]
  #  Returns an instance of Ryo::BasicObject.
  def self.create(props, prototype = nil)
    ::Ryo::Builder.build(props, prototype, build_class: self)
  end

  def self.from(props, prototype = nil)
    ::Ryo::Builder.build_from(props, prototype, build_class: self)
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
def Ryo.BasicObject(props, prototype = nil)
  Ryo::BasicObject.create(props, prototype)
end
