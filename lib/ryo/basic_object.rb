# frozen_string_literal: true

class Ryo::BasicObject < BasicObject
  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::BasicObject]
  #  Returns an instance of Ryo::BasicObject.
  def self.create(props, prototype = nil)
    ::Ryo::Builder.build(self, props, prototype)
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object.
  #
  # @param props (see Ryo::Builder.recursive_build)
  # @param prototype (see Ryo::Builder.recursive_build)
  #
  # @return [Ryo::BasicObject]
  #  Returns an instance of {Ryo::BasicObject Ryo::BasicObject}.
  def self.from(props, prototype = nil)
    ::Ryo::Builder.recursive_build(self, props, prototype)
  end
end

##
# @example
#  point = Ryo::BasicObject(x: 0, y: 0)
#  p [point.x, point.y] # => [0, 0]
#
# @param props (see Ryo::Builder.build)
# @param prototype (see Ryo::Builder.build)
#
# @return [Ryo::BasicObject]
#   Returns an instance of {Ryo::BasicObject Ryo::BasicObject}.
def Ryo.BasicObject(props, prototype = nil)
  Ryo::BasicObject.create(props, prototype)
end
