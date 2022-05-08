# frozen_string_literal: true

class Ryo::Object
  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::Object]
  #  Returns an instance of Ryo::Object.
  def self.create(props, prototype = nil)
    Ryo::Builder.build(props, prototype, build_class: self)
  end

  def self.from(props, prototype = nil)
    Ryo::Builder.build_from(props, prototype, build_class: self)
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
