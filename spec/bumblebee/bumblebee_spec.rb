# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

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
    describe 'the simple 1:1 parsing example' do
      let(:data) { fixture('simple_readme_example.csv') }

      let(:columns) do
        [
          { field: 'id' },
          { field: 'name' },
          { field: 'dob' },
          { field: 'phone' }
        ]
      end

      let(:output) do
        [
          { 'id' => '1', 'name' => 'Matt', 'dob' => '2/3/01',   'phone' => '555-555-5555' },
          { 'id' => '2', 'name' => 'Nick', 'dob' => '9/3/21',   'phone' => '444-444-4444' },
          { 'id' => '3', 'name' => 'Sam',  'dob' => '12/12/32', 'phone' => '333-333-3333' }
        ]
      end

      specify 'works as advertised' do
        expect(Bumblebee.parse_csv(columns, data)).to eq output
      end
    end

    describe 'the custom parsing example' do
      let(:data) { fixture('custom_readme_example.csv') }

      let(:columns) do
        [
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
            to_object: ->(o) { { dob: o['Date of Birth'] } } },
          { field: :contact,
            header: 'Phone #',
            to_csv: %i[contact phone],
            to_object: ->(o) { { phone: o['Phone #'] } } }
        ]
      end

      let(:output) do
        [
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
      end

      specify 'works as advertised' do
        expect(Bumblebee.parse_csv(columns, data)).to eq output
      end
    end
  end
end
