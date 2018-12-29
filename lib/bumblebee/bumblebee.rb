# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'csv'
require 'acts_as_hashable'
require 'ostruct'

require_relative 'column'
require_relative 'template'

# The top-level module provides the two main methods for convenience.
# You can also consume these in a more OOP way using the Template class or a more
# procedural way using these.
module Bumblebee
  class << self
    def generate_csv(columns, objects, options = {})
      ::Bumblebee::Template.new(columns).generate_csv(objects, options)
    end

    def parse_csv(columns, string, options = {})
      ::Bumblebee::Template.new(columns).parse_csv(string, options)
    end
  end
end
