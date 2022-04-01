require "proto"
require "proto/core_ext/object"

##
# Create a new object, with no prototype.
obj = Object.create(nil)

##
# Assign the property "foo" the value of
# "42".
obj.foo = 42

##
# Use "Proto.brain" to ask the object if it
# has the property "foo".
Kernel.p Proto.brain.property?(obj, "foo")
