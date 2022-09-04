## About

Ryo is a Ruby library that implements prototype-based inheritance - with
the implementation taking a lot of inspiration from JavaScript. Ryo can be
used for creating Ruby objects from Hash objects, for implementing configuration
objects, and for other use cases where prototype-based inheritance can be useful.

## Examples

The examples cover quite a lot - but not everything. The [API documentation](https://0x1eef.github.io/x/ryo.rb/)
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
  print: Ryo.fn { |source, option|
    print source.ljust(padding), option, "\n"
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

The following example demonstrates [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) - a method that can be used to iterate through
the properties of a Ryo object. Since Ryo takes every effort to not mix its implementation with
the objects it creates, [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) is not implemented as `#each` directly on a Ryo object:

```ruby
require "ryo"

car = Ryo(name: "ford", year: 1922)
Ryo.each(car) do |key, value|
  p [key, value]
end

##
# ["name", 'ford']
# ["year", 1922]
```

#### Map

The previous example introduced [`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method) - a method that returns an
Enumerator when a block is not given. An [Enumerator](https://www.rubydoc.info/stdlib/core/Enumerator) provides access to
methods such as "map". The following example demonstrates a map operation
using Ryo:

```ruby
require "ryo"

car = Ryo(name: "ford", year: 1922)
p Ryo.each(car).map { _1 == "name" ? "telsa" : 2022 }

##
# ["telsa", 2022]
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

vehicles = Ryo.from(bike: {wheels: 2}, car: {wheels: 4})
p [vehicles.bike.wheels, vehicles.car.wheels]

##
# [2, 4]
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

vehicles = Ryo::BasicObject.from(bike: {wheels: 2}, car: {wheels: 4})
p [vehicles.bike.wheels, vehicles.car.wheels]

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
