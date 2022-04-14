require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with
# no prototype.
fruit = Object.create(nil)

##
# Create another object, with "fruit"
# as its prototype.
pineapple = Object.create(fruit)

##
# Merge {sour: true} into "pineapple", and then
# merge "pineapple" into "fruit".
Ryo.assign(fruit, pineapple, {sour: true})

puts fruit.sour # => true
puts pineapple.sour # => true
