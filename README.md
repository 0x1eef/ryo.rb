## About

Ryo implements prototype-based inheritance, in Ruby.

Ryo can be suitable for establishing relationships between objects,
for acting as a drop-in OpenStruct replacement, and for a number of
other use cases where prototype-based inheritance makes sense.

JavaScript's implementation of prototype-based inheritance was a source
of inspiration and served as a reference point for Ryo's implementation.

## Examples

### Introduction

The examples provide a high-level overview, and cover a lot - but not
everything. <br>
The  [API documentation](https://0x1eef.github.io/x/ryo.rb) is available
as a complete reference.

### Prototypes

#### Point object

The following example demonstrates how prototype-based inheritance works
in Ryo. The example introduces three objects to form a single point object
with the properties, "x" and "y". The
[Ryo()](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method)
method seen in the example returns an instance of
[Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html):

```ruby
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({}, point_b)
p [point_c.x, point_c.y]

##
# [5, 10]
```

#### Ryo.fn

The following example builds upon the previous example by introducing a Ryo function.
[`Ryo.fn`](https://0x1eef.github.io/x/ryo.rb/Ryo/Keywords.html#function-instance_method)
will bind its `self` to the Ryo object it is assigned to. When the function is called it
will have access to the properties available through the prototype chain of the Ryo object:

```ruby
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({
  inspect: Ryo.fn { |m| [x * m, y * m] }
}, point_b)
p point_c.inspect.call(2)

##
# [10, 20]
```

### Iteration

#### Ryo.each

The following example demonstrates
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) -
a method that can iterate through the properties of a Ryo object, and
its prototype(s). Ryo makes every effort to not mix its implementation
with the objects it creates -  that's why [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method)
is not implemented directly on a Ryo object.

When a block is not given,
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method)
returns an Enumerator that provides access to the methods of Ruby's Enumerable.
Methods on Enumerable won't return a Ryo object, but often arrays. Ryo addresses
that with [`Ryo::Enumerable`](https://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html).

A demonstration of [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method):

```ruby
require "ryo"

point = Ryo(x: 10, y: 20)
Ryo.each(point) do |key, value|
  p [key, value]
end

##
# ["x", 10]
# ["y", 20]
```

#### Ryo.map!

A number of [`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html) methods
can return a new copy of a Ryo object and its prototypes, or mutate a Ryo object and its prototypes
in-place. The following example demonstrates an in-place map operation on a Ryo object with
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method).
The counterpart of
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method) is
[`Ryo.map`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map-instance_method), and
it returns a new copy of a Ryo object and its prototypes.

A demonstration of [`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method):

```ruby
require "ryo"

point_a = Ryo(x: 2)
point_b = Ryo({y: 4}, point_a)
point_c = Ryo({}, point_b)

Ryo.map!(point) { |key, value| value * 2 }
p [point_c.x, point_c.y]
p [point_a.x, point_b.y]

##
# [4, 8]
# [4, 8]
```

#### Ancestors

All [`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html)
methods support an optional `ancestors` option.

`ancestors` is an integer that determines how far up the prototype chain a
[`Ryo::Enumerable`](https://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html)
method can go. 0 covers a Ryo object, and none of the prototypes in its
prototype chain. 1 covers a Ryo object, and one of the prototypes in its
prototype chain - and so on.

When the `ancestors` option is not provided, the default behavior of
[`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html)
methods is to traverse the entire prototype chain. The following example
demonstrates using the `ancestors` option with
[`Ryo.find`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#find-class_method):

```ruby
require "ryo"

point_a = Ryo(x: 5)
point_b = Ryo({y: 10}, point_a)
point_c = Ryo({z: 15}, point_b)

p Ryo.find(point_c, ancestors: 0) { |k,v| v == 5 } # => nil
p Ryo.find(point_c, ancestors: 1) { |k,v| v == 5 } # => nil
p Ryo.find(point_c, ancestors: 2) { |k,v| v == 5 } # => point_a
p Ryo.find(point_c){ |k,v| v == 5 } # => point_a
```

### Recursion

#### Ryo.from

The [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method) method has
the same interface as the [`Ryo`](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method)
method, but it is implemented to recursively walk a Hash object and create Ryo objects
from any nested Hash objects that it finds along the way.

The reason recursion is not default behavior is that it has the potential to
be a slow operation when given a complex Hash object that's potentially very large -
otherwise there shouldn't be a noticeable performance impact.

The following example demonstrates [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method):

```ruby
require "ryo"

point = Ryo.from({
  x: {to_i: 0},
  y: {to_i: 10}
})
p [point.x.to_i, point.y.to_i]

##
# [0, 10]
```

#### Ryo.from with an Array

The [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method) method can
walk an Array object, and create Ryo objects from Hash objects that it finds along the way.
An object that can't be turned into a Ryo object is left as-is. The following
example demonstrates how that works in practice:

``` ruby
require "ryo"

points = Ryo.from([
  {x: {to_i: 2}},
  "foobar",
  {y: {to_i: 4}}
])

p points[0].x.to_i
p points[1]
p points[2].y.to_i

##
# 2
# "foobar"
# 4
```

#### Ryo.from with OpenStruct

All methods that can create Ryo objects support turning a Struct, or OpenStruct object
into a Ryo object. The following example demonstrates how
[`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method)
can recursively transform an OpenStruct object into Ryo objects. The example also assigns
a prototype to the Ryo object created from the OpenStruct:

``` ruby
require "ryo"
require "ostruct"

point = Ryo.from(
  OpenStruct.new(x: {to_i: 5}),
  Ryo.from(y: {to_i: 10})
)
p [point.x.to_i, point.y.to_i]

##
# [5, 10]
```

### BasicObject

#### Ryo::BasicObject

All of the previous examples have been working with instances of
[Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html),
a subclass of Ruby's Object class. In comparison, [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html) -
a subclass of Ruby's BasicObject class, provides an object
with very few methods. The following example demonstrates
how to create an instance of [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html):

```ruby
require "ryo"

point_a = Ryo::BasicObject(x: 0)
point_b = Ryo::BasicObject({y: 0}, point_a)
point_c = Ryo::BasicObject({}, point_b)
p [point_c.x, point_c.y]

##
# [0, 0]
```

#### Ryo::BasicObject.from

[Ryo::BasicObject.from](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html#from-class_method)
is identical to Ryo.from but rather than returning instance(s) of [Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html)
it returns instance(s) of [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html)
instead:

```ruby
require "ryo"

point = Ryo::BasicObject.from({
  x: {to_i: 2},
  y: {to_i: 4}
})
p [point.x.to_i, point.y.to_i]

##
# [2, 4]
```

### Collisions

#### Resolution strategy

When a property and method collide, Ryo tries to find the best resolution. Since Ryo properties
don't accept arguments, and methods can - we are able to distinguish a property from a method in
many cases.

Consider this example, where a property collides with the `Kernel#then` method. This example
would work the same for other methods that accept a block and/or arguments:

```ruby
require "ryo"

ryo = Ryo::Object(then: 12)
p ryo.then # => 12
p ryo.then { 34 } # => 34
```

### Beyond Hash objects

#### Duck typing

To keep the documentation simple, the objects Ryo works with have been
described as Hash objects, and Array objects. Technically Ryo makes use of
duck typing. When a Hash is mentioned that means *any* object that implements
`#each_pair` - while when an Array is mentioned that means *any* object that
implements `#each`. The only methods that support Array / `#each` objects are
[Ryo.from](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method),
[Ryo::Object.from](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html#from-class_method)
and
[Ryo::BasicObject.from](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html#from-class_method).

The following example demonstrates how to transform a custom object that implements 
`#each_pair` into a Ryo object:

``` ruby
require "ryo"

class Point
  def initialize
    @x = 5
    @y = 10
  end

  def each_pair
    yield("x", @x)
    yield("y", @y)
  end
end

option = Ryo(Point.new)
p option.x # => 5
p option.y # => 10
```

## Sources

* [Source code (GitHub)](https://github.com/0x1eef/ryo.rb#readme)
* [Source code (GitLab)](https://gitlab.com/0x1eef/ryo-rb#about)

## Install

Ryo is available as a RubyGem:

    gem install ryo.rb

## Thanks

Thanks to [@awfulcooking (mooff)](https://github.com/awfulcooking) for the helpful
discussions and advice that they provided on IRC regarding Ryo.

## License

This project is released under the terms of the MIT license. <br>
See [./LICENSE.txt](./LICENSE.txt) for details.
