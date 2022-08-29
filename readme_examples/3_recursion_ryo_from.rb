# frozen_string_literal: true

require_relative "setup"
require "ryo"

vehicles = Ryo.from(bike: {wheels: 2}, car: {wheels: 4})
p vehicles.bike.wheels
p vehicles.car.wheels

##
# 2
# 4
