# frozen_string_literal: true

class Dragnet::Survey
  module Copying
    extend ActiveSupport::Concern

    included do
      belongs_to :copy_of, class_name: 'Dragnet::Survey', optional: true
      accepts_nested_attributes_for :copy_of,
                                    update_only: true,
                                    reject_if: ->(attrs) { attrs.compact_blank!.empty? }

      has_many :copies,
               foreign_key: 'copy_of_id',
               class_name: 'Dragnet::Survey',
               dependent: :nullify,
               inverse_of: :copy_of
    end

    def copy?
      !!copy_of_id
    end

    # @return [Survey, false]
    def copy!
      copy = Copy.new(self)
      return copy if copy.save!

      false
    end
  end
end
