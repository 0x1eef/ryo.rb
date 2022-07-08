# ryo.rb

ryo.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is inspired by JavaScript's implementation,
in particular Ryo ports JavaScript's [`Object.create`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create).

## Compared to..

**1. Compared to JavaScript**

Ryo is inspired by JavaScript - it is the point of reference
a lot of the time. There are Ryo equivalents to JavaScript - for
example, JavaScript's `Object.create(null)` is equivalent to
`Object.create(nil)`.

There are Ryo modules that implement more JavaScript equivalents,
such as [`Ryo::Reflect`](http://0x1eef.github.io/x/ryo.rb/Ryo/Reflect.html) -
which is based on JavaScript's Reflect object, and [`Ryo::Keywords`](http://0x1eef.github.io/x/ryo.rb/Ryo/Keywords.html) -
which is based on JavaScript operators like `delete` and `in`. Both
modules extend the `Ryo` module - and that helps keep the typing to
a minimum.

**2. Compared to OpenStruct**

A Ryo object without a prototype is similar to an instance of
OpenStruct, with a few differences:

* For the most part, Ryo provides an object free of implementation details.
* Ryo implements most of its functionality independent of the objects
  it creates.
* Ryo objects can have `#method_missing` assigned as a property
  without breaking.
* Methods overshadowed by a property remain callable when they receive 1+ arguments.
* Ryo has an API for walking a Hash recursively - replacing Hash objects
  with Ryo objects.

The last item on the list makes mention of a specialized API that
was created for those who want to use Ryo as an OpenStruct alternative.
The following is an example of that API:

```ruby
require "ryo"
require "ryo/core_ext/object"
require "ryo/core_ext/basic_object"

##
# Create an instance of BasicObject.
ryo = BasicObject.from(foo: {bar: {baz: "foobarbaz"}})
ryo.foo.bar.baz # => "foobarbaz"

##
# Create an instance of Object.
ryo = Object.from(foo: {bar: {baz: "foobarbaz"}})
ryo.foo.bar.baz # => "foobarbaz"
```

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

Early in the example you will come across, [`Ryo.fn`](http://0x1eef.github.test/x/ryo.rb/Ryo/Function.html) -
which can also be written as [`Ryo.function`](http://0x1eef.github.test/x/ryo.rb/Ryo/Function.html). It
returns an object that is similar to a lambda, with a key difference: its
self is bound to the object it is assigned to, and that provides [equivalent
JavaScript behavior](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/1_prototypes.js#L9).

At the end of the example you will come across `Ryo.delete(crystal, "name")`, and
that is equivalent to JavaScript's
[`delete` operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/delete).


```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the properties "name"
# and "description".
perl = Object.create(nil, {
  name: "Perl",
  description: Ryo.fn { "The #{name} programming language" }
})

##
# Find matches directly on the "perl" object.
p perl.name # => "Perl"
p perl.description.() # => "The Perl programming language"

##
# Create a second object, with "perl" as
# its prototype.
ruby = Object.create(perl, {name: "Ruby"})

##
# Find matches directly on the "ruby" object.
p ruby.name # => "Ruby"

##
# Find matches in the prototype chain.
p ruby.description.() # => "The Ruby programming language"

##
# Create a third object, with "ruby" as its prototype.
crystal = Object.create(ruby, {name: "Crystal"})

##
# Find matches directly on the "crystal" object.
p crystal.name # => "Crystal"

##
# Find matches in the prototype chain.
p crystal.description.() # => "The Crystal programming language"

##
# Delete "name" from "crystal".
Ryo.delete(crystal, "name")

##
# Find matches in the prototype chain.
p crystal.description.() # => "The Ruby programming language"

```

**2. Equivalent to JavaScript's `Object.assign`**

`Ryo.assign` is Ryo's equivalent to [`Object.assign`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign).
With `Ryo.assign`, one can merge multiple source objects into a target
object, and the source objects can be a mix of Ryo, and Hash objects. The javascript equivalent to this example can be found at
[readme_examples/js/2_object.assign.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/2_object.assign.js).

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
book = Object.create(nil)

##
# Merge {page_count: 10} into "book",
# then merge {title: "..."} into "book",
# and finally merge {page_count: 20} into
# "book".
Ryo.assign(
  book,
  {page_count: 10},
  {title: "The mysterious case of the believer"},
  {page_count: 20}
)

##
# Prints 20
p book.page_count

##
# Prints: The mysterious case of the believer
p book.title

```

**3. Equivalent to JavaScript's `in` operator**

JavaScript's [`in` operator]() can check for property membership
in an object and in its prototype chain. If the property is found
on neither of those, `false` is returned. Ryo's equivalent to this
is the `Ryo.in?` method. The javascript equivalent
to this example can be found at [readme_examples/js/3_in.operator.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/3_in.operator.js).


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
p Ryo.in?(honda, "wheels")

##
# Returns true after finding the "model"
# property directly on "honda".
p Ryo.in?(honda, "model")

##
# Returns false after not finding the "foobar"
# property on "honda", or in its prototype chain.
p Ryo.in?(honda, "foobar")

```

**4. Equivalent to JavaScript's `Object.hasOwn`, `Object.prototype.hasOwnProperty`**

`Ryo.property?` is Ryo's equivalent to JavaScript's [`Object.hasOwn`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/hasOwn), and
to a lesser extent, [`Object.prototype.hasOwnProperty`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/hasOwnProperty). With `Ryo.property?`
one can discover if a property is defined directly on an object - without
consulting the prototype chain. The javascript equivalent
to this example can be found at [readme_examples/js/4_object.hasOwn.js](https://github.com/0x1eef/ryo.rb/blob/master/readme_examples/js/4_object.hasOwn.js).

```ruby
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
ryo = Object.create(nil, {foo: "foo"})

##
# Create a second object, with the "ryo" object as
# its prototype.
ryo2 = Object.create(ryo, {bar: "bar"})

##
# Returns false
p Ryo.property?(ryo2, "foo")

##
# Returns true
p Ryo.property?(ryo2, "bar")
```

## Resources

* [Homepage](https://0x1eef.github.io/x/ryo.rb)
* [Source code](https://github.com/0x1eef/ryo.rb)


## Thanks

I'd like to extend special thanks to mooff on `irc.libera.chat/#ruby` for
brain storming and taking part in discussions about Ryo. Those discussions
had a big impact on the direction Ryo took.


## LICENSE

This project uses the MIT license, see [/LICENSE.txt](/LICENSE.txt) for details.
