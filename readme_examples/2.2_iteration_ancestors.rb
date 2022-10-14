# frozen_string_literal: true

require_relative "setup"
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({z: 15}, point_b)

p Ryo.find(point_c, ancestors: 0) { |k, v| v == 5 } # => nil
p Ryo.find(point_c, ancestors: 1) { |k, v| v == 5 } # => nil
p Ryo.find(point_c, ancestors: 2) { |k, v| v == 5 } # => point_a
p Ryo.find(point_c) { |k, v| v == 5 } # => point_a
