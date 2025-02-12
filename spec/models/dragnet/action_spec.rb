describe Dragnet::Action do
  it_behaves_like 'an abstract class'

  let(:action_class) do
    Class.new(described_class) do
      def partial?
        true
      end

      def invoke
        SecureRandom.uuid
      end
    end
  end

  it 'generates a unique name for each action' do
    expect(action_class.new.name).not_to eq(action_class.new.name)
  end

  it "collects attribute and parameter data in it's continuation when it's partial" do
    attributes = { a: 1, b: 2 }
    params = { c: 3, b: 4 }

    action = action_class.new(attributes)
    continuation = action.call(params)

    expect(continuation.data).to eq(attributes.merge(params))
  end
end
