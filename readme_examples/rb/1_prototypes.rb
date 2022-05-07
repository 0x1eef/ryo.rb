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
puts perl.name # => "Perl"
puts perl.description.() # => "The Perl programming language"

##
# Create a second object, with "perl" as
# its prototype.
ruby = Object.create(perl, {name: "Ruby"})

##
# Find matches directly on the "ruby" object.
puts ruby.name # => "Ruby"

##
# Find matches in the prototype chain.
puts ruby.description.() # => "The Ruby programming language"

##
# Create a third object, with "ruby" as its prototype.
crystal = Object.create(ruby, {name: "Crystal"})

##
# Find matches directly on the "crystal" object.
puts crystal.name # => "Crystal"

##
# Find matches in the prototype chain.
puts crystal.description.() # => "The Crystal programming language"

##
# Delete "name" from "crystal".
Ryo.delete(crystal, "name")

##
# Find matches in the prototype chain.
puts crystal.description.() # => "The Ruby programming language"
