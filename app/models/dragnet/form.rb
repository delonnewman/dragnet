module Dragnet
  class Form < Survey
    has_many :records, class_name: 'Dragnet::Reply', dependent: :restrict_with_error, inverse_of: :survey
  end

  def no_data?
    survey.replies.empty?
  end
end
