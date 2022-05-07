require_relative "setup"

##
# Shared example
RSpec.shared_examples ".set_prototype_of" do
  describe ".set_prototype_of" do
    let(:ryo1) { object.create(nil) }
    let(:ryo2) { object.create(ryo1) }
    let(:ryo3) { object.create(nil, {foo: 42}) }

    before { Ryo.set_prototype_of(ryo2, ryo3) }
    subject { ryo2.foo }
    it { is_expected.to eq(42) }
  end
end

##
# Shared example
RSpec.shared_examples ".function" do
  describe ".function (alias: .fn)" do
    let(:ryo1) { object.create(nil, {func: Ryo.fn { |arg1| arg1 }}) }

    context "when the function requires argument(s)" do
      context "when the required argument is not given" do
        subject { ryo1.func.() }
        it { expect { is_expected }.to raise_error(ArgumentError) }
      end

      context "when the required argument is given" do
        subject { ryo1.func.(42) }
        it { is_expected.to eq(42) }
      end
    end

    context "when the function receives a block" do
      let(:ryo1) { object.create(nil, {func: Ryo.fn { |&b| b.() }}) }
      subject { ryo1.func.() { "block" } }
      it { is_expected.to eq("block") }
    end
  end
end

##
# Shared example
RSpec.shared_examples ".assign" do
  describe ".assign" do
    let(:ryo1) { object.create(nil, {foo: 1}) }
    let(:ryo2) { object.create(nil, {bar: 2}) }

    it "combines ryo1 and ryo2" do
      expect(
        Ryo.assign(ryo1, ryo2)
      ).to eq("foo" => 1, "bar" => 2)
    end

    it "combines a combination of Ryo and Hash objects" do
      expect(
        Ryo.assign(ryo1, {baz: 1}, {daz: 2}, ryo2)
      ).to eq({"foo" => 1, "bar" => 2, "baz" => 1, "daz" => 2})
    end
  end
end

##
# Shared example
RSpec.shared_examples ".delete" do
  describe ".delete" do
    let(:ryo1) { object.create(nil, {foo: 1}) }

    context "when a propery is deleted" do
      before { Ryo.delete(ryo1, "foo") }
      subject { ryo1.foo }

      it { is_expected.to be_nil }
    end
  end
end

##
# Shared example
RSpec.shared_examples ".properties_of" do
  describe ".properties_of" do
    let(:ryo1) { object.create(nil, foo: 1, bar: 2) }
    let(:ryo2) { object.create(ryo1, baz: 3, daz: 4) }
    subject { Ryo.properties_of(ryo2) }
    it { is_expected.to eq(["baz", "daz"]) }
  end
end

##
# Shared example
RSpec.shared_examples ".from" do
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

    context "when given an object that can't be coerced to a Hash" do
      subject { proc { object.from(Object.new) } }
      it { is_expected.to raise_error(TypeError) }
    end
  end
end

##
# specs
RSpec.describe Ryo do
  context "when the object is Ryo::Object" do
    let(:object) { Ryo::Object }
    include_examples ".function"
    include_examples ".assign"
    include_examples ".delete"
    include_examples ".properties_of"
    include_examples ".from"
    include_examples ".set_prototype_of"
  end

  context "when the object is Ryo::BasicObject" do
    let(:object) { Ryo::BasicObject }
    include_examples ".function"
    include_examples ".assign"
    include_examples ".delete"
    include_examples ".properties_of"
    include_examples ".from"
    include_examples ".set_prototype_of"
  end

  context "when the object is Object" do
    let(:object) { Object }
    include_examples ".function"
    include_examples ".assign"
    include_examples ".delete"
    include_examples ".properties_of"
    include_examples ".from"
    include_examples ".set_prototype_of"
  end

  context "when the object is BasicObject" do
    let(:object) { BasicObject }
    include_examples ".function"
    include_examples ".assign"
    include_examples ".delete"
    include_examples ".properties_of"
    include_examples ".from"
    include_examples ".set_prototype_of"
  end
end
