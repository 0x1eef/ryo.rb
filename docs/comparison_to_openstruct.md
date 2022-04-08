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
the assignment of any property to an object, even if it already exists as a 
method. There are few exceptions to this - redefining methods that would 
break Ryo's interface cannot be assigned as a property, but they are very 
few in number. 

When it comes to being an OpenStruct alternative, Ryo is capable because 
just like JavaScript, it is possible to create an object with no 
prototype, which would give you something equivalant to an instance of
OpenStruct. Ultimately though, Ryo takes a different approach and it might
be one you like (or don't like).
