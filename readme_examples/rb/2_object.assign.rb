require_relative "setup"
require "ryo"
require "ryo/core_ext/object"

##
# Create an instance of Object, with no prototype.
book = Object.create(nil);

##
# Merge {page_count: 10} into "book",
# then merge {title: "..."} into "book",
# and finally merge {page_count: 20} into
# "book".
Ryo.assign(
  book,
  {page_count: 10},
  {title: "The mysterious case of the believer"},
  {page_count: 20}
)

##
# Prints 20
puts book.page_count

##
# Prints: The mysterious case of the believer
puts book.title
