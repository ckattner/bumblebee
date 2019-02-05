# 2.0.1 (February 5th, 2019)

* Updated acts_as_hashable Dependency

# 2.0.0 (January 31, 2019)

* Upgraded Rubocop
* Updated README
* Hooked up CodeClimate / Test Coverage
* Changed internal implementation of Column#csv_to_object.  This is a breaking change that reverse's the flow of assignment: When a column is parsed and value is extracted, it will iterate over the to_object values one by one, chaining the previous value with the next.  Once it is complete, it assigns the value to the field.

# 1.2.1 (January 22, 2019)

* README enhancements.

# 1.2.0 (January 22, 2019)

* Updated parser so it is position-agnostic.  Previously the position of the headers mattered to the parser.  Now, the headers in the file will be used and matched on with the column headers.

# 1.1.0 (January 22, 2019)

* Updated parser so it is now compatible and works with Ruby 2.5.3 and 2.6.0.
* Minimum Ruby version bumped to 2.3.8

# 1.0.0 (December 27, 2018)

Initial Release
