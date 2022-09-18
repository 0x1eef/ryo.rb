# frozen_string_literal: true

require_relative "setup"
require "ryo"
require "ostruct"

point = Ryo.from(
  OpenStruct.new(x: {int: 5}),
  Ryo.from(y: {int: 10})
)

p [point.x.int, point.y.int]

##
# [5, 10]
