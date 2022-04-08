# ryo.rb

ryo.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is heavily inspired by JavaScript's implementation, 
in particular Ryo ports JavaScript's [`Object.create`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create).
The objects returned by Ryo's `Object.create` are similar to instances 
of Object from JavaScript, or OpenStruct from Ruby. 

## Comparisons

**1. Compared to JavaScript's "Object"**

Ryo is heavily inspired by JavaScript when it comes to its implementation - 
it copies its behavior as much as it can, including in regards 
to prototype-based inheritance. There are Ryo equivalent's to 
JavaScript - for example, in JavaScript `Object.create(null)` is equivalent
to `Object.create(nil)` in Ryo. The examples below cover this in more 
detail. Despite the heavy influence from JavaScript, I would like to think 
Ryo retains Ruby's character. 

**2. Compared to OpenStruct**

The comparison with OpenStruct was too long to include with the README - 
about four paragraphs. It is available to read separately at [docs/comparison_with_openstruct.md](docs/comparison_to_openstruct.md), and 
it explains some of the ideas behind Ryo.

## Examples

**Introduction**

The examples use `Object.create` - a monkeypatch that is opt-in
by requiring `ryo/core_ext/object`. The examples make use of the 
monkeypatch, but if they did not they could use 
`Ryo::Object.create` instead. 

**Prototype-based inheritance** 

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

**Equivalent to JavaScript's `obj.hasOwnProperty('foo')`**

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

**Create instances of BasicObject (instead of Object)**

There are two options available to create objects that are
instances of BasicObject. The first is "Ryo::BasicObject.create"
and the second option is to use the "BasicObject.create" monkeypatch
by requiring "ryo/core_ext/basic_object".

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
