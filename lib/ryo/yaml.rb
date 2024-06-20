# frozen_string_literal: true

##
# The {Ryo::YAML Ryo::YAML} module provides a number of methods
# for coercing YAML data into a Ryo object. It must be required
# separately to Ryo (ie: require "ryo/yaml"), and the methods of
# this module are then available on the {Ryo Ryo} module.
module Ryo::YAML
  require "yaml"
  extend self

  ##
  # @example
  #   Ryo.from_yaml(path: "/foo/bar/baz.yaml")
  #   Ryo.from_yaml(string: "---\nfoo: bar\n")
  #
  # @param [String] path
  #  The path to a YAML file
  #
  # @param [String] string
  #  A blob of YAML
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
  def from_yaml(path: nil, string: nil, object: Ryo::Object)
    if path && string
      raise ArgumentError, "Provide a path or string but not both"
    elsif path
      object.from YAML.load_file(path)
    elsif string
      object.from YAML.load(string)
    else
      raise ArgumentError, "No path or string provided"
    end
  end

  Ryo.extend(self)
end
