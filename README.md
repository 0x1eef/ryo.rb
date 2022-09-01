## About

Ryo is a Ruby library that implements prototype-based inheritance - with
the implementation taking a lot of inspiration from JavaScript. Ryo can be
used for creating Ruby objects from Hash objects, for implementing configuration
objects, and for other use cases where prototype-based inheritance can be useful.

## Examples

### Prototypes

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

car = Ryo(name: 'ford', year: 1922)
Ryo.each(car) do |key, value|
  p [key, value]
end

##
# ['name', 'ford']
# ['year', 1922]
```

#### Map

The previous example introduced `Ryo.each` - a method that returns an
Enumerator when a block is not given. An Enumerator provides access to
methods such as "map". The following example demonstrates a map operation
using Ryo:

```ruby
require "ryo"

car = Ryo(name: "ford", year: 1922)
p Ryo.each(car).map { _1 == "name" ? "telsa" : 2022 }

##
# ['telsa', 2022]
```

## Install

Still in early development.
