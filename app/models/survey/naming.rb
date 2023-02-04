# frozen_string_literal: true

class Survey::Naming < Dragnet::Advice
  advises Survey, args: %i[default_name]

  delegate :name, :slug, to: :advised_object

  def generate_name_and_slug
    survey.name = unique_name if generate_name?
    survey.slug = Dragnet::Utils.slug(name) if generate_slug?
  end

  def generate_name?
    name.blank? || auto_named? and survey.new_record? || survey.will_save_change_to_author_id?
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

  # @return [String]
  def unique_name
    n = auto_named_survey_count
    n.zero? ? default_name : numbered_name(n)
  end

  # @param [Integer] number
  #
  # @return [String]
  def numbered_name(number)
    "#{default_name} (#{number})"
  end

  # @return [Integer]
  def auto_named_survey_count
    return 0 unless author_id?

    Survey.where('name = ? or name like ? and author_id = ?', default_name, "#{default_name} (%)", author_id).count
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
