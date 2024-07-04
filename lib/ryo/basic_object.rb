# frozen_string_literal: true

##
# {Ryo::BasicObject Ryo::BasicObject} is a Ryo object and subclass
# of Ruby's BasicObject class that can be created by using
# {Ryo.BasicObject Ryo.BasicObject()},
# {Ryo::BasicObject.from Ryo::BasicObject.from}, or
# {Ryo::BasicObject.create Ryo::BasicObject.create}.
class Ryo::BasicObject < BasicObject
  ##
  # @param props (see Ryo::Builder.build)
  # @param prototype (see Ryo::Builder.build)
  # @return [Ryo::BasicObject]
  #  Returns an instance of {Ryo::BasicObject Ryo::BasicObject}
  def self.create(props, prototype = nil)
    ::Ryo::Builder.build(self, props, prototype)
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object
  #
  # @param props (see Ryo::Builder.recursive_build)
  # @param prototype (see Ryo::Builder.recursive_build)
  # @return [Ryo::BasicObject]
  #  Returns an instance of {Ryo::BasicObject Ryo::BasicObject}
  def self.from(props, prototype = nil)
    ::Ryo::Builder.recursive_build(self, props, prototype)
  end

  ##
  # Duplicates the internals of a Ryo object
  #
  # @param [Ryo::BasicObject] ryo
  #  A Ryo object
  # @return [Ryo::BasicObject]
  #  Returns a Ryo object
  def initialize_dup(ryo)
    ::Ryo.set_table_of(self, ::Ryo.table_of(ryo).dup)
    ::Ryo.extend!(self, ::Ryo)
  end
end

##
# @example
#  point = Ryo::BasicObject(x: 0, y: 0)
#  p [point.x, point.y] # => [0, 0]
#
# @param props (see Ryo::Builder.build)
# @param prototype (see Ryo::Builder.build)
# @return [Ryo::BasicObject]
#   Returns an instance of {Ryo::BasicObject Ryo::BasicObject}
def Ryo.BasicObject(props, prototype = nil)
  Ryo::BasicObject.create(props, prototype)
end
