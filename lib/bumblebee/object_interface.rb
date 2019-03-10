# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Bumblebee
  # Provides methods for interacting with custom objects.
  class ObjectInterface
    class << self
      def traverse(object, through)
        pointer = object

        through.each do |t|
          next unless pointer

          pointer = get(pointer, t)
        end

        pointer
      end

      def build(object, through)
        pointer = object

        through.each do |t|
          pointer = get(pointer, t) || get(set(pointer, t, pointer.class.new), t)
        end

        pointer
      end

      def set(object, key, val)
        object.tap do |o|
          setter_method = "#{key}="
          if o.respond_to?(setter_method)
            o.send(setter_method, val)
          elsif o.respond_to?(:[])
            o[key] = val
          end
        end
      end

      def get(object, key)
        if object.is_a?(Hash)
          indifferent_hash_get(object, key)
        elsif object.respond_to?(key)
          object.send(key)
        end
      end

      private

      def indifferent_hash_get(hash, key)
        if hash.key?(key.to_s)
          hash[key.to_s]
        elsif hash.key?(key.to_s.to_sym)
          hash[key.to_s.to_sym]
        end
      end
    end
  end
end
