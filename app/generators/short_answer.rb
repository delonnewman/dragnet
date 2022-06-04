class ShortAnswer < Dragnet::Generator
  def call(*)
    Faker::Lorem.sentence
  end
end
