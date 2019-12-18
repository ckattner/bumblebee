# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Defines a class-level interace for specifying columns.
  module ColumnDsl
    extend Forwardable

    def_delegators :column_set, :columns

    def column_set
      @column_set ||= ColumnSet.new
    end

    def column(header, opts = {})
      column_set.column(header, opts)

      self
    end

    def all_column_sets
      # the reverse preserves the order of inheritance to go from parent -> child
      ancestors.reverse_each.with_object(ColumnSet.new) do |ancestor, set|
        ancestor < Template ? set.add(ancestor.columns) : set
      end
    end

    def all_columns
      all_column_sets.columns
    end
  end
end
