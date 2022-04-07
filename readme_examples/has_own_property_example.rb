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
# Use "Proto" to ask the object if it
# has the property "foo".
Kernel.p Proto.property?(obj, "foo")
