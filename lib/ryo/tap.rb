##
# The {Ryo::Tap Ryo::Tap} module extends Ryo objects
# created by {BasicObject.from BasicObject.from} with
# a `tap` method, which is required by the implementation
# of {BasicObject.from BasicObject.from}.
module Ryo::Tap
  def tap(&b)
    ::Kernel
      .instance_method(:tap)
      .bind_call(self, &b)
  end
end
