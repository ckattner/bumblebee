# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # A Mutator is a composition of a converter with hash value setting.  It can be a straight
  # converter, or it can be new types which are not directly defined as 'converters.'
  class Mutator
    module Types
      IGNORE = :ignore
    end
    include Types

    attr_reader :converter, :type

    def initialize(arg)
      @resolver = Objectable.resolver
      @converter = arg.nil? || mutator?(arg) ? NullConverter.new : SimpleConverter.new(arg)
      @type      = mutator?(arg) ? Types.const_get(arg.to_s.upcase.to_sym) : nil

      freeze
    end

    def set(object, key, val)
      return object if ignore?

      resolver.set(object, key, converter.convert(val))
    end

    private

    attr_reader :resolver

    def ignore?
      type == IGNORE
    end

    def mutator?(arg)
      return false unless arg.is_a?(String) || arg.is_a?(Symbol)

      Types.constants.include?(arg.to_s.upcase.to_sym)
    end
  end
end
