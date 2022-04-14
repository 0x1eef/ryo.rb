require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with
# no prototype.
fruit = Object.create(nil)

##
# Merge {sour:true} into "fruit".
Ryo.assign(fruit, {sour: true})

puts fruit.sour # => true
