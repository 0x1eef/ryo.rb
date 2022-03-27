# proto.rb

proto.rb is an implementation of prototype-based inheritance in pure
Ruby. The library is heavily inspired and derived from JavaScript's 
implementation. proto.rb could be described as a port of "Object.create"
from JavaScript, as that's where the main inspiration comes from, and
it translates reasonably well to Ruby.


## Demo

```ruby
##
# Create a new object, with no prototype.
# On this object, define the property 'foo'.
one = Object.create(nil) { def foo() 42 end }  

##
# Create a second object, with "one" as its prototype.
two = Object.create(one)

##
# Query the property "foo", and traverse the 
# prototype chain until it is found (or return nil)
two.foo # => 42
```

## LICENSE

This project uses the MIT license, see [/LICENSE.txt](/LICENSE.txt) for details.
