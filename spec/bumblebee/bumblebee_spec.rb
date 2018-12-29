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

  let(:people) do
    [
      { name: 'Matt', dob: '1901-01-03' },
      { name: 'Nathan', dob: '1931-09-03' }
    ]
  end

  let(:csv) { "name,dob\nMatt,1901-01-03\nNathan,1931-09-03\n" }

  let(:quoted_csv) { "\"name\",\"dob\"\n\"Matt\",\"1901-01-03\"\n\"Nathan\",\"1931-09-03\"\n" }

  it 'should generate a csv' do
    actual = ::Bumblebee.generate_csv(columns, people)

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
    objects = ::Bumblebee.parse_csv(columns, csv)

    expect(objects).to eq(people)
  end
end
