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

    def apply(timestamp = Time.zone.new)
      Survey.transaction do
        proxy_association.owner.update!(merged_attributes)
        each { |edit| edit.apply!(timestamp) }
        Survey::EditingStatus.saved!(survey)
      end
    end
  end
end
