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
    # Two signatures for consumption:
    #
    # ::Bumblebee.generate_csv(columns = [], objects = [], options = {})
    #
    # or
    #
    # ::Bumblebee.generate_csv(objects = [], options = {}) do |t|
    #   t.column :id, header: 'ID #'
    #   t.column :first, header: 'First Name'
    # end
    def generate_csv(*args, &block)
      if block_given?
        objects = args[0] || []
        options = args[1] || {}
      else
        objects = args[1] || []
        options = args[2] || {}
      end

      template(args, &block).generate_csv(objects, options)
    end

    # Two signatures for consumption:
    #
    # ::Bumblebee.parse_csv(columns = [], string = '', options = {})
    #
    # or
    #
    # ::Bumblebee.parse_csv(string = '', options = {}) do |t|
    #   t.column :id, header: 'ID #'
    #   t.column :first, header: 'First Name'
    # end
    def parse_csv(*args, &block)
      if block_given?
        string  = args[0] || ''
        options = args[1] || {}
      else
        string  = args[1] || ''
        options = args[2] || {}
      end

      template(args, &block).parse_csv(string, options)
    end

    private

    def template(args, &block)
      columns = block_given? ? [] : (args[0] || [])

      ::Bumblebee::Template.new(columns, &block)
    end
  end
end
