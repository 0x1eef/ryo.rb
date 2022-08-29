# frozen_string_literal: true

require_relative "setup"
require "ryo"

car = Ryo(name: "ford", year: 1922)
p Ryo.each(car).map { _1 == "name" ? "telsa" : 2022 }

##
# ['telsa', 2022]
