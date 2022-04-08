## Comparing Ryo to OpenStruct

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
the assignment of any property to an object, even if it already exists 
as a method. Ryo also aims to make sure that whatever property you assign, 
the object will continue to function.

Take this example, where OpenStruct raises an exception when 
method_missing is defined as a field:

```ruby
require "ostruct"

obj = OpenStruct.new
obj.method_missing = nil

##
# Raises an exception:
obj.foo = 1
```

Then compare that with Ryo, who doesn't raise an exception and continues
to operate as you'd expect:

```ruby 
require "ryo"
require "ryo/core_ext/object"

obj = Object.create(nil)
obj.method_missing = 1
obj.foo = 2

##
# Prints 1
Kernel.p obj.method_missing

##
# Prints 2
Kernel.p obj.foo

```
