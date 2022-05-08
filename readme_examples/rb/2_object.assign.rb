require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
fruit = Object.create(nil)

##
# Create an instance of Object, with "fruit" as its
# prototype.
pineapple = Object.create(fruit)

##
# Merge {delicious:true} into {sweet: true},
# then merge the result of that merge into
# pineapple, finally merge pineapple into fruit.
Ryo.assign(fruit, pineapple, {sweet: true}, {delicious: true})

##
# Prints true (x2)
puts fruit.sweet
puts fruit.delicious

##
# Prints true (x2)
puts pineapple.sweet
puts pineapple.delicious
