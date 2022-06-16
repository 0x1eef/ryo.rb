require_relative "setup"

##
# Shared example
shared_examples "the instance methods of Ryo objects" do
  describe "#respond_to?" do
    context "when a property is defined" do
      before { ryo1.bar = 84 }
      subject { ryo1.respond_to?(:bar) }
      it { is_expected.to be(true) }
    end

    context "when a property is not defined" do
      subject { ryo1.respond_to?(:foobar) }
      it { is_expected.to be(true) }
    end
  end

  describe "#method_missing" do
    context "when a property does not exist" do
      subject { ryo1.foobar }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#eql?" do
    context "when two ryo objects are equal" do
      subject { ryo2 == ryo3 }
      it { is_expected.to be(true) }
    end

    context "when a ryo object and a Hash are equal" do
      subject { ryo2 == {} }
      it { is_expected.to be(true) }
    end

    context "when comparing against nil" do
      subject { ryo2 == nil }
      it { is_expected.to be(false) }
    end
  end
end

##
# Shared example
RSpec.shared_examples "property overshadows a method" do
  context "when a property overshadows a method that takes a block" do
    let(:ryo1) do
      object
        .from({tap: {tap: {tap: 42}}})
    end

    context "when no block is given" do
      subject { ryo1.tap.tap.tap }
      it { is_expected.to eq(42) }
    end

    context "when a block is given" do
      subject { ryo1.tap {} }
      it { is_expected.to eq(ryo1) }
    end
  end
end

##
# Specs
RSpec.describe Ryo::ObjectMixin do
  let(:ryo1) { object.create(nil, foo: 42) }
  let(:ryo2) { object.create(ryo1) }
  let(:ryo3) { object.create(ryo2) }

  context "when the object is Ryo::Object" do
    let(:object) { Ryo::Object }
    include_examples "property overshadows a method"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is Ryo::BasicObject" do
    let(:object) { Ryo::BasicObject }
    include_examples "property overshadows a method"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is Object" do
    let(:object) { Object }
    include_examples "property overshadows a method"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end

  context "when the object is BasicObject" do
    let(:object) { BasicObject }
    include_examples "property overshadows a method"
    include_examples "the instance methods of Ryo objects"
    include_examples "prototype-based inheritance"
  end
end
