#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

point = Ryo(x: 10, y: 20)
Ryo.each(point) do |key, value|
  p [key, value]
end

##
# ["x", 10]
# ["y", 20]
