# frozen_string_literal: true

shared_examples 'an action' do
  before do
    action.send(:initialize_parameters!, {})
  end

  it 'implements partial?' do
    expect { action.partial? }.not_to raise_error
  end

  it 'implements invoke' do
    expect { action.invoke }.not_to raise_error
  end

  it "returns a continuation when the action is called and it's partial" do
    allow(action).to receive(:partial?).and_return(true)

    expect(action.call({})).to be_an_instance_of Dragnet::Continuation
  end

  it "returns the return value of invoke when the action is called and it's not partial" do
    value = SecureRandom.uuid

    allow(action).to receive(:partial?).and_return(false)
    allow(action).to receive(:invoke).and_return(value)

    expect(action.call({})).to be value
  end
end
