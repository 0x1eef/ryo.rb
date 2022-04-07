# ryo.rb

ryo.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is heavily inspired by JavaScript's implementation, 
in particular Ryo ports JavaScript's [`Object.create`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create).
The objects returned by Ryo's `Object.create` are similar to instances 
of Object from JavaScript, or OpenStruct from Ruby. 

When comparing Ryo to OpenStruct there are notable differences - 
beyond OpenStruct's not having prototypes. For example to delete a "field" in OpenStruct 
one would write `obj.delete_field!(:foo)` where as with Ryo it would be 
`Ryo.delete(obj, "foo")`, and while Ryo can provide the same 
functionality as OpenStruct it has solved the problems it faced differently.

## Demo

**Prototype-based inheritance** 

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create a new object, with no prototype.
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
# Read the property "name", and find a match
# directly on the apple object.
Kernel.p apple.name # => "Apple"

##
# Read the property "eat", and traverse the
# prototype chain until it is found on "fruit".
Kernel.p apple.eat.()
``` 

**Equivalent to JavaScript's `in` operator**

```ruby
##
# Create a new object, with no prototype.
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
# Create a new object, with no prototype.
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
# Create a new object, with no prototype.
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
