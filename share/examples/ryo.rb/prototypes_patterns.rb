#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)

case point
in {x: 5}
  print "point.x = 5", "\n"
else
  print "no match!", "\n"
end

##
# point.x = 5
