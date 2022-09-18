# frozen_string_literal: true

require_relative "setup"
require "ryo"

coords = Ryo::BasicObject.from({
  point_x: {x: {int: 2}},
  point_y: {y: {int: 4}}
})
p [coords.point_x.x.int, coords.point_y.y.int]

##
# [2, 4]
