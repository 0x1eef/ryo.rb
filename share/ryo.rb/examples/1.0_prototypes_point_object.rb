#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)
p [point.x, point.y]

##
# [5, 10]
