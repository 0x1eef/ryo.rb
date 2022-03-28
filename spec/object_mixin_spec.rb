require_relative "setup"

RSpec.describe Proto::ObjectMixin do
  let(:object) do
    Class.new do
      extend Proto::ObjectMixin
    end
  end

  let(:one) { object.create(nil) { def foo = 42 } }
  let(:two) { object.create(one) }
  let(:three) { object.create(two) }

  context "when there is no prototype in the chain" do
    context "when querying for a property that does not exist" do
      subject { one.baz }
      it { is_expected.to eq(nil) }
    end

    describe "#respond_to?" do
      context "when querying for a property defined by a block" do
        subject { one.respond_to?(:foo) }
        it { is_expected.to be(true) }
      end

      context "when querying for an assigned property on self" do
        before { one.bar = 84 }
        subject { one.respond_to?(:bar) }
        it { is_expected.to be(true) }
      end

      context "when querying for a property that does not exist" do
        subject { one.respond_to?(:foobar) }
        it { is_expected.to be(true) }
      end
    end

    describe "#method_missing" do
      context "when querying for a property that does not exist" do
        subject { one.foobar }
        it { is_expected.to eq(nil) }
      end
    end
  end

  context "when there is one prototype in the chain" do
    context "when traversing to the property on the root prototype" do
      subject { two.foo }
      it { is_expected.to eq(42) }
    end

    context "when the property is deleted from the root prototype" do
      before { one.delete("foo") }
      subject { two.foo }
      it { is_expected.to eq(nil) }
    end

    describe "#method_missing" do
      context "when querying for a property that does not exist" do
        subject { two.foobar }
        it { is_expected.to eq(nil) }
      end
    end
  end

  context "when there are two prototypes in the chain" do
    context "when traversing to the property on the root prototype" do
      subject { three.foo }
      it { is_expected.to eq(42) }
    end

    context "when traversing to the property on the middle prototype" do
      let(:two) { object.create(one) { def foo = 84 } }
      subject { three.foo }
      it { is_expected.to eq(84) }
    end

    context "when the property is deleted from the middle prototype" do
      let(:two) { object.create(one) { def foo = 84 } }
      before { two.delete("foo") }
      subject { three.foo }
      it { is_expected.to eq(42) }
    end
  end
end
