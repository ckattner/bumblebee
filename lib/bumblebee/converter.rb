# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Base class that defines the general interface and structure for a converter class.
  # Subclasses should use the 'visitor' pattern and imeplement a visit_* method for each of the
  # Types.
  class Converter
    module Types
      BIGDECIMAL  = :bigdecimal
      BOOLEAN     = :boolean
      DATE        = :date
      INTEGER     = :integer
      JOIN        = :join
      FLOAT       = :float
      FUNCTION    = :function
      PLUCK_JOIN  = :pluck_join
      PLUCK_SPLIT = :pluck_split
      SPLIT       = :split
      STRING      = :string
    end
    include Types

    DEFAULT_DATE_FORMAT = '%Y-%m-%d'
    DEFAULT_SEPARATOR   = ','
    VISITOR_METHOD_PREFIX = 'process_'

    private_constant :VISITOR_METHOD_PREFIX

    attr_reader :function,
                :object_class,
                :per,
                :sub_property,
                :type

    def initialize(arg)
      if arg.is_a?(Proc)
        @type         = FUNCTION
        @function     = arg
        @object_class = Hash
      elsif arg.is_a?(Hash)
        hash = arg.symbolize_keys
        initialize_from_hash(hash)
      else
        @type         = make_type(arg)
        @per          = make_converter
        @object_class = Hash
      end

      freeze
    end

    def convert(val)
      send("#{VISITOR_METHOD_PREFIX}#{type}", val)
    end

    private

    def make_type(val)
      Types.const_get(val.to_s.upcase.to_sym)
    end

    def initialize_from_hash(hash)
      @type         = make_type(hash[:type])
      @function     = hash[:function]
      @nullable     = hash[:nullable]
      @separator    = hash[:separator]
      @date_format  = hash[:date_format]
      @sub_property = hash[:sub_property]
      @object_class = hash[:object_class] || Hash
      @per          = make_converter(hash[:per])
    end

    def nullable
      @nullable || false
    end
    alias nullable? nullable

    def separator
      @separator || DEFAULT_SEPARATOR
    end

    def date_format
      @date_format || DEFAULT_DATE_FORMAT
    end

    def make_converter(arg = nil)
      arg ? self.class.new(arg) : ::Bumblebee::NullConverter.new
    end
  end
end
