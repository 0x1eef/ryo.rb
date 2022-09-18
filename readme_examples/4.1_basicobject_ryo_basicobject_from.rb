# frozen_string_literal: true

require_relative "setup"
require "ryo"

coords = Ryo::BasicObject.from({
  point_x: {x: 2},
  point_y: {y: 4}
})
p [coords.point_x.x, coords.point_y.y]

##
# [2, 4]
