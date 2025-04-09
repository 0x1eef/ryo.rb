## About

Ryo implements prototype-based inheritance, in Ruby.

## Examples

### Prototypes

#### Point object

The following example demonstrates how prototype-based inheritance is
implemented in Ryo. The example introduces three objects to form a
single point object with the properties, "x" and "y". The
[Ryo()](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method)
method seen in the example returns an instance of
[Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html):

```ruby
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)
p [point.x, point.y]

##
# [5, 10]
```

#### Patterns

Ryo objects can be used with the
[pattern matching feature](https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html)
that has been available since Ruby 2.7. It works in a very similar
way to matching against a Hash object, and traverses the prototype
chain:

```ruby
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)

case point
in {x: 5}
  print "point.x = 5", "\n"
else
  print "no match!", "\n"
end

##
# point.x = 5
```

### Functions

#### Ryo.fn

The following example demonstrates a Ryo function.
[`Ryo.fn`](https://0x1eef.github.io/x/ryo.rb/Ryo/Keywords.html#function-instance_method)
will bind its `self` to the Ryo object it is assigned to, and when the function
is called it will have access to the properties of the Ryo object:

```ruby
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({
  multiply: Ryo.fn { |m| [x * m, y * m] }
}, point_y)
p point.multiply.call(2)

##
# [10, 20]
```

#### Ryo.memo

The following example demonstrates
[`Ryo.memo`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#memo-class_method).
`Ryo.memo` returns a value that becomes memoized after a property is
accessed for the first time. It is similar to a Ryo function:

```ruby
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: Ryo.memo { 5 })
point_y = Ryo({y: Ryo.memo { 10 }}, point_x)
point = Ryo({sum: Ryo.memo { x + y }}, point_y)
print "point.x = ", point.x, "\n"
print "point.y = ", point.y, "\n"
print "point.sum = ", point.sum, "\n"

##
# point.x = 5
# point.y = 10
# point.sum = 15
```

### Iteration

#### Ryo.each

The
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method)
method can iterate through the properties of a Ryo object, and
its prototype(s). Ryo is designed to not mix its implementation
with the objects it creates -  that's why
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method)
is not implemented directly on a Ryo object. A demonstration of
[`Ryo.each`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#each-class_method):

```ruby
#!/usr/bin/env ruby
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

[`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html)
methods can return a new copy of a Ryo object and its prototypes, or mutate
a Ryo object and its prototypes in-place. The following example demonstrates
an in-place map operation on a Ryo object with
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method).
The counterpart of
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method)
is
[`Ryo.map`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map-instance_method),
and it returns a new copy of a Ryo object and its prototypes. A demonstration of
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method):

```ruby
#!/usr/bin/env ruby
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
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)

p Ryo.find(point, ancestors: 0) { |k,v| v == 5 }   # => nil
p Ryo.find(point, ancestors: 1) { |k,v| v == 5 }   # => nil
p Ryo.find(point, ancestors: 2) { |k,v| v == 5 }.x # => point_x.x
p Ryo.find(point) { |k,v| v == 5 }.x # => point_x.x
```

### Recursion

#### Ryo.from

The [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method) method has
the same interface as the [`Ryo`](https://0x1eef.github.io/x/ryo.rb/top-level-namespace.html#Ryo-instance_method)
method, but it is implemented to recursively walk a Hash object and create Ryo objects
from other Hash objects found along the way. The following example demonstrates
[`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method):

```ruby
#!/usr/bin/env ruby
require "ryo"

person = Ryo.from({
  name: "John",
  age: 30,
  address: {
    street: "123 Main St",
    city: "Anytown",
    state: "AS",
    zip: 12345
  }
})
p [person.name, person.age, person.address.city]

##
# ["John", 30, "Anytown"]
```

#### Ryo.from with an Array

The [`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method) method can
walk an Array object, and create Ryo objects from Hash objects found along the way.
An object that can't be turned into a Ryo object is left as-is. The following
example demonstrates how that works in practice:

``` ruby
#!/usr/bin/env ruby
require "ryo"

points = Ryo.from([
  {x: 2},
  "foobar",
  {y: 4}
])

p points[0].x
p points[1]
p points[2].y

##
# 2
# "foobar"
# 4
```

#### Ryo.from with OpenStruct

All methods that can create Ryo objects support turning a Struct, or OpenStruct object
into a Ryo object. The following example demonstrates how
[`Ryo.from`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method)
can recursively turn an OpenStruct object into Ryo objects:

``` ruby
#!/usr/bin/env ruby
require "ryo"
require "ostruct"

point = Ryo.from(
  OpenStruct.new(x: 5, y: 10)
)
p [point.x, point.y]

##
# [5, 10]
```

### BasicObject

#### Ryo::BasicObject

All of the previous examples have been working with instances of
[Ryo::Object](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html),
a subclass of Ruby's Object class. In comparison, [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html) -
a subclass of Ruby's BasicObject class, provides an object
with fewer methods. The following example demonstrates
how to create an instance of [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html):

```ruby
#!/usr/bin/env ruby
require "ryo"

point_x = Ryo::BasicObject(x: 0)
point_y = Ryo::BasicObject({y: 0}, point_x)
point = Ryo::BasicObject({}, point_y)
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
#!/usr/bin/env ruby
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

When a property and method collide, Ryo tries to
find the best resolution. Because Ryo properties don't
accept arguments, and methods can - we can distinguish a
method from a Ryo property by the presence or absence of
an argument in at least some cases. Consider the following
example, where a property collides with the `Kernel#then` method:

```ruby
#!/usr/bin/env ruby
require "ryo"

ryo = Ryo::Object(then: 12)
# Resolves to Ryo property
p ryo.then # => 12
# Resolves to Kernel#then
p ryo.then { 34 } # => 34
```

### Beyond Hash objects

#### Duck typing

The documentation has used simple terms to describe
the objects that Ryo works with: Hash and Array objects.
But that doesn't quite capture that Ryo is implemented with
duck typing: any object that implements `#each_pair`
could be used instead of a Hash, and any object that
implements `#each` could be used instead of an Array. Note that only
[Ryo.from](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method),
[Ryo::Object.from](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html#from-class_method)
and
[Ryo::BasicObject.from](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html#from-class_method)
can handle Array-like objects.

The following example implements `#each_pair`:

``` ruby
#!/usr/bin/env ruby
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

point = Ryo(Point.new)
p point.x # => 5
p point.y # => 10
```

## Documentation

A complete API reference is available at
[0x1eef.github.io/x/ryo.rb](https://0x1eef.github.io/x/ryo.rb)

## Install

Ryo can be installed via rubygems.org:

    gem install ryo.rb

## Sources

* [github.com/@0x1eef](https://github.com/0x1eef/ryo.rb#readme)
* [gitlab.com/@0x1eef](https://gitlab.com/0x1eef/ryo.rb#about)

## Thanks

Thanks to
[@awfulcooking (mooff)](https://github.com/awfulcooking)
and
[@havenwood](https://github.com/havenwood)
for the helpful discussions

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
