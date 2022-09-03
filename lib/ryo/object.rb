# frozen_string_literal: true

class Ryo::Object
  ##
  # @param prototype (see Ryo::ObjectMixin#create)
  # @param props (see Ryo::ObjectMixin#create)
  #
  # @return [Ryo::Object]
  #  Returns an instance of Ryo::Object.
  def self.create(props, prototype = nil)
    Ryo::Builder.build(self, props, prototype)
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object.
  #
  # @param props (see Ryo::Builder#recursive_build)
  # @param prototype (see Ryo::Builder#resursive_build)
  #
  # @return [Ryo::Object]
  #  Returns an instance of {Ryo::Object Ryo::Object}.
  def self.from(props, prototype = nil)
    Ryo::Builder.recursive_build(self, props, prototype)
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
