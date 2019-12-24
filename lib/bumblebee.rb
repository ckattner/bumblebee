# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'bigdecimal'
require 'csv'
require 'date'
require 'forwardable'
require 'objectable'
require 'set'

# Monkey-patching core libaries
require_relative 'bumblebee/core_ext/hash'
Hash.include Bumblebee::CoreExt::Hash

# Load library
require_relative 'bumblebee/mutator'
require_relative 'bumblebee/null_converter'
require_relative 'bumblebee/converter'
require_relative 'bumblebee/simple_converter'
require_relative 'bumblebee/column'
require_relative 'bumblebee/column_set'
require_relative 'bumblebee/column_dsl'
require_relative 'bumblebee/template'
