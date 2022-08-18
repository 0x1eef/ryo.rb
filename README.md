## About

Ryo is a Ruby library that implements prototype-based inheritance - with
the implementation taking a lot of inspiration from JavaScript. Ryo can be
used for creating Ruby objects from Hash objects, for implementing configuration
objects, and for other use cases where prototype-based inheritance can be useful.

A notable feature of Ryo is that properties that overshadow a method remain callable
as long as the property is called with one or more arguments - this means that methods
such as `#method_missing` can be defined as a property without breaking the underlying
`#method_missing` implementation. The same is true for `#puts`, and so on.

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

## Install

Still in early development.
