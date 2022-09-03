# frozen_string_literal: true

require_relative "setup"
require "ryo"

default = Ryo(option: "foo", padding: 24)
config = Ryo({
  print: Ryo.fn { |source, option|
    print source.ljust(padding), option, "\n"
  }
}, default)

##
# Traverse to 'default'
config.print.call("option (from 'default')", config.option)

##
# Read directly from 'config'
print("assign config.option", "\n")
config.option = "bar"
config.print.call("option (from 'config')", config.option)

##
# Traverse to 'default'
print("delete config.option", "\n")
Ryo.delete(config, "option")
config.print.call("option (from 'default')", config.option)
