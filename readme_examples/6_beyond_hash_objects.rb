require_relative "setup"
require "ryo"

class Point
  def initialize
    @x = 5
    @y = 10
  end

  def each_pair
    yield("x", @x)
    yield("y", @y)
  end
end

option = Ryo(Point.new)
p option.x # => 5
p option.y # => 10
