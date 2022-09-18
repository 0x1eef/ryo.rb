# frozen_string_literal: true

require_relative "setup"
require "ryo"

coords = Ryo.from([
  {point_x: {x: {int: 2}}},
  "foobar",
  {point_y: {y: {int: 4}}}
])

p coords[0].point_x.x.int
p coords[1]
p coords[2].point_y.y.int

##
# 2
# "foobar"
# 4
