# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Subclass of Converter that provides a simple implementation for each Type.
  class SimpleConverter < ::Bumblebee::Converter
    DEFAULT_DATE = '1900-01-01'
    DEFAULT_BIG_DECIMAL = 0

    private

    def process_pluck_join(val)
      raise ArgumentError, 'sub_property is required for a pluck_join' unless sub_property

      Array(val).map { |h| per.convert(::Bumblebee::ObjectInterface.get(h, sub_property)) }
                .join(separator)
    end

    def process_pluck_split(val)
      raise ArgumentError, 'sub_property is required for a pluck_split' unless sub_property

      process_split(val).map do |v|
        object_class.new.tap { |h| ::Bumblebee::ObjectInterface.set(h, sub_property, v) }
      end
    end

    def process_ignore(_val)
      nil
    end

    def process_join(val)
      Array(val).map { |v| per.convert(v) }.join(separator)
    end

    def process_split(val)
      val.to_s.split(separator).map { |v| per.convert(v) }
    end

    def process_function(val)
      raise ArgumentError, 'function is required for function type' unless function

      function.call(val)
    end

    def process_date(val)
      return nil if nullable? && null_or_empty?(val)

      Date.strptime(null_or_empty_default(val, DEFAULT_DATE).to_s, date_format)
    end

    def process_string(val)
      return nil if nullable? && null_or_empty?(val)

      val.to_s
    end

    def process_integer(val)
      return nil if nullable? && null_or_empty?(val)

      val.to_i
    end

    def process_float(val)
      return nil if nullable? && null_or_empty?(val)

      val.to_f
    end

    def process_bigdecimal(val)
      return nil if nullable? && null_or_empty?(val)

      BigDecimal(null_or_empty_default(val, DEFAULT_BIG_DECIMAL).to_s)
    end

    def process_boolean(val)
      if nullable? && nully?(val)
        nil
      elsif truthy?(val)
        true
      else
        false
      end
    end

    def null_or_empty_default(val, default)
      null_or_empty?(val) ? default : val
    end

    def null_or_empty?(val)
      val.nil? || val.to_s.empty?
    end

    # rubocop:disable Style/DoubleNegation
    def nully?(val)
      null_or_empty?(val) || !!(val.to_s =~ /(nil|null)$/i)
    end

    def truthy?(val)
      !!(val.to_s =~ /(true|t|yes|y|1)$/i)
    end
    # rubocop:enable Style/DoubleNegation
  end
end
