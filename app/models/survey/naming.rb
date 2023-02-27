# frozen_string_literal: true

class Survey::Naming < Dragnet::Advice
  advises Survey, args: %i[default_name]

  delegate :name, :slug, to: :advised_object

  def generate_name_and_slug
    survey.name = unique_name(survey.name) if generate_name?
    survey.slug = Dragnet::Utils.slug(name) if generate_slug?
  end

  def generate_name?
    name.blank? || auto_named? || duplicated_name? and survey.new_record? || survey.will_save_change_to_author_id?
  end
  alias generated_name? generate_name?

  def generate_slug?
    name.present? && slug.blank?
  end
  alias generated_slug? generate_slug?

  def manually_named?
    name.present? && !auto_named?
  end

  def auto_named?
    name.start_with?(default_name)
  end

  def duplicated_name?
    !unique_name?
  end

  def unique_name?
    auto_named_survey_count(name).zero?
  end

  # @return [String]
  def unique_name(name = nil)
    name ||= default_name
    n = auto_named_survey_count(name)
    n.zero? ? name : numbered_name(n, name)
  end

  # @param [Integer] number
  #
  # @return [String]
  def numbered_name(number, name = default_name)
    "#{name} (#{number})"
  end

  # @return [Integer]
  # TODO: memoize this method
  def auto_named_survey_count(name = default_name)
    return 0 unless author_id?

    Survey.where('name = ? or name like ? and author_id = ?', name, "#{name} (%)", author_id).count
  end

  def author_id?
    author_id.present?
  end

  # @return [Integer, nil]
  def author_id
    survey.author_id || survey.author&.id
  end

  def ident
    return if slug.blank?

    slug.underscore.to_sym
  end
end
