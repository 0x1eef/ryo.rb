require_relative "setup"

RSpec.describe Proto::ObjectMixin do
  let(:object) do
    Class.new do
      extend Proto::ObjectMixin
    end
  end

  let(:one) { object.create(nil) { def bar = 42 } }
  let(:two) { object.create(one) }
  let(:three) { object.create(two) }

  context "when there is one prototype in the chain" do
    context "when falling back to the property on the root prototype" do
      subject { two.bar }
      it { is_expected.to eq(42) }
    end

    context "when the property is deleted from the root prototype" do
      before { two.delete("bar") }
      subject { two.bar }
      it { is_expected.to eq(nil) }
    end
  end

  context "when there are two prototypes in the chain" do
    context "when falling back to the property on the root prototype" do
      subject { three.bar }
      it { is_expected.to eq(42) }
    end

    context "when falling back to the property on the middle prototype" do
      let(:two) { object.create(one) { def bar = 84 } }
      subject { three.bar }
      it { is_expected.to eq(84) }
    end

    context "when the property is deleted from all prototypes in the chain" do
      before { two.delete("bar") }
      subject { two.bar }
      it { is_expected.to eq(nil) }
    end
  end
end
