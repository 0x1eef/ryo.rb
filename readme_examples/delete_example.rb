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
# Using "Proto", delete the "foo"
# property from "obj".
Proto.delete(obj, "foo")

##
# Prints nil
Kernel.p obj.foo
