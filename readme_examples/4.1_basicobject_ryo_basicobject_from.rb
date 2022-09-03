# frozen_string_literal: true

require_relative "setup"
require "ryo"

vehicles = Ryo::BasicObject.from(bike: {wheels: 2}, car: {wheels: 4})
p [vehicles.bike.wheels, vehicles.car.wheels]

##
# [2, 4]
