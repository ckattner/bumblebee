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
      @to_csv       = ::Bumblebee::Mutator.new(to_csv)
      @to_object    = ::Bumblebee::Mutator.new(to_object)

      freeze
    end

    # Extract from object and set on hash
    def csv_set(data_object, hash)
      value = extract(traverse(data_object), property)

      to_csv.set(hash, header, value)
    end

    def object_set(csv_object, hash)
      pointer = build(hash)
      value   = csv_object[header]

      to_object.set(pointer, property, value)

      hash
    end

    private

    def traverse(object)
      ::Bumblebee::ObjectInterface.traverse(object, through)
    end

    def extract(object, key)
      ::Bumblebee::ObjectInterface.get(object, key)
    end

    def build(object)
      ::Bumblebee::ObjectInterface.build(object, through)
    end
  end
end
