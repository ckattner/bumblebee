# Bumblebee

[![Gem Version](https://badge.fury.io/rb/bumblebee.svg)](https://badge.fury.io/rb/bumblebee) [![Build Status](https://travis-ci.org/bluemarblepayroll/bumblebee.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/bumblebee) [![Maintainability](https://api.codeclimate.com/v1/badges/e56cf63628a6b12ad1aa/maintainability)](https://codeclimate.com/github/bluemarblepayroll/bumblebee/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/e56cf63628a6b12ad1aa/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/bumblebee/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Higher level languages, such as Ruby, make interacting with CSV (Comma Separated Values) files trivial. Even so, this library provides a very simple object/CSV mapper that allows you to fully interact with CSV's in a declarative way.  Locking in common patterns, even in higher level languages, is important in large codebases.  Using a library, such as this, will help ensure standardization around CSV interaction.

## Installation

To install through Rubygems:

````
gem install install bumblebee
````

You can also add this to your Gemfile:

````
bundle add bumblebee
````

## Examples

### A Simple 1:1 Example

Imagine the following CSV:

id | name | dob        | phone
-- | ---- | ---------- | ------------
1  | Matt | 1901-02-03 | 555-555-5555
2  | Nick | 1921-09-03 | 444-444-4444
3  | Sam  | 1932-12-12 | 333-333-3333

Using the following column configuration:

````ruby
columns = %i[id name dob phone]
````

We could parse this data and turn it into hashes:

````ruby
objects = Bumblebee::Template.new(columns: columns).parse(data)
````

Then `objects` is this array of hashes:

````ruby
[
  { id: '1', name: 'Matt', dob: '1901-02-03', phone: '555-555-5555' },
  { id: '2', name: 'Nick', dob: '1921-09-03', phone: '444-444-4444' },
  { id: '3', name: 'Sam',  dob: '1932-12-12', phone: '333-333-3333' }
]
````

*Note: Data, in this case, would be the CSV file contents in string format.*

### Custom Headers

If our headers are not a perfect 1:1 match to our object, such as:

ID # | First Name | Date of Birth | Phone #
---- | ---------- | ------------- | ------------
1    | Matt       | 1901-02-03    | 555-555-5555
2    | Nick       | 1921-09-03    | 444-444-4444
3    | Sam        | 1932-12-12    | 333-333-3333

Then we can explicitly map those as:

````ruby
columns = {
  'ID #' => :id,
  'First Name' => :name,
  'Date of Birth' => :dob,
  'Phone #' => :phone
}
````

### Nested Objects

Let's say we have the following data which we want to create a CSV from:

````ruby
objects = [
  {
    id: 1,
    name:     { first: 'Matt' },
    demo:     { dob: '1901-02-03' },
    contact:  { phone: '555-555-5555' }
  },
  {
    id: 2,
    name:     { first: 'Nick' },
    demo:     { dob: '1921-09-03' },
    contact:  { phone: '444-444-4444' }
  },
  {
    id: 3,
    name:     { first: 'Sam' },
    demo:     { dob: '1932-12-12' },
    contact:  { phone: '333-333-3333' }
  }
]
````

We could create a flat-file CSV:

ID # | First Name | Date of Birth | Phone #
---- | ---------- | ------------- | ------------
1    | Matt       | 1901-02-03    | 555-555-5555
2    | Nick       | 1921-09-03    | 444-444-4444
3    | Sam        | 1932-12-12    | 333-333-3333

Using the following column config:

````ruby
columns = {
  'ID #' => :id,
  'First Name': {
    property: :first,
    through: :name
  },
  'Date of Birth': {
    property: :dob,
    through: :demo
  },
  'Phone #': {
    property: :phone,
    through: :contact
  }
]
````

And executing the following:

````ruby
csv = Bumblebee::Template.new(columns: columns).generate(objects)
````

The above columns config would work both ways, so if we received the CSV, we could parse it to an array of nested hashes.

### Custom  Formatting

You can also pass in built-in or custom functions that can do the value formatting.  For example:

````ruby
columns = {
  'ID #': {
    property: :id,
    to_object: :integer
  },
  'First Name': {
    property: :first,
    through: :name,
    to_csv: ->(v) { v.to_s.upcase }
  },
  'Date of Birth': {
    property: :dob,
    through: :demo,
    to_object: { type: :date, nullable: true }
  },
  'Phone #': {
    property: :phone,
    through: :contact
  }
}
````

would ensure:

* id is an integer data type when parsed
* the CSV has only upper-case `First Name` values
* dob is a date data type when parsed

Other formatting functions that can be used for to_object and/or to_csv:

* bigdecimal: converts to BigDecimal (nullable, non-nullable default is 0)
* boolean: converts to flexible boolean (nullable; non-nullable default is false).  1,t,true,y,yes all parse to true, 0,f,false,n,no all parse to false
* date: converts to Date (nullable; non-nullable default is 1900-01-01)
* integer: converts to Fixnum (nullable, non-nullable default is 0)
* join: array is joined by separator option (defaults to comma)
* float: converts to Float (nullable, non-nullable default is 0.0f)
* function: custom lambda function (input is the resolved value, output of lambda will be used resolved value)
* pluck_join: map the sub-property (sub_property option) then join them with separator (defaults to comma)
* pluck_split: array is split by separator option (defaults to comma), then new object (object_class option) is created and sub-property (sub_property option) set.
* split: array is split by separator option (defaults to comma)
* string: calls to_s method on the value

### Pluck Join / Pluck Split Explained

Pluck join and pluck split comes in handy when you have an array of objects and would like to:

* map one value from each object and join it (in order to output in a CSV)
* take a string value, split it, the map each value to a new object (in order to parse as objects)

Take this input and configuration for example:

````ruby
objects = [
  {
    id: 1,
    name:     { first: 'Matt' },
    demo:     { dob: '1901-02-03' },
    contact:  { phone: '555-555-5555' },
    children: [ { id: 9, name: 'Spunky' }, { id: 10, name: 'Dunker' } ]
  },
  {
    id: 2,
    name:     { first: 'Nick' },
    demo:     { dob: '1921-09-03' },
    contact:  { phone: '444-444-4444' },
    children: [ { id: 11, name: 'Bonzi' }, { id: 12, name: 'Buddy' } ]
  },
  {
    id: 3,
    name:     { first: 'Sam' },
    demo:     { dob: '1932-12-12' },
    contact:  { phone: '333-333-3333' }
  }
]

columns = {
  'ID #': {
    property: :id,
    to_object: :integer
  },
  'Children ID #s': {
    property: :children,
    to_csv: { type: :pluck_join, separator: ';', sub_property: :id },
    to_object: { type: :pluck_split, separator: ';', sub_property: :id },
  }
}
````

Generating a CSV:

````ruby
csv = Bumblebee::Template.new(columns: columns).generate(objects)
````

would output:

ID # | Children ID #s
---- | --------------
1    | 9;10
2    | 11;12

Parsing a CSV:

````ruby
objects = Bumblebee::Template.new(columns: columns).parse(csv)
````

would output:

````ruby
objects = [
  {
    id: 1,
    children: [ { id: 9 }, { id: 10 } ]
  },
  {
    id: 2,
    children: [ { id: 11 }, { id: 12 } ]
  },
  {
    id: 3
  }
]
````

### Parsing Into Custom Classes

Hash is the default return type when parsing a CSV.  You can change this by providing a Hash-like class:

````ruby
objects = Bumblebee::Template.new(columns: columns, object_class: OpenStruct).parse(csv)
````

Objects will now be an array of OpenStruct objects instead of Hash objects.

* Note: you must also specify this in pluck_split:

````ruby
columns = {
  'ID #': {
    property: :id,
    to_object: :integer
  },
  'Children ID #s': {
    property: :children,
    to_csv: { type: :pluck_join, separator: ';', sub_property: :id },
    to_object: { type: :pluck_split, separator: ';', sub_property: :id, object_class: OpenStruct },
  }
}
````

#### Further CSV Customization

The two main methods:

* Template#generate
* Template#parse

also accept custom options that [Ruby's CSV::new](https://ruby-doc.org/stdlib-2.6/libdoc/csv/rdoc/CSV.html#method-c-new) accepts.  The only caveat is that Bumblebee needs headers for its mapping, so it overrides the header options.

#### Template DSL

You can choose to pass in a block for template/column specification if you would rather prefer a code-first approach over a configuration-first approach.

##### Using Blocks

````ruby
csv = Bumblebee::Template.new do |t|
  t.column 'ID #',        property: :id,
                          to_object: :integer

  t.column 'First Name',  property: :first,
                          through: :name
end.generate(objects)

objects = Bumblebee::Template.new do |t|
  t.column 'ID #',        property: :id,
                          to_object: :integer

  t.column 'First Name',  property: :first,
                          through: :name
end.parse(data)
````

##### Subclassing ::Bumblebee::Template

Another option is to subclass Template and declare your columns at the class-level:

````ruby
class PersonTemplate < Bumblebee::Template
  column 'ID #',        property: :id,
                        to_object: :integer

  column 'First Name',  property: :first,
                        through: :name,
                        to_object: :pluck_split
end

template  = PersonTemplate.new
csv       = template.generate(objects)
objects   = template.parse(data)
````

##### Column Precedence

The preceding examples showed three ways to declare columns, and each is additive to the next (in the following order):

1. Class level (parent-first)
2. Argument level (passed into constructor)
3. Block level

To illustrate all three:

````ruby
class PersonTemplate < Bumblebee::Template # first
  column 'ID #',        property: :id,
                        to_object: :integer

  column 'First Name',  property: :first,
                        through: :name,
                        to_object: :pluck_split
end

columns = {
  'Middle Name': {
    property: :middle
  }
}

template  = PersonTemplate.new(columns: columns) do |t| # second
  t.column 'Last Name', property: :last # third
end

````

When executed to generate a CSV, the columns would be (in order): ```ID #, First Name, Middle Name, Last Name.```

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check bumblebee.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/bumblebee.git)
4. Navigate to the root folder (cd bumblebee)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````
bundle exec guard
````

Also, do not forget to run Rubocop:

````
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update ```lib/bumblebee/version.rb``` using [semantic versioning](https://semver.org/)
3. Install dependencies: ```bundle```
4. Update ```CHANGELOG.md``` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Build the project locally: `gem build bumblebee`
7. Publish package to RubyGems: `gem push bumblebee-X.gem` where X is the version to push
8. Tag master with new version: `git tag <version>`
9. Push tags remotely: `git push origin --tags`

## License

This project is MIT Licensed.
