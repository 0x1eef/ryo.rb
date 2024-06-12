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
  # @param [String] path
  #  The path to a JSON file.
  #
  # @param [Ryo] object
  #  {Ryo::Object Ryo::Object}, or {Ryo::BasicObject Ryo::BasicObject}.
  #  Defaults to {Ryo::Object Ryo::Object}.
  #
  # @raise [SystemCallError]
  #  Might raise a number of Errno exceptions.
  #
  # @return [Ryo::Object, Ryo::BasicObject]
  #  Returns a Ryo object.
  def from_json_file(path, object: Ryo::Object)
    from_json File.binread(path), object:
  end

  ##
  # @param [String] blob
  #  A blob of JSON.
  #
  # @param [Ryo] object
  #  {Ryo::Object Ryo::Object}, or {Ryo::BasicObject Ryo::BasicObject}.
  #  Defaults to {Ryo::Object Ryo::Object}.
  #
  # @return (see Ryo::JSON#from_json_file)
  def from_json(blob, object: Ryo::Object)
    object.from JSON.parse(blob)
  end

  Ryo.extend(self)
end
