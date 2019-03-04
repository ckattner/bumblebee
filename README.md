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
columns = [
  { field: :id },
  { field: :name },
  { field: :dob },
  { field: :phone }
]
````

We could parse this data and turn it into hashes:

````ruby
objects = Bumblebee.parse_csv(columns, data)
````

Then `objects` is this array of hashes:

````ruby
[
  { id: '1', name: 'Matt', dob: '2/3/01',   phone: '555-555-5555' },
  { id: '2', name: 'Nick', dob: '9/3/21',   phone: '444-444-4444' },
  { id: '3', name: 'Sam',  dob: '12/12/32', phone: '333-333-3333' }
]
````

*Note: Data, in this case, would be the read CSV file contents in string format.*

### Custom Headers

If our headers are not a perfect 1:1 match to our object, such as:

ID # | First Name | Date of Birth | Phone #
---- | ---------- | ------------- | ------------
1    | Matt       | 1901-02-03    | 555-555-5555
2    | Nick       | 1921-09-03    | 444-444-4444
3    | Sam        | 1932-12-12    | 333-333-3333

Then we can explicitly map those as:

````ruby
columns = [
  { field: :id,     header: 'ID #' },
  { field: :name,   header: 'First Name' },
  { field: :dob,    header: 'Date of Birth' },
  { field: :phone,  header: 'Phone #' }
]
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
columns = [
  { field: :id,                 header: 'ID #' },
  { field: [:name, :first],     header: 'First Name' },
  { field: [:demo, :dob],       header: 'Date of Birth' },
  { field: [:contact, :phone],  header: 'Phone #' }
]
````

And executing the following:

````ruby
csv = Bumblebee.generate_csv(columns, objects)
````

The above columns config would work both ways, so if we received the CSV, we could parse it to an array of nested hashes.  Unfortunately, for now, we cannot do better than an array of nested hashes.

### Custom To CSV Formatting

You can also pass in functions that can do the value formatting.  For example:

````ruby
columns = [
  {
    field: :id,
    header: 'ID #'
  },
  {
    field: :name,
    header: 'First Name',
    to_csv: [:name, :first, ->(o) { o.to_s.upcase }]
  },
  {
    field: :dob,
    header: 'Date of Birth',
    to_csv: [:demo, :dob]
  },
  {
    field: :phone,
    header: 'Phone #',
    to_csv: [:contact, :phone]
  }
]
````

would ensure the CSV has only upper-case `First Name` values.

### Custom To Object Formatting

You can also choose a custom method how the CSV's value is parsed just like you can customize how values are set for a CSV.  This helps function as an intermediate extractor/formatter/converter, in theory, should be able to give you alot more custom control over the parsing.

A previous example above showed a custom nested object-to-csv flow.  This time, let's go csv-to-object with this dataset:

ID # | First Name | Date of Birth | Phone #
---- | ---------- | ------------- | ------------
1    | Matt       | 1901-02-03    | 555-555-5555
2    | Nick       | 1921-09-03    | 444-444-4444
3    | Sam        | 1932-12-12    | 333-333-3333

Using the following column config:

````ruby
columns = [
  {
    field: :id,
    header: 'ID #',
    to_object: ->(o) { o['ID #'].to_i }
  },
  {
    field: :name,
    header: 'First Name',
    to_csv: %i[name first],
    to_object: ->(o) { { first: o['First Name'] } }
  },
  { field: :demo,
    header: 'Date of Birth',
    to_csv: %i[demo dob],
    to_object: ->(o) { { dob: o['Date of Birth'] } }
  },
  { field: :contact,
    header: 'Phone #',
    to_csv: %i[contact phone],
    to_object: ->(o) { { phone: o['Phone #'] } }
  }
]
````

Executing the following:

````ruby
objects = Bumblebee.parse_csv(columns, data)
````

Would give us the following:

````ruby
objects = [
  {
    id: 1,
    name: { first: 'Matt' },
    demo: { dob: '1901-02-03' },
    contact: { phone: '555-555-5555' }
  },
  {
    id: 2,
    name: { first: 'Nick' },
    demo: { dob: '1921-09-03' },
    contact: { phone: '444-444-4444' }
  },
  {
    id: 3,
    name: { first: 'Sam' },
    demo: { dob: '1932-12-12' },
    contact: { phone: '333-333-3333' }
  }
]
````

#### Further CSV Customization

The two main methods:

* generate_csv
* parse_csv

also accept custom options that [Ruby's CSV::new](https://ruby-doc.org/stdlib-2.6/libdoc/csv/rdoc/CSV.html#method-c-new) accepts.  The only caveat is that Bumblebee needs headers for its mapping, so it overrides the header options.

#### Template DSL

You can choose to pass in a block for template/column specification if you would rather prefer a code-first approach over a configuration-first approach.

##### Using Blocks

````ruby
csv = Bumblebee.generate_csv(objects) do |t|
  t.column :id,    header: 'ID #',
                   to_object: ->(o) { o['ID #'].to_i }

  t.column :first, header: 'First Name',
                   to_csv: %i[name first],
                   to_object: ->(o) { { first: o['First Name'] } }
end

objects = Bumblebee.parse_csv(data) do |t|
  t.column :id,    header: 'ID #',
                   to_object: ->(o) { o['ID #'].to_i }

  t.column :first, header: 'First Name',
                   to_csv: %i[name first],
                   to_object: ->(o) { { first: o['First Name'] } }
end
````

##### Interacting Directly With ::Bumblebee::Template

You can also choose to interact/build templates directly instead of going through the top-level API:

````ruby
template = Bumblebee::Template.new(columns)

# or

template = Bumblebee::Template.new do |t|
  t.column :id,    header: 'ID #',
                   to_object: ->(o) { o['ID #'].to_i }

  t.column :first, header: 'First Name',
                   to_csv: %i[name first],
                   to_object: ->(o) { { first: o['First Name'] } }
end
````

Template class has the same top-level methods:

````ruby
csv = template.generate_csv(objects)

objects = template.parse_csv(data)
````

##### Subclassing ::Bumblebee::Template

Another option is to subclass Template and declare your columns at the class-level:

````ruby
class PersonTemplate < Bumblebee::Template
  column :id,    header: 'ID #',
                 to_object: ->(o) { o['ID #'].to_i }

  column :first, header: 'First Name',
                 to_csv: %i[name first],
                 to_object: ->(o) { { first: o['First Name'] } }
end

# Usage

template  = PersonTemplate.new
csv       = template.generate_csv(objects)
objects   = template.parse_csv(data)
````

##### Column Precedence

The preceding examples showed three ways to declare columns, and each is additive to the next (in the following order):

1. Class level (parent-first)
2. Argument level (passed into constructor)
3. Block level

To illustrate all three:

````ruby
class PersonTemplate < Bumblebee::Template # first
  column :id,    header: 'ID #',
                 to_object: ->(o) { o['ID #'].to_i }

  column :first, header: 'First Name',
                 to_csv: %i[name first],
                 to_object: ->(o) { { first: o['First Name'] } }
end

# Usage

template  = PersonTemplate.new({ field: :middle, header: 'Middle Name' }) do |t| # second
  t.column :last, header: 'Last Name' # third
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
