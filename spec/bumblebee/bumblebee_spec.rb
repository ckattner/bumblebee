# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'
require 'stringio'

describe ::Bumblebee do
  let(:columns) do
    [
      { field: :name },
      { field: :dob }
    ]
  end

  let(:reverse_columns) do
    [
      { field: :dob },
      { field: :name }
    ]
  end

  let(:people) do
    [
      { name: 'Matt', dob: '1901-01-03' },
      { name: 'Nathan', dob: '1931-09-03' }
    ]
  end

  let(:csv) { "name,dob\nMatt,1901-01-03\nNathan,1931-09-03\n" }

  let(:quoted_csv) { "\"name\",\"dob\"\n\"Matt\",\"1901-01-03\"\n\"Nathan\",\"1931-09-03\"\n" }

  it 'should generate a csv' do
    actual = Bumblebee.generate_csv(columns, people)

    expect(actual).to eq(csv)
  end

  it 'should generate a csv and accept options' do
    options = {
      force_quotes: true
    }

    actual = ::Bumblebee.generate_csv(columns, people, options)

    expect(actual).to eq(quoted_csv)
  end

  it 'should parse a csv' do
    objects = Bumblebee.parse_csv(columns, csv)

    expect(objects).to eq(people)
  end

  it 'should parse a csv with columns in different order than headers' do
    objects = ::Bumblebee.parse_csv(reverse_columns, csv)

    expect(objects).to eq(people)
  end

  describe 'README examples' do
    let(:columns) do
      [
        { field: :id },
        { field: :name },
        { field: :dob },
        { field: :phone }
      ]
    end

    let(:data) do
      path = File.expand_path('fixtures/simple_readme_example.csv', __dir__)

      # Excel adds a Byte Order Mark to the beginning of the file. Let Ruby
      # know about this so that the first 'id' column is correctly parsed.
      # More info about the Excel Byte Order Mark and Ruby is available at:
      # https://estl.tech/of-ruby-and-hidden-csv-characters-ef482c679b35 .
      file = File.open(path, 'r:bom|utf-8')
      file.read
    end

    let(:output) do
      [
        { id: '1', name: 'Matt', dob: '2/3/01',   phone: '555-555-5555' },
        { id: '2', name: 'Nick', dob: '9/3/21',   phone: '444-444-4444' },
        { id: '3', name: 'Sam',  dob: '12/12/32', phone: '333-333-3333' }
      ]
    end

    specify 'the simple 1:1 example works as advertised' do
      expect(Bumblebee.parse_csv(columns, data)).to eq output
    end
  end
end
