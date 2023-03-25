# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_a = Ryo(x: 2)
point_b = Ryo({y: 4}, point_a)
point_c = Ryo({}, point_b)

Ryo.map!(point) { |key, value| value * 2 }
p [point_c.x, point_c.y]
p [point_a.x, point_b.y]

##
# [4, 8]
# [4, 8]
