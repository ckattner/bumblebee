# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Base converter using the Null Object Pattern.  Use this when a custom converter is not needed.
  class NullConverter
    def convert(val)
      val
    end
  end
end
