require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the properties "planet",
# and "greet".
person = Object.create(nil, {
  planet: "Earth",
  greet: Ryo.fn {
    greeting = "#{name} asks: have you tried #{language}? " \
               "It is popular on my home planet, #{planet}."
    puts greeting
  }
})

##
# Create a second object, with "person" as
# its prototype. On this object, define
# the properties "name", and "language".
larry = Object.create(person, {name: "Larry Wall", language: "Perl"})

##
# Find matches directly on the larry object.
larry.name     # => "Larry Wall"
larry.language # => "Perl"

##
# Find matches in the prototype chain.
larry.planet   # => "Earth"
larry.greet.() # => "Larry Wall asks: have you tried Perl? ..."

##
# Create a third object, with "larry" as its
# prototype. On this object, define the properties
# "name" and "language".
matz = Object.create(larry, {name: "Yukihiro Matsumoto", language: "Ruby"})

##
# Find matches directly on the matz object.
matz.name     # => "Yukihiro Matsumoto"
matz.language # => "Ruby"

##
# Find matches in the prototype chain.
matz.planet   # => "Earth"
matz.greet.() # => "Yukihiro Matsumoto asks: have you tried Ruby? ..."

##
# Delete the "language" property from matz,
# and find it on the larry prototype instead.
Ryo.delete(matz, "language")
matz.greet.() # => "Yukihiro Matsumoto asks: have you tried Perl? ..."
