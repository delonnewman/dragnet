# frozen_string_literal: true

module Dragnet
  module ConsoleMethods
    def s(survey_id)
      Dragnet::Survey.find(survey_id)
    end

    def u(user_id)
      Dragnet::User.find(user_id)
    end
  end
end
