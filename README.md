# Bumblebee

[![Build Status](https://travis-ci.org/bluemarblepayroll/bumblebee.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/bumblebee)

Higher level languages, such as Ruby, make interacting with CSV (Comma Separated Values) files trivial. Even so, this library provides a very simple object/CSV mapper that allows you to fully interact with CSV's in a declarative way.  Locking in common patterns, even in higher level languages, is important in large codebases.  Using a library, such as this, will help ensure standardization around CSV interaction.

However, there are situations where this level of abstraciton may not be appropriate.  For example, this library is not meant to be extremely performant given large files and/or datasets.  This library shines with CSV and/or data-sets of less than 100,000 records (approx).

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

### Custom Formatting

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

#### Further CSV Customization

The two main methods:

* generate_csv
* parse_csv

also accept custom options that [Ruby's CSV::new](https://ruby-doc.org/stdlib-2.6/libdoc/csv/rdoc/CSV.html#method-c-new) accepts.  The only caveat is that Bumblebee needs headers for its mapping, so it overrides the header options.

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
