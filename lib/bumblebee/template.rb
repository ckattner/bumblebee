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
  # parse_csv: take in a string and return an array of OpenStruct objects
  class Template
    attr_reader :columns

    def initialize(columns = [])
      @columns = ::Bumblebee::Column.array(columns)
    end

    # Return array of strings (headers)
    def headers
      columns.map(&:header)
    end

    def generate_csv(objects, options = {})
      objects = objects.is_a?(Hash) ? [objects] : Array(objects)

      write_options = options.merge(headers: headers, write_headers: true)

      CSV.generate(write_options) do |csv|
        objects.each do |object|
          row = columns.map { |column| column.object_to_csv(object) }

          csv << row
        end
      end
    end

    def parse_csv(string, options = {})
      csv = CSV.new(string, options.merge(headers: true))

      # Drop the first record, it is the header record
      csv.to_a.map do |row|
        # Build up a hash using the column one at a time
        extracted_hash = columns.inject({}) do |hash, column|
          hash.merge(column.csv_to_object(row))
        end

        extracted_hash
      end
    end
  end
end
