## About

Ryo implements prototype-based inheritance, in Ruby.

Ryo's implementation of prototype-based inheritance offers
a flexible approach for establishing object relationships,
and building configuration objects. Ryo can also act as a
recursive OpenStruct alternative. JavaScript's implementation of
prototype-based inheritance served as a reference point
for Ryo's implementation.

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
require "ryo"

point_x = Ryo(x: 5)
point_y = Ryo({y: 10}, point_x)
point = Ryo({}, point_y)
p [point.x, point.y]

##
# [5, 10]
```

#### Ryo.fn

The following example demonstrates a Ryo function.
[`Ryo.fn`](https://0x1eef.github.io/x/ryo.rb/Ryo/Keywords.html#function-instance_method)
will bind its `self` to the Ryo object it is assigned to, and when the function
is called it will have access to the properties of the Ryo object:

```ruby
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

#### Ryo.lazy

The following example demonstrates a lazy Ryo value.
[`Ryo.lazy`](https://0x1eef.github.io/x/ryo.rb/Ryo.html#lazy-class_method)
creates a lazy value that is not evaluated until a property is accessed
for the first time. It is similar to a Ryo function but it does not require
that the `#call` method be used, and after the property is accessed for the
first time the lazy value is replaced by the evaluated value:

```ruby
require "ryo"

point_x = Ryo(x: Ryo.lazy { 5 })
point_y = Ryo({y: Ryo.lazy { 10 }}, point_x)
point = Ryo({sum: Ryo.lazy { x + y }}, point_y)
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
is not implemented directly on a Ryo object.

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

[`Ryo::Enumerable`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html)
methods can return a new copy of a Ryo object and its prototypes, or mutate
a Ryo object and its prototypes in-place. The following example demonstrates
an in-place map operation on a Ryo object with
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method).
The counterpart of
[`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method)
is
[`Ryo.map`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map-instance_method),
and it returns a new copy of a Ryo object and its prototypes.

A demonstration of [`Ryo.map!`](http://0x1eef.github.io/x/ryo.rb/Ryo/Enumerable.html#map!-instance_method):

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
from other Hash objects found along the way. Recursion is not the default behavior
because it has the potential to be slow when given a complex Hash object that's
very large - otherwise there shouldn't be a noticeable performance impact.

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
walk an Array object, and create Ryo objects from Hash objects found along the way.
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
can recursively turn an OpenStruct object into Ryo objects. The example also assigns
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
with fewer methods. The following example demonstrates
how to create an instance of [Ryo::BasicObject](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html):

```ruby
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

The documentation has used simple terms to describe the objects that Ryo works
with: Hash and Array objects. But actually, Ryo uses duck typing, so any object
that implements `#each_pair` can be treated as a Hash object, and any object that
implements `#each` can be treated as an Array object. Note that only
[Ryo.from](https://0x1eef.github.io/x/ryo.rb/Ryo.html#from-class_method),
[Ryo::Object.from](https://0x1eef.github.io/x/ryo.rb/Ryo/Object.html#from-class_method)
and
[Ryo::BasicObject.from](https://0x1eef.github.io/x/ryo.rb/Ryo/BasicObject.html#from-class_method)
can handle Array/#each objects.

Here's an example of how to turn your own custom object, which implements
`#each_pair`, into a Ryo object:

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

point = Ryo(Point.new)
p point.x # => 5
p point.y # => 10
```

## Sources

* [Source code (GitHub)](https://github.com/0x1eef/ryo.rb#readme)
* [Source code (GitLab)](https://gitlab.com/0x1eef/ryo.rb#about)

## <a id='install'>Install</a>

**Git**

Ryo is distributed as a RubyGem through its git repositories. <br>
[GitHub](https://github.com/0x1eef/ryo.rb),
and
[GitLab](https://gitlab.com/0x1eef/ryo.rb)
are available as sources.

```ruby
# Gemfile
gem "ryo.rb", github: "0x1eef/ryo.rb", tag: "v0.4.7"
```

**Rubygems.org**

Ryo can also be installed via rubygems.org.

    gem install ryo.rb

## Thanks

Thanks to
[@awfulcooking (mooff)](https://github.com/awfulcooking)
for the helpful discussions and advice.

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/).
<br>
See [LICENSE](./LICENSE).

