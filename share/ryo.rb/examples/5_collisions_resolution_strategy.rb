#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
require "ryo"

ryo = Ryo::Object(then: 12)
p ryo.then # => 12
p ryo.then { 34 } # => 34
