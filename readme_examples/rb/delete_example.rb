require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
obj = Object.create(nil)

##
# Assign the property "foo" the value of
# "42".
obj.foo = 42

##
# Using "Ryo", delete the "foo"
# property from "obj".
Ryo.delete(obj, "foo")

##
# Prints nil
Kernel.p obj.foo
