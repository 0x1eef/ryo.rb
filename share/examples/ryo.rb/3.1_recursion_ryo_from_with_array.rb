#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

points = Ryo.from([
  {x: 2},
  "foobar",
  {y: 4}
])

p points[0].x
p points[1]
p points[2].y

##
# 2
# "foobar"
# 4
