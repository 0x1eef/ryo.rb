require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the property "wheels".
vehicle = Object.create(nil, {wheels: 4})

##
# Create a second object, with "vehicle" as
# its prototype. On this object, define
# the property "model".
honda = Object.create(vehicle, {model: "Honda"})

##
# Returns true after finding the "wheels"
# property in the prototype chain of "honda".
puts Ryo.in?(honda, "wheels")

##
# Returns true after finding the "model"
# property directly on "honda".
puts Ryo.in?(honda, "model")

##
# Returns false after not finding the "foobar"
# property on "honda", or in its prototype chain.
puts Ryo.in?(honda, "foobar")
