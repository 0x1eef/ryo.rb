require_relative "setup"
require "ryo"

vehicles = Ryo.from([
  {wheels: {quantity: 2}},
  "foobar",
  {wheels: {quantity: 4}}
])

p vehicles[0].wheels.quantity
p vehicles[1]
p vehicles[2].wheels.quantity

##
# 2
# "foobar"
# 4
