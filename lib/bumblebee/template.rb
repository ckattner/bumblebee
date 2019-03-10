# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Wraps up columns and provides to main methods:
  # generate_csv: take in an array of objects and return a string (CSV contents)
  # parse_csv: take in a string and return an array of hashes
  class Template
    extend Forwardable
    extend ::Bumblebee::ColumnDsl

    def_delegators :column_set, :headers, :columns

    attr_reader :object_class

    def initialize(columns: nil, object_class: Hash, &block)
      @column_set   = ::Bumblebee::ColumnSet.new(self.class.all_columns)
      @object_class = object_class

      column_set.add(columns)

      return unless block_given?

      if block.arity == 1
        yield self
      else
        instance_eval(&block)
      end
    end

    def column(header, opts = {})
      column_set.column(header, opts)

      self
    end

    def generate(objects, options = {})
      objects = objects.is_a?(Hash) ? [objects] : Array(objects)

      write_options = options.merge(headers: headers, write_headers: true)

      CSV.generate(write_options) do |csv|
        objects.each do |object|
          csv << columns.each_with_object({}) do |column, hash|
            column.csv_set(object, hash)
          end
        end
      end
    end

    def parse(string, options = {})
      csv = CSV.new(string, options.merge(headers: true))

      csv.to_a.map do |row|
        # Build up a hash using the column one at a time
        columns.each_with_object(object_class.new) do |column, object|
          column.object_set(row, object)
        end
      end
    end

    private

    attr_reader :column_set
  end
end
