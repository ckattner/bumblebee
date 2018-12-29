# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # This is main piece of logic that defines a column which can go from objects to csv cell values
  # and csv rows to objects.
  class Column
    acts_as_hashable

    attr_reader :field,
                :to_object,
                :header,
                :to_csv

    def initialize(field:, header: nil, to_csv: nil, to_object: nil)
      raise ArgumentError, 'field is required' unless field

      @field      = field
      @header     = make_header(header || field)
      @to_csv     = Array(to_csv || field)
      @to_object  = Array(to_object || field)
    end

    # Take a object and convert to a value.
    def object_to_csv(object)
      val = object

      # Iterate over keys until we reach a nil or the end of keys.
      to_csv.each do |f|
        # short-circuit out of the extract method
        return nil unless val

        val = single_extract(val, f)
      end

      val
    end

    def csv_to_object(csv_hash)
      return nil unless csv_hash

      value   = csv_hash[header]
      pointer = hash = {}

      to_object[0..-2].each do |f|
        if f.is_a?(Proc)
          value = f.call(value)
        else
          pointer = pointer[f] = {}
        end
      end

      pointer[to_object[-1]] = value

      hash
    end

    private

    # Loop through all values, contcatenating their string equivalent with an underscore.
    # Since we allow procs, but we want deterministic headers, we will simply transform
    # theem to _proc_.  This is not perfect and could create naming clashes, but it really
    # should not be.  You should really leave proc's out of header and field.
    def make_header(value)
      Array(value).map do |v|
        if v.is_a?(Proc)
          'proc'
        else
          v.to_s
        end
      end.join('_')
    end

    # Take an object and attempt to extract a value from it.
    # First, see if the key is a proc, if so, then delegate to the proc.
    # Next, see if the object responds to the key, if so, then call it.
    # Lastly, see if it responds to brackets, if so, then call the brackets method sending
    # in the key.
    # Finally if all else fails, return nil.
    def single_extract(object, key)
      if key.is_a?(Proc)
        key.call(object)
      elsif object.respond_to?(key)
        object.send(key)
      elsif object.respond_to?(:[])
        object[key]
      end
    end
  end
end
