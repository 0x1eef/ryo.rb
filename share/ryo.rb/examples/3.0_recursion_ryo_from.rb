# frozen_string_literal: true

require_relative "setup"
require "ryo"

point = Ryo.from({
  x: {to_i: 0},
  y: {to_i: 10}
})
p [point.x.to_i, point.y.to_i]

##
# [0, 10]
