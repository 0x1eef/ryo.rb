require_relative "setup"

RSpec.describe Proto::ObjectMixin do
  let(:create_object) do
    lambda do |proto, &b|
      Class.new do
        extend Proto::ObjectMixin
      end.create(proto, superclass: superclass, &b)
    end
  end

  let(:one) { create_object.call(nil) { def foo = 42 } }
  let(:two) { create_object.call(one) }
  let(:three) { create_object.call(two) }

  shared_examples "tests" do |superclass|
    context "when there is no prototype in the chain" do
      context "when querying for a property that does not exist" do
        subject { one.baz }
        it { is_expected.to eq(nil) }
      end

      context "when assigning the same property twice on self" do
        let(:one) { create_object.call(nil) }
        before { one.foo = 1 }
        subject(:assign_second_assignment) { one.foo = 2 }

        it "avoids defining the getter and setter a second time" do
          expect(one).to_not receive(:__define_singleton_method).with("foo")
          expect(one).to_not receive(:__define_singleton_method).with("foo=")
          assign_second_assignment
        end
      end

      context "when deleting the same property twice from self" do
        before { one.delete("foo") }
        subject(:perform_second_delete) { one.delete("foo") }

        it "avoids defining the getter a second time" do
          expect(one).to_not receive(:__define_singleton_method).with("foo")
          perform_second_delete
        end
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
        let(:two) { create_object.call(one) { def foo = 84 } }
        subject { three.foo }
        it { is_expected.to eq(84) }
      end

      context "when the property is deleted from the middle prototype" do
        let(:two) { create_object.call(one) { def foo = 84 } }
        before { two.delete("foo") }
        subject { three.foo }
        it { is_expected.to eq(42) }
      end
    end
  end

  context "when the superclass is Object" do
    let(:superclass) { Object }
    include_examples "tests", Object
  end

  context "when the superclass is BasicObject" do
    let(:superclass) { BasicObject }
    include_examples "tests", BasicObject
  end
end
