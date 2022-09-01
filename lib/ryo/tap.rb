# frozen_string_literal: true

##
# The {Ryo::Tap Ryo::Tap} module extends Ryo objects
# created by {BasicObject.from BasicObject.from} with
# a `tap` method that is not available on BasicObject
# by default.
module Ryo::Tap
  def tap(&b)
    ::Kernel
      .instance_method(:tap)
      .bind_call(self, &b)
  end
end
