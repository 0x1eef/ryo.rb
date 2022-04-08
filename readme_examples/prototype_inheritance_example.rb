require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object,  define the properties "sour" and
# "eat".
fruit = Object.create(nil, {
  sour: false,
  eat: lambda { |fruit| "Eating a #{fruit.name}" },
})

##
# Create a second object, with "fruit" as
# its prototype. On this object, define
# the properties "name" and "color"
apple = Object.create(fruit, {name: "Apple", color: "green"})

##
# Find matches directly on the apple object.
Kernel.p apple.name # => "Apple"
Kernel.p apple.color # => "Apple"

##
# Find matches in the prototype chain.
Kernel.p apple.sour # => false
Kernel.p apple.eat.(apple) # => "Eating a Apple"

##
# Create a third object, with "apple" as its
# prototype. On this object, define the properties
# "name" and "sour".
sour_apple = Object.create(apple, {name: "Sour Apple", sour: true})

##
# Find matches directly on the sour_apple object.
Kernel.p sour_apple.name # => "Sour Apple"
Kernel.p sour_apple.sour # => true

##
# Find matches in the prototype chain.
Kernel.p sour_apple.color # => "green"
Kernel.p sour_apple.eat.(sour_apple) # => "Eating a Sour Apple"
