# frozen_string_literal: true

require_relative "setup"
require "ryo"

point = Ryo::BasicObject.from({
  x: {to_i: 2},
  y: {to_i: 4}
})
p [point.x.to_i, point.y.to_i]

##
# [2, 4]
