# ryo.rb

ryo.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is heavily inspired by JavaScript's implementation, 
in particular Ryo ports JavaScript's [`Object.create`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create).
The objects returned by Ryo's `Object.create` are similar to instances 
of Object from JavaScript, or OpenStruct from Ruby. 

## Comparisons

**1. Compared to JavaScript's "Object"**

Ryo is heavily inspired by JavaScript - it is the point of reference
a lot of the time, including in regards to using prototypes for 
inheritance. There are Ryo equivalent's to JavaScript - for example, 
in JavaScript `Object.create(null)` is equivalent to `Object.create(nil)` 
in Ryo. 

**2. Compared to OpenStruct**

The comparison with OpenStruct was too long to include with the README - 
about four paragraphs. It is available to read separately at [docs/comparison_with_openstruct.md](docs/comparison_to_openstruct.md), and 
it explains some of the ideas behind Ryo.

## Examples

**Introduction**

The examples use `Object.create` - a monkeypatch that is opt-in
by requiring `ryo/core_ext/object`. The examples use the monkeypatch - 
if they didn't they could use `Ryo::Object.create` instead. 

**Prototypes** 

This example illustrates how prototype-based inheritance works when 
using Ryo. It is a long example but with each step documented. The 
JavaScript equivalent to this example can be found at 
[readme_examples/js/prototypes.js](readme_examples/js/prototypes.js).

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

**Equivalent to JavaScript's `Object.assign`**

Object.assign can merge two or more objects, starting
from right to left. The objects can be a mix of Ryo, 
and Hash objects. The JavaScript equivalent to this example
can be found at [readme_examples/js/object_assign.js](/readme_examples/js/object_assign.js)

```ruby
require "ryo"
require "ryo/core_ext/object"

fruit = Object.create(nil)
apple = Object.create(fruit)
Ryo.assign(fruit, apple, {sour: true})

Kernel.p apple.sour # => true
Kernel.p fruit.sour # => true
```

**Equivalent to JavaScript's `in` operator**

```ruby
##
# Create an instance of Object, with no prototype.
# On this object, define the property "eat".
fruit = Object.create(nil, {
  eat: lambda { "nomnom" }
})

##
# Create a second object, with "fruit" as
# its prototype. On this object, define
# the property "name".
apple = Object.create(fruit, {name: "Apple"})

##
# Query the "apple" object using Ryo.in? - 
# This returns true
Ryo.in?(apple, "eat")

##
# This also returns true 
Ryo.in?(apple, "name")

##
# This returns false
Ryo.in?(apple, "foobar")
```

**Equivalent to JavaScript's `delete(obj.foo)`**

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
# Using "Ryo", delete the "foo"
# property from "obj".
Ryo.delete(obj, "foo")

##
# Prints nil
Kernel.p obj.foo

```

**Equivalent to JavaScript's `Object.hasOwn`, `Object.prototype.hasOwnProperty`**

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

**BasicObject**

There are two options available to create objects that are
instances of BasicObject. The first is `Ryo::BasicObject.create`
and the second is to use the `BasicObject.create` monkeypatch
by requiring `ryo/core_ext/basic_object`.

The first option:

```ruby
require "ryo"

##
# Create an instance of BasicObject,
# and assign the property "foo" the
# value of 1.
obj = Ryo::BasicObject.create(nil, {foo: 1})

Kernel.p obj.foo
```

The second option:

```ruby
require "ryo"
require "ryo/core_ext/basic_object"

##
# Create an instance of BasicObject,
# and assign the property "foo" the
# value of 1.
obj = BasicObject.create(nil, {foo: 1})

Kernel.p obj.foo
```

## LICENSE

This project uses the MIT license, see [/LICENSE.txt](/LICENSE.txt) for details.
