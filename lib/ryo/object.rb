# frozen_string_literal: true

class Ryo::Object
  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::Object]
  #  Returns an instance of Ryo::Object.
  def self.create(props, prototype = nil)
    Ryo::Builder.build(props, prototype, build: self)
  end

  def self.from(props, prototype = nil)
    Ryo::Builder.build_from(props, prototype, build: self)
  end
end

##
# @example
#  point = Ryo::Object(x: 0, y: 0)
#  p [point.x, point.y] # => [0, 0]
#
# @param props (see Ryo::Builder.build)
# @param prototype (see Ryo::Builder.build)
#
# @return [Ryo::Object]
#   Returns an instance of {Ryo::Object Ryo::Object}.
def Ryo.Object(props, prototype = nil)
  Ryo::Object.create(props, prototype)
end
