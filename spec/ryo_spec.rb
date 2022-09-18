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

  describe ".prototype_chain_of" do
    context "when given the last node in a chain of prototypes" do
      subject { Ryo.prototype_chain_of(node_3) }
      let(:root) { Ryo({a: 1}) }
      let(:node_1) { Ryo({b: 2}, root) }
      let(:node_2) { Ryo({c: 3}, node_1) }
      let(:node_3) { Ryo({d: 4}, node_2) }

      it { is_expected.to eq([node_2, node_1, root]) }
    end

    context "when given an object without a prototype" do
      subject { Ryo.prototype_chain_of(Ryo({})) }
      it { is_expected.to eq([]) }
    end
  end

  describe ".each" do
    context "when iterating over properties in the prototype chain" do
      subject { Ryo.each(point).map { [_1, _2] } }
      let(:point_x) { Ryo(x: 0) }
      let(:point_y) { Ryo({y: 5}, point_x) }
      let(:point) { Ryo({}, point_y) }

      it { is_expected.to eq([["y", 5], ["x", 0]]) }
    end
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

  describe ".from" do
    context "when given a set of nested Hash objects" do
      subject { vehicles.cars.wheels.quantity }
      let(:vehicles) { Ryo.from(cars: {wheels: {quantity: 4}}) }
      it { is_expected.to eq(4) }
    end

    context "when given a Hash nested in an Array" do
      subject { house.rooms[0].quantity }
      let(:house) { Ryo.from(rooms: [{quantity: 4}]) }
      it { is_expected.to eq(4) }
    end

    context "with a prototype" do
      let(:point) { Ryo.from(x: 0, y: 0) }
      let(:vehicles) { Ryo.from({cars: {wheels: {quantity: 4}}}, point) }

      context "when traversing to the prototype" do
        subject { [vehicles.x, vehicles.y] }
        it { is_expected.to eq([0, 0]) }
      end

      context "when traversing to the prototype on a nested node" do
        subject { [vehicles.cars.x, vehicles.cars.y] }
        it { is_expected.to eq([nil, nil]) }
      end
    end

    context "when given an Array that contains Hash objects" do
      context "when given one Hash object" do
        subject { vehicles[0].wheels.quantity }
        let(:vehicles) { Ryo.from([{wheels: {quantity: 4}}]) }
        it { is_expected.to eq(4) }
      end

      context "when given two Hash objects" do
        subject { vehicles.map { _1.wheels.quantity } }
        let(:vehicles) { Ryo.from([{wheels: {quantity: 4}}, {wheels: {quantity: 3}}]) }
        it { is_expected.to eq([4, 3]) }
      end

      context "when given a mix of Hash objects, and other objects" do
        subject { vehicles.map { Ryo === _1 ? _1.wheels.quantity : _1 } }
        let(:vehicles) { Ryo.from([{wheels: {quantity: 4}}, "foo"]) }
        it { is_expected.to eq([4, "foo"]) }
      end

      context "when given an object that implements #each but not #each_key" do
        subject { Ryo.from(each_obj.new).map { Ryo === _1 ? _1.wheels.quantity : _1 } }
        let(:each_obj) do
          Class.new {
            def initialize
              @arr = [{wheels: {quantity: 4}}, "foo"]
            end

            def each
              @arr.each { yield(_1) }
            end
          }
        end
        it { is_expected.to eq([4, "foo"]) }
      end
    end

    context "when given an object that does implement #each / #each_key" do
      subject(:from) { Ryo.from(Object.new) }
      it { expect { from }.to raise_error(TypeError, %r{does not implement #each / #each_key}) }
    end
  end

  describe "clone" do
    let(:point_x) { Ryo::BasicObject(x: 1) }
    let(:point_y) { Ryo::BasicObject({y: 2}, point_x) }
    let(:point) { Ryo::BasicObject({}, point_y) }
    subject(:clone) { Ryo.clone(point) }

    context "when the clone is mutated" do
      before { clone.x = 5 }

      context "when confirmimg the source wasn't mutated" do
        subject { point.x }
        it { is_expected.to eq(1) }
      end

      context "when confirming the clone was mutated" do
        subject { clone.x }
        it { is_expected.to eq(5) }
      end
    end

    context "when confirming the source and clone are distinct objects" do
      subject { Ryo.module_method(:equal?).bind_call(point, clone) }
      it { is_expected.to eq(false) }
    end

    context "when confirming the source and clone are equal" do
      subject { point == clone }
      it { is_expected.to be(true) }
    end

    context "when confirming the prototypes of the source and clone are equal" do
      subject { Ryo.prototype_chain_of(point) == Ryo.prototype_chain_of(clone) }
      it { is_expected.to eq(true) }
    end
  end
end
