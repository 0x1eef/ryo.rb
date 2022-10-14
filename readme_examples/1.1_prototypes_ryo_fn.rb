# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({
  inspect: Ryo.fn { |m| [x * m, y * m] }
}, point_b)
p point_c.inspect.call(2)

##
# [10, 20]
