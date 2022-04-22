require_relative "setup"

##
# Shared example
RSpec.shared_examples "the singleton methods of Ryo::Object, Ryo::BasicObject" do
  describe ".from" do
    context "when walking through a Hash of nested Hash objects" do
      subject do
        object
          .from({foo: {bar: {baz: 42}}})
          .foo.bar.baz
      end

      it { is_expected.to eq(42) }
    end

    context "when walking through a mix of Hash and Array objects" do
      subject do
        object
          .from({foo: {bar: [{baz: 42}]}})
          .foo.bar[0].baz
      end

      it { is_expected.to eq(42) }
    end

    context "when a property overshadows a method that takes a block" do
      let(:obj) do
        object
          .from({tap: {tap: {tap: 42}}})
      end

      context "when no block is given" do
        subject { obj.tap.tap.tap }

        it { is_expected.to eq(42) }
      end

      context "when a block is given" do
        subject { obj.tap {} }

        it { is_expected.to eq(obj) }
      end
    end
  end
end

##
# Shared example
RSpec.shared_examples "prototype-based inheritance" do
  context "when there is one prototype" do
    context "when traversing to a property on the root prototype" do
      subject { apple.foo }
      it { is_expected.to eq(42) }
    end

    context "when a property is deleted from the root prototype" do
      before { Ryo.delete fruit, "foo" }
      subject { apple.foo }
      it { is_expected.to eq(nil) }
    end
  end

  context "when there are two prototypes" do
    context "when traversing to a property on the root prototype" do
      subject { sour_apple.foo }
      it { is_expected.to eq(42) }
    end

    context "when traversing to a property on the middle prototype" do
      let(:apple) { object.create(fruit, foo: 84) }
      subject { sour_apple.foo }
      it { is_expected.to eq(84) }
    end

    context "when a property is deleted from the middle prototype" do
      let(:apple) { object.create(fruit, foo: 84) }
      before { Ryo.delete apple, "foo" }
      subject { sour_apple.foo }
      it { is_expected.to eq(42) }
    end
  end
end

##
# Shared example
shared_examples "the instance methods of Ryo objects" do
  describe "#respond_to?" do
    context "when a property is defined" do
      before { fruit.bar = 84 }
      subject { fruit.respond_to?(:bar) }
      it { is_expected.to be(true) }
    end

    context "when a property is not defined" do
      subject { fruit.respond_to?(:foobar) }
      it { is_expected.to be(true) }
    end
  end

  describe "#method_missing" do
    context "when a property does not exist" do
      subject { fruit.foobar }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#eql?" do
    context "when two ryo objects are equal" do
      subject { apple == sour_apple }
      it { is_expected.to be(true) }
    end

    context "when a ryo object and a Hash are equal" do
      subject { apple == {} }
      it { is_expected.to be(true) }
    end

    context "when comparing against nil" do
      subject { apple == nil }
      it { is_expected.to be(false) }
    end
  end
end

##
# Specs
RSpec.describe Ryo::ObjectMixin do
  let(:fruit) { object.create(nil, foo: 42) }
  let(:apple) { object.create(fruit) }
  let(:sour_apple) { object.create(apple) }

  context "when the object is Ryo::Object" do
    let(:object) { Ryo::Object }
    include_examples "the singleton methods of Ryo::Object, Ryo::BasicObject"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is Ryo::BasicObject" do
    let(:object) { Ryo::BasicObject }
    include_examples "the singleton methods of Ryo::Object, Ryo::BasicObject"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is Object" do
    let(:object) { Object }
    include_examples "the singleton methods of Ryo::Object, Ryo::BasicObject"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is BasicObject" do
    let(:object) { BasicObject }
    include_examples "the singleton methods of Ryo::Object, Ryo::BasicObject"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end
end
