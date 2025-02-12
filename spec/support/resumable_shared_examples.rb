# frozen_string_literal: true

shared_examples Dragnet::Resumable do
  it 'implements resume_with' do
    expect { resumable.resume_with({}) }.not_to raise_error
  end
end
