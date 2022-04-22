##
# The {Ryo::Keywords Ryo::Keywords} module implements Ryo equivalent's
# to some of JavaScript's keywords - for example, the `in` and `delete`
# operators. This module's instance methods are available as singleton
# methods on the {Ryo} module.
module Ryo::Keywords
  extend self

  ##
  # @example
  #   person = Object.create(nil, {greet: Ry.fn { puts "Hello #{name}" }})
  #   tim = Object.create(person, {name: "Tim"})
  #   tim.greet.()
  #
  # @param [Proc] b
  #  The function's body.
  #
  # @return [Ryo::Function]
  #  Returns a Ryo function that is bound to the
  #  self of the Ryo object it is assigned to.
  def function(&b)
    Ryo::Function.new(&b)
  end
  alias_method :fn, :function

  # Equivalent to JavaScript's "in" operator.
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The property.
  #
  # @return [Boolean]
  #  Returns true when *property* is a member of *ryo*,
  #  or its prototype chain.
  def in?(ryo, property)
    Ryo::Reflect.property?(ryo, property) ||
    Ryo::Reflect.property?(Ryo::Reflect.prototype_of(ryo), property)
  end

  ##
  # Equivalent to JavaScript's "delete" operator.
  #
  # @param [Ryo] ryo
  #  An object who has included the Ryo
  #  module.
  #
  # @param [String] property
  #  The property to delete.
  #
  # @return [void]
  def delete(ryo, property)
    property = property.to_s
    if Ryo::Reflect.property?(ryo, property)
      Ryo::Reflect.unbox_table(ryo).delete(property)
    else
      return if Ryo::Reflect.getter_defined?(ryo, property)
      Ryo::Reflect.define_method!(ryo, property) { ryo[property] }
    end
  end
end
