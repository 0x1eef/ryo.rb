# ryo.rb

ryo.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is inspired by JavaScript's implementation,
in particular Ryo ports JavaScript's [`Object.create`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create).

## Compared to..

**1. Compared to JavaScript's "Object"**

Ryo is inspired by JavaScript - it is the point of reference
a lot of the time, especially in regards to using prototypes for
inheritance. There are Ryo equivalent's to JavaScript - for example,
in JavaScript `Object.create(null)` is equivalent to `Object.create(nil)`
in Ryo.

The [Ryo::Reflect module](https://0x1eef.github.io/docs/ryo.rb/Ryo/Reflect.html) implements numerous other JavaScript
equivalents, and it is based upon JavaScript's
[`Reflect` object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect).
Similar to the Reflect object and some of the static methods on Object, Ryo separates the behavior it provides from the objects it creates.

**2. Compared to OpenStruct**

**TODO**

## Examples

**Introduction**

The examples use `Object.create` - a monkeypatch that is opt-in
by requiring `ryo/core_ext/object`. if they didn't, they could use
`Ryo::Object.create` instead. Both of those mentioned methods return
instances of Ruby's Object class, with some inherited behavior to make
them Ryo objects.

Ryo objects can also be instances of BasicObject, either by using the
opt-in monkeypatch `BasicObject.create` (`ryo/core_ext/basic_object`) or
by using `Ryo::BasicObject.create`.

**1. Prototypes**

This example illustrates how prototype-based inheritance works in
Ryo. It is a long example with each step documented. The
JavaScript equivalent to this example can be found at
[readme_examples/js/1_prototypes.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/1_prototypes.js).

Early in the example you will come across, `Ryo.fn` - which can also be
written as `Ryo.function`. It returns an object that is similar to a lambda,
with a key difference: its self is bound to the object it is assigned to. This
provides equivalent JavaScript behavior.

At the end of the example you will come across `Ryo.delete(matz, "language")`,
it is equivalent to JavaScript's [`delete` operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/delete).


```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the properties "planet",
# and "greet".
person = Object.create(nil, {
  planet: "Earth",
  greet: Ryo.fn {
    greeting = "#{name} asks: have you tried #{language}? " \
               "It is popular on my home planet, #{planet}."
    puts greeting
  }
})

##
# Create a second object, with "person" as
# its prototype. On this object, define
# the properties "name", and "language".
larry = Object.create(person, {name: "Larry Wall", language: "Perl"})

##
# Find matches directly on the larry object.
larry.name     # => "Larry Wall"
larry.language # => "Perl"

##
# Find matches in the prototype chain.
larry.planet   # => "Earth"
larry.greet.() # => "Larry Wall asks: have you tried Perl? ..."

##
# Create a third object, with "larry" as its
# prototype. On this object, define the properties
# "name" and "language".
matz = Object.create(larry, {name: "Yukihiro Matsumoto", language: "Ruby"})

##
# Find matches directly on the matz object.
matz.name     # => "Yukihiro Matsumoto"
matz.language # => "Ruby"

##
# Find matches in the prototype chain.
matz.planet   # => "Earth"
matz.greet.() # => "Yukihiro Matsumoto asks: have you tried Ruby? ..."

##
# Delete the "language" property from matz,
# and find it on the larry prototype instead.
Ryo.delete(matz, "language")
matz.greet.() # => "Yukihiro Matsumoto asks: have you tried Perl? ..."
```

**2. Equivalent to JavaScript's `Object.assign`**

`Ryo.assign` is Ryo's equivalent to [`Object.assign`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign).
`Ryo.assign` can be used in place of the second argument to `Object.create`,
for example - one could write something like what follows below. The javascript
equivalent to this example can be found at
[readme_examples/js/2_object.assign.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/2_object.assign.js).

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with
# no prototype.
fruit = Object.create(nil)

##
# Merge {sour:true} into "fruit".
Ryo.assign(fruit, {sour: true})

puts fruit.sour # => true
```

It's possible to merge as many objects as you want,
from right to left, and they can be a mix of Ryo objects
and Hash objects. The javascript equivalent
to this example can be found at
[readme_examples/js/2_1.object.assign.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/2_1.object.assign.js).

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with
# no prototype.
fruit = Object.create(nil)

##
# Create another object, with "fruit"
# as its prototype.
pineapple = Object.create(fruit)

##
# Merge {sour: true} into "pineapple", and then
# merge "pineapple" into "fruit".
Ryo.assign(fruit, pineapple, {sour: true})

puts fruit.sour # => true
puts pineapple.sour # => true

```

**3. Equivalent to JavaScript's `in` operator**

JavaScript's [`in` operator]() can check for property membership
in an object and in its prototype chain. If the property is found
on neither of those, `false` is returned. Ryo's equivalent to this
is the `Ryo.in?` method. The javascript equivalent
to this example can be found at [https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/3_in.operator.js](/readme_examples/js/3_in.operator.js).


```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the property "wheels".
vehicle = Object.create(nil, {wheels: 4})

##
# Create a second object, with "vehicle" as
# its prototype. On this object, define
# the property "model".
honda = Object.create(vehicle, {model: "Honda"})

##
# Returns true after finding the "wheels"
# property in the prototype chain of "honda".
puts Ryo.in?(honda, "wheels")

##
# Returns true after finding the "model"
# property directly on "honda".
puts Ryo.in?(honda, "model")

##
# Returns false after not finding the "foobar"
# property on "honda", or in its prototype chain.
puts Ryo.in?(honda, "foobar")
```

**4. Equivalent to JavaScript's `Object.hasOwn`, `Object.prototype.hasOwnProperty`**

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
obj = Object.create(nil)

##
# Assign the property "foo" the value of
# "42".
obj.foo = 42

##
# Use "Ryo" to ask the object if it
# has the property "foo".
Kernel.p Ryo.property?(obj, "foo")
```

## LICENSE

This project uses the MIT license, see [/LICENSE.txt](/LICENSE.txt) for details.
