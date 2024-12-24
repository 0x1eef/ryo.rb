#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"
require "ostruct"

point = Ryo.from(
  OpenStruct.new(x: 5, y: 10)
)
p [point.x, point.y]

##
# [5, 10]
