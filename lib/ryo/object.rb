# frozen_string_literal: true

##
# {Ryo::Object Ryo::Object} is a Ryo object and subclass of
# Ruby's Object class that can be created by using
# [Ryo()](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method),
# {Ryo.Object Ryo.Object()}, {Ryo::Object.from Ryo::Object.from},
# or {Ryo::Object.create Ryo::Object.create}.
class Ryo::Object
  ##
  # @param props (see Ryo::Builder.build)
  # @param prototype (see Ryo::Builder.build)
  # @return [Ryo::Object]
  #  Returns an instance of {Ryo::Object Ryo::Object}
  def self.create(props, prototype = nil)
    Ryo::Builder.build(self, props, prototype)
  end

  ##
  # Creates a Ryo object by recursively walking a Hash object
  #
  # @param props (see Ryo::Builder.recursive_build)
  # @param prototype (see Ryo::Builder.recursive_build)
  # @return [Ryo::Object]
  #  Returns an instance of {Ryo::Object Ryo::Object}.
  def self.from(props, prototype = nil)
    Ryo::Builder.recursive_build(self, props, prototype)
  end

  ##
  # Duplicates the internals of a Ryo object
  #
  # @param [Ryo::Object] ryo
  #  A Ryo object
  # @return [Ryo::Object]
  #  Returns a Ryo object
  def initialize_dup(ryo)
    Ryo.set_table_of(self, Ryo.table_of(ryo).dup)
    Ryo.extend!(self, Ryo)
  end
end

##
# @example
#  point = Ryo::Object(x: 0, y: 0)
#  p [point.x, point.y] # => [0, 0]
#
# @param props (see Ryo::Builder.build)
# @param prototype (see Ryo::Builder.build)
# @return [Ryo::Object]
#   Returns an instance of {Ryo::Object Ryo::Object}
def Ryo.Object(props, prototype = nil)
  Ryo::Object.create(props, prototype)
end
