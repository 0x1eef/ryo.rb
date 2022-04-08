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
to `Object.create(nil)` in Ryo. The demos below cover this in more 
detail. Despite the heavy influence from JavaScript, I would like to think 
Ryo retains Ruby's character. 

**2. Compared to OpenStruct**

When comparing Ryo to OpenStruct there are stark differences - 
beyond instances of OpenStruct not having prototypes or implementing
anything like them. 

For example to delete a "field" using OpenStruct one would write 
`open_struct.delete_field!(:foo)` where as with Ryo the equivalent
would be `Ryo.delete(obj, "foo")`. Ryo does this to avoid defining
methods directly on "obj", in fact Ryo defines as few methods as it 
can on the objects it creates. The reason is to avoid conflict with 
properties a user of Ryo could assign, and for functionality to 
remain present regardless of what properties are assigned to an 
object. 

Ryo also provides the option to create objects who are instances of
Object (the default), or BasicObject - but like JavaScript it allows
the assignment of any property to an object, even if it already exists as a 
method. There are few exceptions to this - redefining methods that would 
break Ryo's interface cannot be assigned as a property, but they are very 
few in number. 

When it comes to being an OpenStruct alternative, Ryo is capable of that 
because just like JavaScript, it is possible to create an object with no 
prototype, which would give you something equivalant to an instance of
OpenStruct. Ultimately though, Ryo takes a different approach and it might
be one you like (or don't like).

## Examples

**Introduction**

The examples use `Object.create` - a monkeypatch that is opt-in
by requiring `ryo/core_ext/object`. The examples make use of the 
monkeypatch, but if they did not they could use 
`Ryo::Object.create` instead. 

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

**Creating instances of BasicObject (instead of Object)**

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
