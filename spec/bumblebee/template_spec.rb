# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'examples/person_template'
require 'examples/simple_object'

describe ::Bumblebee::Template do
  describe 'array/string-based columns and symbol based object keys' do
    let(:data_objects) { yaml_fixture('simple', 'data.yml').map(&:symbolize_keys) }

    let(:csv_file) { fixture('simple', 'data.csv') }

    let(:columns) { yaml_fixture('simple', 'columns.yml') }

    subject { ::Bumblebee::Template.new(columns: columns) }

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      actual = actual.map(&:symbolize_keys)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'array/string-based columns and OpenStruct objects' do
    let(:data_objects) do
      yaml_fixture('simple', 'data.yml').map { |h| OpenStruct.new(h.symbolize_keys) }
    end

    let(:csv_file) { fixture('simple', 'data.csv') }

    let(:columns) { yaml_fixture('simple', 'columns.yml') }

    subject { ::Bumblebee::Template.new(columns: columns, object_class: OpenStruct) }

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'array/string-based columns and custom objects' do
    let(:data_objects) do
      yaml_fixture('simple', 'data.yml').map { |h| SimpleObject.new(h.symbolize_keys) }
    end

    let(:csv_file) { fixture('simple', 'data.csv') }

    let(:columns) { yaml_fixture('simple', 'columns.yml') }

    subject { ::Bumblebee::Template.new(columns: columns, object_class: SimpleObject) }

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'config-based columns' do
    let(:data_objects) { yaml_fixture('registrations', 'data.yml') }

    let(:csv_file) { fixture('registrations', 'data.csv') }

    let(:columns) { yaml_fixture('registrations', 'columns.yml') }

    subject { ::Bumblebee::Template.new(columns: columns) }

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'block-based (with local context) columns' do
    let(:data_objects) { yaml_fixture('registrations', 'data.yml') }

    let(:csv_file) { fixture('registrations', 'data.csv') }

    let(:columns) { yaml_fixture('registrations', 'columns.yml') }

    subject do
      ::Bumblebee::Template.new do |t|
        columns.each do |header, opts|
          t.column(header, opts)
        end
      end
    end

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'block-based (without local context) columns' do
    let(:data_objects) { yaml_fixture('registrations', 'data.yml') }

    let(:csv_file) { fixture('registrations', 'data.csv') }

    subject do
      ::Bumblebee::Template.new do
        columns = yaml_fixture('registrations', 'columns.yml')
        columns.each do |header, opts|
          column(header, opts)
        end
      end
    end

    specify '#generate_csv properly builds a CSV-formatted string' do
      actual = subject.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      actual = subject.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end

  describe 'class-based columns' do
    let(:data_objects) { yaml_fixture('people', 'data.yml') }

    let(:csv_file) { fixture('people', 'data.csv') }

    subject { PersonTemplate.new }

    specify '#generate_csv properly builds a CSV-formatted string' do
      template = PersonTemplate.new

      actual = template.generate(data_objects)

      expect(actual).to eq(csv_file)
    end

    specify '#parse_csv properly builds objects' do
      template = PersonTemplate.new

      actual = template.parse(csv_file)

      expect(actual).to eq(data_objects)
    end
  end
end
