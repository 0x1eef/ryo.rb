# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo(x: 0)
point_y = Ryo({y: 0}, point_x)
point = Ryo({}, point_y)

p [point.x, point.y]

##
# [0, 0]
