# frozen_string_literal: true

shared_examples 'an abstract class' do
  it 'cannot be instantiated' do
    expect { described_class.new }.to raise_error(/only subclasses of \w+ can be instantiated/)
  end
end
