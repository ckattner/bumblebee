# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require './spec/examples/converter_test_case'

describe Bumblebee::SimpleConverter do
  describe '#convert' do
    ConverterTestCase.all.each do |test_case|
      it "should convert: #{test_case.arg}" do
        converter = Bumblebee::SimpleConverter.new(test_case.arg)

        test_case.convert_cases.each do |convert_case|
          input = convert_case.first
          output = convert_case.last

          expect(converter.convert(input)).to eq(output)
          expect(converter.convert(input).class).to eq(output.class)
        end
      end
    end
  end
end
