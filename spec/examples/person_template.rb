# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class PersonTemplate < ::Bumblebee::Template
  column 'ID #',            property: 'id',
                            to_object: :integer

  column 'First Name',      property: 'first',
                            through: 'demo'

  column 'Last Name',       property: 'last',
                            through: 'demo'

  column 'Street 1',        property: 'street1',
                            through: %w[demo address]

  column 'Street 2',        property: 'street2',
                            through: %w[demo address]

  column 'City',            property: 'city',
                            through: %w[demo address]

  column 'State',           property: 'st',
                            through: %w[demo address]

  column 'Zipcode',         property: 'zip',
                            through: %w[demo address]

  column 'Current',         property: 'current',
                            through: %w[demo address],
                            to_object: :boolean

  column 'Home #',          property: 'home',
                            through: 'contact'

  column 'Fax #',           property: 'fax',
                            through: 'contact'

  column 'Email Address',   property: 'email',
                            through: 'contact'

  column 'Smokes',          property: 'smoker',
                            to_object: :boolean

  column 'Current Balance', property: 'balance',
                            to_object: :bigdecimal

  column 'Visits',          property: 'visit_dates',
                            to_csv: { type: :join, separator: ';', per: :string },
                            to_object: { type: :split, separator: ';', per: :date }

  column 'Family Members',  property: 'family_members',
                            to_csv: { type: :pluck_join, sub_property: 'id' },
                            to_object: { type: :pluck_split, sub_property: 'id', per: :integer }

  column 'Email Address Domain', property: 'email',
                                 through: 'contact',
                                 to_csv: ->(email) { email.to_s.split('@').last },
                                 to_object: :ignore
end
