# frozen_string_literal: true

class Survey::Opening < Dragnet::Advice
  advises Survey

  def opened!
    survey.open = true
    survey
  end

  def open!
    opened!.tap(&:save!)
  end

  def closed!
    survey.open = false
    survey
  end

  def close!
    closed!.tap(&:save!)
  end

  def toggle_openness!
    if survey.open?
      close!
    else
      open!
    end
  end
end
