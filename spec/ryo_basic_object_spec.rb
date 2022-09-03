# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo::BasicObject do
  describe "Ryo::BasicObject()" do
    context "when given a Hash" do
      subject { [point.x, point.y] }
      let(:point) { Ryo::BasicObject(x: 0, y: 0) }
      it { is_expected.to eq([0, 0]) }
    end
  end

  describe ".from" do
    context "when given a set of nested Hash objects" do
      subject { vehicles.cars.wheels.quantity }
      let(:vehicles) { described_class.from(cars: {wheels: {quantity: 4}}) }
      it { is_expected.to eq(4) }
    end

    context "when given a Hash nested in an Array" do
      subject { house.rooms[0].quantity }
      let(:house) { described_class.from(rooms: [{quantity: 4}]) }
      it { is_expected.to eq(4) }
    end

    context "with a prototype" do
      let(:point) { described_class.from(x: 0, y: 0) }
      let(:vehicles) { described_class.from({cars: {wheels: {quantity: 4}}}, point) }

      context "when traversing to the prototype" do
        subject { [vehicles.x, vehicles.y] }
        it { is_expected.to eq([0, 0]) }
      end

      context "when traversing to the prototype on a nested node" do
        subject { [vehicles.cars.x, vehicles.cars.y] }
        it { is_expected.to eq([nil, nil]) }
      end
    end
  end
end
