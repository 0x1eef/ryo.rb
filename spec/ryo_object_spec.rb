# frozen_string_literal: true

require_relative "setup"

RSpec.describe "Ryo objects" do
  let(:car) { Ryo(name: "Car") }

  describe "Kernel#Ryo" do
    context "when given a Ryo object" do
      subject { Ryo(ryo) }
      let(:ryo) { Ryo(name: "Car") }

      it { is_expected.to be_instance_of(Ryo::Object) }
    end
  end

  describe "#respond_to?" do
    context "when a property is defined" do
      subject { car.respond_to?(:name) }
      it { is_expected.to be(true) }
    end

    context "when a property is not defined" do
      subject { car.respond_to?(:foobar) }
      it { is_expected.to be(true) }
    end
  end

  describe "#method_missing" do
    context "when a property doesn't exist" do
      subject { car.foobar }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#eql?" do
    context "when two objects are equal" do
      subject { car == car_2 }
      let(:car_2) { Ryo(name: "Car") }
      it { is_expected.to be(true) }
    end

    context "when an object and a Hash are equal" do
      subject { car == {"name" => "Car"} }
      it { is_expected.to be(true) }
    end

    context "when an object and symbol-key Hash are equal" do
      subject { car == {name: "Car"} }
      it { is_expected.to be(true) }
    end

    context "when an object and nested symbol-key Hash are equal" do
      subject { car == {name: "Car", wheels: {quantity: 4, weight: {lbs: "50"}}} }
      let(:car) { Ryo.from(name: "Car", wheels: {quantity: 4, weight: {lbs: "50"}}) }
      it { is_expected.to be(true) }
    end

    context "when an object is compared against nil" do
      subject { car == nil }
      it { is_expected.to be(false) }
    end
  end

  describe "#to_h" do
    subject(:h) { car.to_h }
    let(:car) { Ryo.from(name: "ford", wheels: {quantity: 4}) }
    it { expect(h).to be_instance_of(Hash) }
    it { expect(h["wheels"]).to be_instance_of(Hash) }
    it { expect(h).to eq({"name" => "ford", "wheels" => {"quantity" => 4}}) }

    context "when given to Hash#merge" do
      subject { {}.merge(car) }
      let(:car) { Ryo(name: "ford") }
      it { is_expected.to be_instance_of(Hash) }
      it { is_expected.to eq({"name" => "ford"}) }
    end
  end

  describe "#deconstruct_keys" do
    subject(:car) { Ryo(name: "ford", wheels: {quantity: 4}) }

    context "when given a pattern match" do
      it "is a match" do
        expect {
          case car
          in {wheels: {quantity: 4}}
          end
        }.not_to raise_error
      end

      it "is not a match" do
        expect {
          case car
          in {wheels: {quantity: 8}}
          end
        }.to raise_error(NoMatchingPatternError)
      end
    end
  end

  describe "when a property overshadows a method" do
    let(:car) do
      Ryo(tap: "property")
    end

    context "when a block is not given" do
      subject { car.tap }
      it { is_expected.to eq("property") }
    end

    context "when a block is given" do
      subject { car.tap {} }
      it { is_expected.to eq(car) }
    end
  end
end
