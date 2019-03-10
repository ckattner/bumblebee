# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class SimpleObject
  attr_accessor :id, :name, :dob, :phone

  def initialize(id: nil, name: '', dob: nil, phone: '')
    @id     = id
    @name   = name
    @dob    = dob
    @phone  = phone
  end

  def eql?(other)
    id == other.id && name == other.name && dob == other.dob && phone == other.phone
  end

  def ==(other)
    eql?(other)
  end
end
