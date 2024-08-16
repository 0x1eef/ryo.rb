# frozen_string_literal: true

##
# The {Ryo::Keywords Ryo::Keywords} module implements Ryo equivalents
# for some of JavaScript's keywords (eg: the **in** and **delete** operators).
# The instance methods of this module are available as singleton
# methods on the {Ryo} module.
module Ryo::Keywords
  ##
  # @example
  #   point = Ryo(x: 0, y: 0, print: Ryo.fn { print x, y, "\n" })
  #   point.print.()
  #
  # @param [Proc] b
  #  The function's body.
  #
  # @return [Ryo::Function]
  #  Returns a Ryo function.
  #
  # @see Ryo::Function Ryo::Function
  def fn(&b)
    Ryo::Function.new(&b)
  end
  alias_method :function, :fn

  ##
  # Equivalent to JavaScript's **in** operator
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  A property name
  # @return [Boolean]
  #  Returns true when **property** is a member of **ryo**, or its prototype chain
  def in?(ryo, property)
    return false unless ryo
    property?(ryo, property) || in?(prototype_of(ryo), property)
  end

  ##
  # The {#delete} method deletes a property from a Ryo object
  # @see Ryo::Reflect#delete!
  # @param [<Ryo::Object, Ryo::BasicObject>] ryo
  #  A Ryo object
  # @param [<String, #to_s>] property
  #  A property name
  # @param [Integer] ancestors
  #  The number of prototypes to traverse.
  #  Defaults to the entire prototype chain.
  # @return [void]
  def delete(ryo, property, ancestors: nil)
    each_ryo(ryo, ancestors:) do
      Ryo.property?(_1, property) ? table_of(_1).delete(property) : nil
    end
  end
end
