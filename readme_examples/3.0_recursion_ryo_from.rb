# frozen_string_literal: true

require_relative "setup"
require "ryo"

coords = Ryo.from({
  point_x: {x: {int: 0}},
  point_y: {y: {int: 10}}
})
p [coords.point_x.x.int, coords.point_y.y.int]

##
# [0, 10]
