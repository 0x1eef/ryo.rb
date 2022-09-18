## About

Ryo is a Ruby library that implements prototype-based inheritance - with
the implementation taking a lot of inspiration from JavaScript. Ryo can be
used for creating Ruby objects from Hash objects, for implementing configuration
objects, and for other use cases where prototype-based inheritance can be useful.

For the sake of simplicity, the objects Ryo works with are described as Hash objects,
and Array objects. Technically Ryo is duck-typed. When a Hash is mentioned that means
*any* object that implements `#each_key`, and `#each` - while when an Array is mentioned
that means *any* object that implements `#each`.

## Examples

The examples cover a lot - but not everything. The [API documentation](https://0x1eef.github.io/x/ryo.rb/)
is available as a complete reference, and covers parts of the interface not
covered by the examples.

### Prototypes

#### Point object

The following example demonstrates prototype-based inheritance in the simplest
terms I could imagine so far. It introduces three objects to form a single
point object with the properties, "x" and "y". The [Ryo()](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method) method used by
the example returns an instance of [Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html):

```ruby
require "ryo"

point_x = Ryo(x: 0)
point_y = Ryo({y: 0}, point_x)
point = Ryo({}, point_y)

p [point.x, point.y]

##
# [0, 0]
```

#### Configuration object

The following example demonstrates prototype-based inheritance by implementing a common pattern -
a configuration object that inherits its defaults from another object. The example tries to be
somewhat simple while capturing a number of advanced features (such as [`Ryo.fn`](https://0x1eef.github.io/x/ryo.rb/Ryo/Keywords.html#function-instance_method)):

```ruby
require "ryo"

default = Ryo(option: "foo", padding: 24)
config = Ryo({
  print: Ryo.fn { |source, config_option|
    print source.ljust(padding), config_option, "\n"
  }
}, default)

##
# Traverse to 'default'
config.print.call("option (from 'default')", config.option)

##
# Read directly from 'config'
print("assign config.option", "\n")
config.option = "bar"
config.print.call("option (from 'config')", config.option)

##
# Traverse to 'default'
print("delete config.option", "\n")
Ryo.delete(config, "option")
config.print.call("option (from 'default')", config.option)

##
# option (from 'default') foo
# assign config.option
# option (from 'config')  bar
# delete config.option
# option (from 'default') foo
```

### Iteration

#### Ryo.each

The following example demonstrates [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) - a method that can iterate through the properties of a Ryo object. Since Ryo takes every effort
to not mix its implementation with the objects it creates,
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) is not implemented directly
on a Ryo object.

When a block is not given, [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method)
returns an Enumerator that provides access to the methods of Enumerable. Methods on Enumerable won't
return a Ryo object, but often arrays.  Ryo addresses that with its own specialized Enumerable methods
that are covered just below. For now - a demonstration of
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method):

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

#### Ryo.map

[`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html) provides
specialized implementations of Enumerable methods that can return a new copy of a Ryo
object and its prototypes, or mutate a Ryo object and its prototypes in-place.

The following example demonstrates a mutating map operation of a Ryo object with
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method).
The non-mutating counterpart of
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method) is
[`Ryo.map`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map-instance_method), and
it returns a new copy of a Ryo object and its prototypes.

```ruby
require "ryo"

point_x = Ryo(x: 2)
point_y = Ryo({y: 4}, point_x)
point = Ryo({}, point_y)

Ryo.map!(point) { |key, value| value * 2 }
p [point.x, point.y]
p [point_x.x, point_y.y]

##
# [4, 8]
# [4, 8]
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

coords = Ryo.from({
  point_x: {x: 0}, 
  point_y: {y: 10}
})
p [coords.point_x.x, coords.point_y.y]

##
# [0, 10]
```

#### Ryo.from with an Array

The [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method) method can
walk an Array object, and create Ryo objects from Hash objects that it finds along the way.
An object that can't be coerced into a Ryo object is left as-is. The following
example demonstrates how that works in practice:

``` ruby
require "ryo"

coords = Ryo.from([
  {point_x: {x: 2}},
  "foobar",
  {point_y: {y: 4}}
])

p coords[0].point_x.x
p coords[1]
p coords[2].point_y.y

##
# 2
# "foobar"
# 4
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

x_point = Ryo::BasicObject(x: 0)
y_point = Ryo::BasicObject({y: 0}, x_point)
point = Ryo::BasicObject({}, y_point)
p [point.x, point.y]

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

coords = Ryo::BasicObject.from({
  point_x: {x: 2},
  point_y: {y: 4}
})
p [coords.point_x.x, coords.point_y.y]

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

## Resources

* [Source code (GitHub)](https://github.com/0x1eef/ryo.rb#readme)
* [Documentation](https://0x1eef.github.io/x/ryo.rb/)

## Install

Ryo is available as a RubyGem:

    gem install ryo.rb

## Thanks

Thanks to [@awfulcooking (mooff)](https://github.com/awfulcooking) for the helpful
discussions and advice that they provided on IRC regarding Ryo.

## License

This project is released under the terms of the MIT license. <br>
See [./LICENSE.txt](./LICENSE.txt) for details.
