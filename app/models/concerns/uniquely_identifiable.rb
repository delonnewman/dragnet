module UniquelyIdentifiable
  extend ActiveSupport::Concern

  class_methods do
    def find_by_short_id!(short_id)
      find_by!(id: ShortUUID.expand(short_id))
    end
  end

  def short_id
    ShortUUID.shorten(id)
  end
end
