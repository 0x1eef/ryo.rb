# frozen_string_literal: true

require_relative "setup"
require "ryo"

x_point = Ryo::BasicObject(x: 0)
y_point = Ryo::BasicObject({y: 0}, x_point)
point = Ryo::BasicObject({}, y_point)
p [point.x, point.y]

##
# [0, 0]
