require_relative "setup"
require "ryo"

point_a = Ryo(x: Ryo.lazy { 5 })
point_b = Ryo({y: Ryo.lazy { 10 }}, point_a)
point = Ryo({sum: Ryo.lazy { x + y }}, point_b)
print "point.x = ", point.x, "\n"
print "point.y = ", point.y, "\n"
print "point.sum = ", point.sum, "\n"

##
# point.x = 5
# point.y = 10
# point.sum = 15
