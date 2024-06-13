# frozen_string_literal: true

##
# The {Ryo::JSON Ryo::JSON} module provides a number of methods
# for coercing JSON data into a Ryo object. It must be required
# separately to Ryo (ie: require "ryo/json"), and the methods of
# this module are then available on the {Ryo Ryo} module.
module Ryo::JSON
  require "json"
  extend self

  ##
  # @example
  #   Ryo.from_json(path: "/foo/bar/baz.json")
  #   Ryo.from_json(string: "[]")
  #
  # @param [String] path
  #  The path to a JSON file
  #
  # @param [String] string
  #  A blob of JSON
  #
  # @param [Ryo] object
  #  {Ryo::Object Ryo::Object}, or {Ryo::BasicObject Ryo::BasicObject}
  #  Defaults to {Ryo::Object Ryo::Object}
  #
  # @raise [SystemCallError]
  #  Might raise a number of Errno exceptions
  #
  # @return [Ryo::Object, Ryo::BasicObject]
  #  Returns a Ryo object
  def from_json(path: nil, string: nil, object: Ryo::Object)
    if path && string
      raise ArgumentError, "Provide a path or string but not both"
    elsif path
      object.from JSON.parse(File.binread(path))
    elsif string
      object.from JSON.parse(string)
    else
      raise ArgumentError, "No path or string provided"
    end
  end

  Ryo.extend(self)
end
