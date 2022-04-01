require "proto"
require "proto/core_ext/object"

##
# Create a new object, with no prototype.
# On this object, define the property "rating".
fruit = Object.create(nil, {
  eat: lambda { "nomnom" }
})

##
# Create a second object, with "fruit" as
# its prototype. On this object, define
# the property "name".
apple = Object.create(fruit, {name: "Apple"})

##
# Query the property "name", and find a match
# directly on the apple object.
Kernel.p apple.name # => "Apple"

##
# Query the property "eat", and traverse the
# prototype chain until it is found on "fruit".
Kernel.p apple.eat.()
