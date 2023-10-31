# frozen_string_literal: true

module Dragnet
  module Retractable
    extend ActiveSupport::Concern

    class_methods do
      def retract_associated(*associations)
        associations.each do |association|
          retractable_associations << association
        end
      end

      def retractable_associations
        @retractable_associations ||= []
      end
    end

    # Assert that this record and any retractable associated records are retracted.
    #
    # @param [Time] timestamp
    #
    # @return [Retractable]
    def retracted!(timestamp = Time.zone.now)
      self.retracted = true
      self.retracted_at = timestamp

      self.class.retractable_associations.each do |association|
        self.public_send(association).each do |record|
          record.retracted!(timestamp)
        end
      end

      self
    end

    # @param [Time] timestamp
    #
    # @return [false, ActiveRecord::Base]
    def retract(timestamp = Time.zone.now)
      retracted!(timestamp).save
    end

    # @param [Time] timestamp
    #
    # @raise ActiveRecord::Invalid
    #
    # @return [ActiveRecord::Base]
    def retract!(timestamp = Time.zone.now)
      retracted!(timestamp).save!
    end
  end
end
