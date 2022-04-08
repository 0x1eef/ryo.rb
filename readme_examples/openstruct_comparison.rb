require "ostruct"
obj = OpenStruct.new
obj.method_missing = 1

##
# Raises an exception:
obj.foo = 1
