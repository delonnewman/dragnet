module Dragnet
  module Survey::EditsExtension
    def latest
      not_applied.order(created_at: :desc).first
    end
    
    def merge
      reduce(proxy_association.owner.projection) do |projection, edit| 
        edit.op.merge(edit, projection)
      end
    end

    def merged_attributes
      Survey::AttributeProjection.new(merge).to_h
    end

    def apply(timestamp = Time.zone.now)
      updates = merged_attributes
      updates[:questions_attributes].each { |q| q.delete(:id) if q[:id].to_i < 0 }

      # survey.edited.validate!(:application)
      Survey.transaction do
        proxy_association.owner.update!(updates)
        each { |edit| edit.apply!(timestamp) }
        Survey::EditingStatus.published!(proxy_association.owner)
      end
    end
  end
end
