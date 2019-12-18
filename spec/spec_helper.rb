# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'stringio'
require 'pry'
require 'ostruct'
require 'yaml'

require 'simplecov'
require 'simplecov-console'
SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start

require './lib/bumblebee'

def fixture_path(*filename)
  File.join('spec', 'fixtures', filename)
end

def csv_fixture(*filename)
  CSV.new(fixture(*filename), headers: true).map(&:to_h)
end

def yaml_fixture(*filename)
  # rubocop:disable Security/YAMLLoad
  YAML.load(fixture(*filename))
  # rubocop:enable Security/YAMLLoad
end

def fixture(*filename)
  # Excel adds a Byte Order Mark to the beginning of the file. Let Ruby
  # know about this so that the first 'id' column is correctly parsed.
  # More info about the Excel Byte Order Mark and Ruby is available at:
  # https://estl.tech/of-ruby-and-hidden-csv-characters-ef482c679b35 .
  file = File.open(fixture_path(*filename), 'r:bom|utf-8')

  file.read
end

def manually_convert_csv_object(csv_object, columns)
  csv_object.map do |header, value|
    column = Bumblebee::Column.new(header, columns[header].symbolize_keys)

    converted_value =
      if column.extractor.expect_array?
        value
      else
        column.converter.convert(value)
      end

    [header, converted_value]
  end.to_h
end
