# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Bumblebee::Template do
  let(:field) { :id }
  let(:opts) { { header: 'ID #' } }

  context 'with a blank template' do
    let(:template) { ::Bumblebee::Template.new }

    subject { template }

    it '#column should add a column' do
      subject.column(field, opts)

      expect(subject.columns.length).to eq(1)
      expect(subject.columns.first.field).to eq(field)
      expect(subject.columns.first.header).to eq(opts[:header])
    end
  end

  describe '#initialize' do
    specify 'that initialization accepts a block (with arity) for column creation' do
      template = ::Bumblebee::Template.new do |t|
        t.column field, opts
      end

      expect(template.columns.length).to eq(1)
      expect(template.columns.first.field).to eq(field)
      expect(template.columns.first.header).to eq(opts[:header])
    end

    specify 'that initialization accepts a block (without arity) for column creation' do
      template = ::Bumblebee::Template.new do
        column :id, header: 'ID #'
      end

      expect(template.columns.length).to eq(1)
      expect(template.columns.first.field).to eq(field)
      expect(template.columns.first.header).to eq(opts[:header])
    end
  end
end
