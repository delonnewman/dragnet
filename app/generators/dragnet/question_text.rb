class Dragnet::QuestionText < Dragnet::ParameterizedGenerator
  def initialize(other_questions: Set.new, max_attempts: 10)
    super()
    @other_questions = other_questions
    @max_attempts = max_attempts
    @attempts = 0
    @source = 0
  end

  def call
    text = generate_content
    while @other_questions.include?(text)
      text = generate_content
    end
    @other_questions << text
    text
  end

  private

  SOURCES = [
    -> { Faker::Movie.quote },
    -> { Faker::Quote.yoda },
    -> { Faker::Quote.robin },
    -> { Faker::Quote.fortune_cookie },
    -> { Faker::Quotes::Shakespeare.hamlet_quote },
    -> { Faker::Quotes::Shakespeare.as_you_like_it_quote },
    -> { Faker::Quotes::Shakespeare.king_richard_iii_quote },
    -> { Faker::Quotes::Shakespeare.romeo_and_juliet_quote },
    -> { Faker::Religion::Bible.quote },
    -> { Faker::Books::Dune.quote },
    -> { Faker::Movies::PrincessBride.quote },
    -> { Faker::Movies::StarWars.quote },
    -> { Faker::Movies::BackToTheFuture.quote },
    -> { Faker::Movies::Tron.quote },
  ].freeze
  private_constant :SOURCES

  def generate_content
    @attempts += 1

    if @attempts > @max_attempts
      @attempts = 0
      @source += 1
      if @source == SOURCES.length
        binding.pry
        raise 'Ran out of sources'
      end
    end

    SOURCES[@source].call
  end
end
