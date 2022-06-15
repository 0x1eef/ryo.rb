# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo do
  describe ".set_prototype_of" do
    subject { ford.name }
    let(:car) { Ryo(name: "Car") }
    let(:ford) { Ryo({}, car) }
    let(:mazda) { Ryo(name: "Mazda") }

    before { Ryo.set_prototype_of(ford, mazda) }
    it { is_expected.to eq("Mazda") }
  end

  describe ".assign" do
    let(:car) { Ryo(name: "Ford") }
    let(:bike) { Ryo(wheels: 2) }

    context "when car and bike are combined" do
      subject { Ryo.assign(car, bike) }
      it { is_expected.to eq("name" => "Ford", "wheels" => 2) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end

    context "when Ryo objects and Hash objects are combined" do
      subject { Ryo.assign(car, bike, {color: "blue"}) }
      it { is_expected.to eq("name" => "Ford", "wheels" => 2, "color" => "blue") }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end
  end

  describe ".properties_of" do
    context "when requesting the properties of an object with a prototype" do
      subject { Ryo.properties_of(ford) }
      let(:car) { Ryo(name: "Car", wheels: 4) }
      let(:ford) { Ryo({model: "T", year: 1920}, car) }
      it { is_expected.to eq(["model", "year"]) }
    end
  end

  describe ".delete" do
    let(:car) { Ryo(name: "Car") }

    context "when a propery is deleted" do
      subject { car.name }
      before { Ryo.delete(car, "name") }
      it { is_expected.to be_nil }
    end
  end

  describe ".function" do
    let(:car) { Ryo(drive: Ryo.fn { |miles| miles }) }

    context "when the function requires argument(s)" do
      context "when the required argument is not given" do
        subject { car.drive.() }
        it { expect { is_expected }.to raise_error(ArgumentError) }
      end

      context "when the required argument is given" do
        subject { car.drive.(42) }
        it { is_expected.to eq(42) }
      end
    end

    context "when the function receives a block" do
      subject { car.drive.() { "block" } }
      let(:car) { Ryo(drive: Ryo.fn { |&b| b.() }) }
      it { is_expected.to eq("block") }
    end
  end
end
