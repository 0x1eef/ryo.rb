require_relative "setup"
require "ryo"

class Option
  def initialize
    @name = "option"
    @value = 123
  end

  def each_pair
    yield("name", @name)
    yield("value", @value)
  end
end

option = Ryo(Option.new)
p option.name  # "option"
p option.value # 123
