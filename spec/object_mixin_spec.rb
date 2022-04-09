require_relative "setup"

RSpec.describe Ryo::ObjectMixin do
  let(:create_object) do
    lambda do |ryo, props = {}|
      obj = Ryo.const_get(superclass)
      obj.create(ryo, props)
    end
  end

  let(:fruit) { create_object.call(nil, foo: 42) }
  let(:apple) { create_object.call(fruit) }
  let(:sour_apple) { create_object.call(apple) }

  shared_examples "tests" do |superclass|
    context "when there is no prototype in the chain" do
      context "when querying for a property that does not exist" do
        subject { fruit.baz }
        it { is_expected.to eq(nil) }
      end

      context "when assigning the same property twice on self" do
        let(:fruit) { create_object.call(nil) }
        before { fruit.foo = 1 }
        subject(:assign_second_assignment) { fruit.foo = 2 }

        it "avoids defining the getter and setter a second time" do
          expect(Ryo).to_not receive(:define_method!).with(fruit, "foo")
          expect(Ryo).to_not receive(:define_method!).with(fruit, "foo=")
          assign_second_assignment
        end
      end

      context "when deleting the same property twice from self" do
        before { Ryo.delete fruit, "foo" }
        subject(:perform_second_delete) { Ryo.delete fruit, "foo" }

        it "avoids defining the getter a second time" do
          expect(Ryo).to_not receive(:define_method!).with(fruit, "foo")
          perform_second_delete
        end
      end

      describe "#respond_to?" do
        context "when querying for a property defined by a block" do
          subject { fruit.respond_to?(:foo) }
          it { is_expected.to be(true) }
        end

        context "when querying for an assigned property on self" do
          before { fruit.bar = 84 }
          subject { fruit.respond_to?(:bar) }
          it { is_expected.to be(true) }
        end

        context "when querying for a property that does not exist" do
          subject { fruit.respond_to?(:foobar) }
          it { is_expected.to be(true) }
        end
      end

      describe "#method_missing" do
        context "when querying for a property that does not exist" do
          subject { fruit.foobar }
          it { is_expected.to eq(nil) }
        end
      end
    end

    context "when there is fruit prototype in the chain" do
      context "when traversing to the property on the root prototype" do
        subject { apple.foo }
        it { is_expected.to eq(42) }
      end

      context "when the property is deleted from the root prototype" do
        before { Ryo.delete fruit, "foo" }
        subject { apple.foo }
        it { is_expected.to eq(nil) }
      end

      describe "#method_missing" do
        context "when querying for a property that does not exist" do
          subject { apple.foobar }
          it { is_expected.to eq(nil) }
        end
      end
    end

    context "when there are apple prototypes in the chain" do
      context "when traversing to the property on the root prototype" do
        subject { sour_apple.foo }
        it { is_expected.to eq(42) }
      end

      context "when traversing to the property on the middle prototype" do
        let(:apple) { create_object.call(fruit, foo: 84) }
        subject { sour_apple.foo }
        it { is_expected.to eq(84) }
      end

      context "when the property is deleted from the middle prototype" do
        let(:apple) { create_object.call(fruit, foo: 84) }
        before { Ryo.delete apple, "foo" }
        subject { sour_apple.foo }
        it { is_expected.to eq(42) }
      end
    end
  end

  context "when the superclass is Object" do
    let(:superclass) { :Object }
    include_examples "tests", Object
  end

  context "when the superclass is BasicObject" do
    let(:superclass) { :BasicObject }
    include_examples "tests", BasicObject
  end
end
