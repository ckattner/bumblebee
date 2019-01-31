# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Bumblebee::Column do
  let(:object) do
    OpenStruct.new(
      name: 'Mattycakes',
      dob: '1921-01-02',
      pizza: 'Pepperoni',
      license: OpenStruct.new(id: '123456')
    )
  end

  let(:hash) do
    {
      name: 'Mattycakes',
      dob: '1921-01-02',
      pizza: 'Pepperoni',
      license: { id: '123456' }
    }
  end

  describe 'initialization' do
    it 'should error if field is nil' do
      expect { ::Bumblebee::Column.new(field: nil) }.to raise_error(ArgumentError)
    end

    it 'should initialize with just a field' do
      field = :name

      column = ::Bumblebee::Column.new(field: field)

      expect(column.field).to     eq(field)
      expect(column.header).to    eq(field.to_s)
      expect(column.to_csv).to    eq([field])
      expect(column.to_object).to  eq([field])
    end

    describe 'header computation' do
      it 'should compute from single field' do
        field = :name

        column = ::Bumblebee::Column.new(field: field)

        expect(column.header).to eq(field.to_s)
      end

      it 'should compute from multiple fields' do
        field = [:name, 'is', :too, 22.4]

        column = ::Bumblebee::Column.new(field: field)

        expect(column.header).to eq(field.map(&:to_s).join('_'))
      end

      it 'should compute from a lambda literal' do
        column = ::Bumblebee::Column.new(field: ->(o) {})
        expect(column.header).to eq('proc')
      end

      it 'should compute from a proc' do
        column = ::Bumblebee::Column.new(field: proc {})
        expect(column.header).to eq('proc')
      end
    end
  end

  describe '#csv_to_object' do
    it 'should correctly extract the value using field' do
      record = {
        'name' => 'Nathan'
      }

      column = ::Bumblebee::Column.new(field: 'name')

      expect(column.csv_to_object(record)).to eq(record)
    end

    it 'should correctly extract the value using header' do
      csv_row = {
        'First Name' => 'Nathan'
      }

      record = {
        'name' => 'Nathan'
      }

      column = ::Bumblebee::Column.new(field: 'name', header: 'First Name')

      expect(column.csv_to_object(csv_row)).to eq(record)
    end

    it 'should correctly extract the value using custom from_csv value' do
      csv_row = {
        'First Name' => 'Nathan'
      }

      record = {
        'First' => 'Nathan'
      }

      column = ::Bumblebee::Column.new(
        field: 'name',
        header: 'First Name',
        to_object: 'First'
      )

      expect(column.csv_to_object(csv_row)).to eq(record)
    end
  end

  describe '#object_to_csv' do
    context 'using field' do
      context 'for single values' do
        it 'should get csv value correctly' do
          column = ::Bumblebee::Column.new(field: :name)

          expect(column.object_to_csv(object)).to eq(object.name)
          expect(column.object_to_csv(hash)).to   eq(hash[:name])
        end

        it 'should return nil when does not exist' do
          column = ::Bumblebee::Column.new(field: :doesnt_exist)

          expect(column.object_to_csv(object)).to eq(nil)
          expect(column.object_to_csv(hash)).to   eq(nil)
        end
      end

      context 'for arrays' do
        it 'should get csv value correctly' do
          column = ::Bumblebee::Column.new(field: %i[license id])

          expect(column.object_to_csv(object)).to eq(object.license.id)
          expect(column.object_to_csv(hash)).to   eq(hash[:license][:id])
        end

        it 'should return nil when it hits dead end at beginning' do
          column = ::Bumblebee::Column.new(field: %i[something that does not exist])

          expect(column.object_to_csv(object)).to eq(nil)
          expect(column.object_to_csv(hash)).to   eq(nil)
        end

        it 'should return nil when it hits dead end in middle' do
          column = ::Bumblebee::Column.new(field: %i[license doesnt_exist here])

          expect(column.object_to_csv(object)).to eq(nil)
          expect(column.object_to_csv(hash)).to   eq(nil)
        end
      end

      context 'when mixing in procs' do
        it 'should get csv value correctly when proc runs against end value' do
          column = ::Bumblebee::Column.new(field: [:license, :id, ->(o) { "# #{o}" }])

          expect(column.object_to_csv(object)).to eq("# #{object.license.id}")
          expect(column.object_to_csv(hash)).to   eq("# #{hash[:license][:id]}")
        end

        it 'should get csv value correctly when proc runs against object-based value' do
          column = ::Bumblebee::Column.new(field: [:license, ->(o) { "# #{o.id}" }])
          expect(column.object_to_csv(object)).to eq("# #{object.license.id}")

          column = ::Bumblebee::Column.new(field: [:license, ->(o) { "# #{o[:id]}" }])
          expect(column.object_to_csv(hash)).to   eq("# #{hash[:license][:id]}")
        end

        it 'should not hit proc if ran against nil' do
          column = ::Bumblebee::Column.new(field: [:doesnt_exist, ->(o) { "# #{o.id}" }])
          expect(column.object_to_csv(object)).to eq(nil)

          column = ::Bumblebee::Column.new(field: [:doesnt_exist, ->(o) { "# #{o[:id]}" }])
          expect(column.object_to_csv(hash)).to eq(nil)
        end
      end
    end
  end
end
