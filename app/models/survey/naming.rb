# frozen_string_literal: true

class Survey::Naming < Dragnet::Advice
  advises Survey, args: %i[default_name]

  delegate :name, :slug, to: :advised_object

  # @return [Symbol, nil]
  def ident
    return if slug.blank?

    slug.underscore.to_sym
  end

  # @param [User] author
  def author=(author)
    @author = author
    self.author_id = author.id
  end

  # @param [Integer] author_id
  def author_id=(author_id)
    survey[:author_id] = author_id
    self.name = unique_name unless manually_named?
  end

  # @param [String] name
  def name=(name)
    survey[:name] = name
    survey[:slug] = Dragnet::Utils.slug(name)
  end

  def manually_named?
    name.present? && !name.start_with?(default_name)
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
end
