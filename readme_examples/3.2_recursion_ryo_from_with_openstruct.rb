# frozen_string_literal: true

require_relative "setup"
require "ryo"
require "ostruct"

point = Ryo.from(
  OpenStruct.new(x: {to_i: 5}),
  Ryo.from(y: {to_i: 10})
)
p [point.x.to_i, point.y.to_i]

##
# [5, 10]
