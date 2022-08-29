# frozen_string_literal: true

require_relative "setup"
require "ryo"

car = Ryo(name: "ford", year: 1922)
Ryo.each(car) do |key, value|
  p [key, value]
end

##
# ['name', 'ford']
# ['year', 1922]
