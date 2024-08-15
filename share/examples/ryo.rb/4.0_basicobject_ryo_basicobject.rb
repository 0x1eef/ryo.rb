#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo::BasicObject(x: 0)
point_y = Ryo::BasicObject({y: 0}, point_x)
point = Ryo::BasicObject({}, point_y)
p [point.x, point.y]

##
# [0, 0]
