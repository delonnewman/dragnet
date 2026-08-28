# frozen_string_literal: true

shared_examples Dragnet::Reportable do
  it 'satisfies the Reportable protocol' do
    expect(Dragnet::Reportable).to be_satisfied_by(reportable)
  end
end
