require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

fruit = Object.create(nil)
apple = Object.create(fruit)
Ryo.assign(fruit, apple, {sour: true})

Kernel.p fruit.sour # => true
Kernel.p apple.sour # => true
