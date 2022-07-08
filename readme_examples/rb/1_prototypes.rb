require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
# On this object, define the properties "name"
# and "description".
perl = Object.create(nil, {
  name: "Perl",
  description: Ryo.fn { "The #{name} programming language" }
})

##
# Find matches directly on the "ruby" object.
p perl.name # => "Perl"
p perl.description.() # => "The Perl programming language"

##
# Create a second object, with "perl" as
# its prototype.
ruby = Object.create(perl, {name: "Ruby"})

##
# Find matches directly on the "ruby" object.
p ruby.name # => "Ruby"

##
# Find matches in the prototype chain.
p ruby.description.() # => "The Ruby programming language"

##
# Create a third object, with "ruby" as its prototype.
crystal = Object.create(ruby, {name: "Crystal"})

##
# Find matches directly on the "crystal" object.
p crystal.name # => "Crystal"

##
# Find matches in the prototype chain.
p crystal.description.() # => "The Crystal programming language"

##
# Delete "name" from "crystal".
Ryo.delete(crystal, "name")

##
# Find matches in the prototype chain.
p crystal.description.() # => "The Ruby programming language"
