# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({
  multiply: Ryo.fn { |m| [x * m, y * m] }
}, point_y)
p point.multiply.call(2)

##
# [10, 20]
