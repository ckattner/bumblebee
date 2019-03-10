# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Maintains a list (dictionary) of columns where each header can only exist once.
  # If columns with same header are re-added, then they are overwritten.
  # This class also provides a factory interface through #add for adding columns
  class ColumnSet
    extend Forwardable

    FACTORY_ADD_METHODS = [
      [::Bumblebee::Column, :assign],
      [Hash, :add_header_column_hash]
    ].freeze

    private_constant :FACTORY_ADD_METHODS

    def_delegator :column_hash, :keys, :headers

    def_delegator :column_hash, :values, :columns

    def initialize(columns = nil)
      @column_hash = {}

      add(columns)
    end

    def column(header, opts = {})
      column = ::Bumblebee::Column.new(header, opts.symbolize_keys)

      column_hash[column.header] = column

      self
    end

    def add(*args)
      args.flatten.compact.each { |arg| factory_add(arg) }

      self
    end

    private

    attr_reader :column_hash

    def assign(column)
      column_hash[column.header] = column

      self
    end

    def add_header_column_hash(hash)
      hash.each_pair do |header, opts|
        column = ::Bumblebee::Column.new(header, opts.symbolize_keys)

        assign(column)
      end

      self
    end

    def factory_add(arg)
      FACTORY_ADD_METHODS.each do |factory_add_method|
        class_constant = factory_add_method.first
        method_sym = factory_add_method.last

        if arg.is_a?(class_constant)
          send(method_sym, arg)
          return self
        end
      end

      # Base case, use arg as the header
      column(arg)
    end
  end
end
