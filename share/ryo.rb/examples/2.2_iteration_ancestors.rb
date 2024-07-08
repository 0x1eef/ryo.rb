#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)

p Ryo.find(point, ancestors: 0) { |k,v| v == 5 }   # => nil
p Ryo.find(point, ancestors: 1) { |k,v| v == 5 }   # => nil
p Ryo.find(point, ancestors: 2) { |k,v| v == 5 }.x # => point_x.x
p Ryo.find(point) { |k,v| v == 5 }.x # => point_x.x
