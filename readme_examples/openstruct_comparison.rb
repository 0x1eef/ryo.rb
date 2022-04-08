require "ostruct"
obj = OpenStruct.new
obj.method_missing = nil
##
# Raises an exception:
obj.foo = 1
