require_relative "setup"

##
# shared examples
RSpec.shared_examples ".function" do
  describe ".function (alias: .fn)" do
    let(:fruit) { object.create(nil, {eat: Ryo.fn { name }}) }

    context "when the function requires argument(s)" do
      let(:fruit) { object.create(nil, {eat: Ryo.fn { |arg1| arg1 }}) }

      context "when the required argument is not given" do
        it "raises an ArgumentError" do
          expect { fruit.eat.() }.to raise_error(ArgumentError)
        end
      end

      context "when the required argument is given" do
        subject { fruit.eat.(42) }
        it { is_expected.to eq(42) }
      end
    end

    context "when the function receives a block" do
      let(:fruit) { object.create(nil, {eat: Ryo.fn { |&b| b.() }}) }
      subject { fruit.eat.() { "block" } }

      it { is_expected.to eq("block") }
    end

    context "when calling a function from 'apple'" do
      subject { apple.eat.() }

      it { is_expected.to eq(apple.name) }
    end

    context "when calling a function from 'sour_apple'" do
      subject { sour_apple.eat.() }

      it { is_expected.to eq(sour_apple.name) }
    end
  end
end

RSpec.describe Ryo do
  let(:fruit) { Ryo::BasicObject.create(nil) }
  let(:apple) { Ryo::BasicObject.create(fruit, {name: "Apple"}) }
  let(:sour_apple) { Ryo::BasicObject.create(apple, {name: "Sour Apple"}) }

  describe ".delete" do
    before { fruit.foo = 1 }

    context "when a propery is deleted" do
      before { Ryo.delete(fruit, "foo") }
      subject { fruit.foo }

      it { is_expected.to be_nil }
    end
  end

  describe ".assign" do
    it "combines fruit and apple" do
      expect(
        Ryo.assign(fruit, apple)
      ).to eq("name" => "Apple")
    end

    it "combines a combination of Ryo and Hash objects" do
      expect(
        Ryo.assign(fruit, {foo: 1}, {bar: 2}, apple)
      ).to eq({"foo" => 1, "bar" => 2, "name" => "Apple"})
    end
  end

  context "when the object is Ryo::Object" do
    let(:object) { Ryo::Object }
    include_examples '.function'
  end

  context "when the object is Ryo::BasicObject" do
    let(:object) { Ryo::BasicObject }
    include_examples '.function'
  end

  context "when the object is Object" do
    let(:object) { Object }
    include_examples '.function'
  end

  context "when the object is BasicObject" do
    let(:object) { BasicObject }
    include_examples '.function'
  end
end
