# frozen_string_literal: true

require_relative "setup"
require "ryo"

coords = Ryo.from({
  point_x: {x: 0},
  point_y: {y: 10}
})
p [coords.point_x.x, coords.point_y.y]

##
# [0, 10]
