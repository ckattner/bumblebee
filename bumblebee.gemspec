# frozen_string_literal: true

require './lib/bumblebee/version'

Gem::Specification.new do |s|
  s.name        = 'bumblebee'
  s.version     = Bumblebee::VERSION
  s.summary     = 'Object/CSV Mapper'

  s.description = <<-DESCRIPTION
    Higher level languages, such as Ruby, make interacting with CSVs trivial.
    Even so, this library provides a very simple object/csv mapper that allows you to fully interact with CSVs in a declarative way.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/bumblebee'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.1'

  s.add_dependency('acts_as_hashable', '~>1.0')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rubocop', '~> 0.59')
end
