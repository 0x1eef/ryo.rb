##
# The {Ryo::Function Ryo::Function} class represents a Ryo
# function. The class is usually not used directly but through
# `Ryo.function { ... }`.
#
# A Ryo function has a special relationship with Ryo objects, where
# when a Ryo function is assigned as a property to a Ryo object,
# its "self" becomes bound to the Ryo object.
class Ryo::Function
  ##
  # @param [Proc] body
  #  The body of the function as a block.
  def initialize(&body)
    @body = body
    @ryo = nil
    @to_proc = nil
  end

  ##
  # @return [Ryo]
  #  The object that the function's "self" is
  #  bound to.
  def receiver
    @ryo
  end
  alias_method :self, :receiver

  ##
  # Change the receiver (self) of the function.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [nil]
  def bind!(ryo)
    @ryo = ryo
    @to_proc = nil
  end

  ##
  # Call the function.
  def call(...)
    to_proc.call(...)
  end

  ##
  # @return [Proc]
  #  Returns the function as a lambda bound
  #  to {#receiver}.
  def to_proc
    @to_proc ||= lambda!(@body)
  end

  private

  def lambda!(body)
    ryo, lambda = @ryo, nil
    Module.new do
      define_method(:__function__, &body)
      lambda = instance_method(:__function__)
               .bind(ryo)
               .to_proc
    end
    lambda
  end
end
