require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
ryo = Object.create(nil, {foo: "foo"})

##
# Create a second object, with the "ryo" object as
# its prototype.
ryo2 = Object.create(ryo, {bar: "bar"})

##
# Returns false
Kernel.p Ryo.property?(ryo2, "foo")

##
# Returns true
Kernel.p Ryo.property?(ryo2, "bar")
