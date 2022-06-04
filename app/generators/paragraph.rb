class Paragraph < Dragnet::Generator
  def call(*)
    Faker::Lorem.sentences.join('  ')
  end
end
