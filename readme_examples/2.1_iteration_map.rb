# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo(x: 2)
point_y = Ryo({y: 4}, point_x)
point = Ryo({}, point_y)

Ryo.map!(point) { |key, value| value * 2 }
p [point.x, point.y]
p [point_x.x, point_y.y]

##
# [4, 8]
# [4, 8]
