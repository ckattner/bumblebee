# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Bumblebee::SimpleConverter do
  let(:test_cases) do
    [
      {
        arg: {
          type: :bigdecimal,
          nullable: true
        },
        convert_cases: [
          [nil, nil],
          ['', nil],
          [6, BigDecimal(6)],
          [BigDecimal('12'), BigDecimal(12)],
          ['24.35', BigDecimal('24.35')]
        ]
      },
      {
        arg: {
          type: :bigdecimal,
          nullable: false
        },
        convert_cases: [
          [nil, BigDecimal(0)],
          ['', BigDecimal(0)]
        ]
      },
      {
        arg: {
          type: :boolean,
          nullable: true
        },
        convert_cases: [
          [nil, nil],
          [true, true],
          ['t', true],
          ['true', true],
          ['TRUE', true],
          ['True', true],
          ['1', true],
          ['Y', true],
          ['y', true],
          ['yes', true],
          ['YES', true],
          ['Yes', true],
          [false, false],
          ['f', false],
          ['false', false],
          ['FALSE', false],
          ['False', false],
          ['0', false],
          ['N', false],
          ['n', false],
          ['no', false],
          ['NO', false],
          ['No', false]
        ]
      },
      {
        arg: {
          type: :boolean,
          nullable: false
        },
        convert_cases: [
          [nil, false],
          ['', false]
        ]
      },
      {
        arg: {
          type: :float,
          nullable: true
        },
        convert_cases: [
          [nil, nil],
          ['', nil],
          [6, 6.to_f],
          [6.0, 6.0.to_f],
          ['24.35', '24.35'.to_f]
        ]
      },
      {
        arg: {
          type: :float,
          nullable: false
        },
        convert_cases: [
          [nil, 0.0],
          ['', 0.0]
        ]
      }
    ]
  end

  specify 'each #convert test case' do
    test_cases.each do |test_case|
      converter = ::Bumblebee::SimpleConverter.new(test_case[:arg])

      test_case[:convert_cases].each do |convert_case|
        input = convert_case.first
        output = convert_case.last

        expect(converter.convert(input)).to eq(output)
        expect(converter.convert(input).class).to eq(output.class)
      end
    end
  end
end
