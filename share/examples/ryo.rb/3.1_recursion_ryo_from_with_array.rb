#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

points = Ryo.from([
  {x: {to_i: 2}},
  "foobar",
  {y: {to_i: 4}}
])

p points[0].x.to_i
p points[1]
p points[2].y.to_i

##
# 2
# "foobar"
# 4
