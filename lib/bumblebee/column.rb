# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # This is main piece of logic that defines a column which can go
  # from objects to csv cell values and csv rows to objects.
  class Column
    attr_reader :header,
                :property,
                :through,
                :to_csv,
                :to_object

    def initialize(
      header,
      property: nil,
      through: [],
      to_csv: nil,
      to_object: nil
    )
      raise ArgumentError, 'header is required' if header.to_s.empty?

      @header       = header.to_s
      @property     = property || @header
      @through      = Array(through)

      # We need to ensure the to_csv mutator is not splitting any keys because its hash has already
      # been resolved where each key is the actual presentational value (csv header).
      @to_csv = Mutator.new(to_csv, resolver: Objectable.resolver(separator: ''))

      @to_object    = Mutator.new(to_object)
      @resolver     = Objectable.resolver

      freeze
    end

    # Extract from object and set on hash
    def csv_set(data_object, hash)
      value = resolver.get(data_object, full_property)

      to_csv.set(hash, header, value)
    end

    def object_set(csv_object, hash)
      value = csv_object[header]

      to_object.set(hash, full_property, value)

      hash
    end

    private

    attr_reader :resolver

    def full_property
      through + [property]
    end
  end
end
