require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

obj = Object.create(nil)
obj.method_missing = 1
obj.foo = 2

##
# Prints 1
Kernel.p obj.method_missing

##
# Prints 2
Kernel.p obj.foo
