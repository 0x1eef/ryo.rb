# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_a = Ryo::BasicObject(x: 0)
point_b = Ryo::BasicObject({y: 0}, point_a)
point_c = Ryo::BasicObject({}, point_b)
p [point_c.x, point_c.y]

##
# [0, 0]
