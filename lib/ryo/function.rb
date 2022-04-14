##
# The {Ryo::Function} class represents a Ryo function.
# Usually it is not used directly but through {Ryo.function},
# or {Ryo.fn} (an alias).
class Ryo::Function
  ##
  # @param [Proc] body
  #  The body of the function as a block.
  def initialize(&body)
    @body = body
    @ryo = nil
  end

  ##
  # @return [Ryo]
  #  The object that the function's "self" is
  #  bound to.
  def receiver
    @ryo
  end

  ##
  # Change the receiver (self) of the function.
  #
  # @param [Ryo] ryo
  #  A Ryo object.
  #
  # @return [void]
  def bind!(ryo)
    @ryo = ryo
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
    lambda!(@body)
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
