#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "setup"
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
