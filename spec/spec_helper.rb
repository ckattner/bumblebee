# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'stringio'
require 'pry'

require 'simplecov'
require 'simplecov-console'
SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start

require './lib/bumblebee'

def fixture_path(filename)
  File.join('spec', 'fixtures', filename)
end

def fixture(filename)
  # Excel adds a Byte Order Mark to the beginning of the file. Let Ruby
  # know about this so that the first 'id' column is correctly parsed.
  # More info about the Excel Byte Order Mark and Ruby is available at:
  # https://estl.tech/of-ruby-and-hidden-csv-characters-ef482c679b35 .
  file = File.open(fixture_path(filename), 'r:bom|utf-8')

  file.read
end
