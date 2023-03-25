# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({}, point_b)
p [point_c.x, point_c.y]

##
# [5, 10]
