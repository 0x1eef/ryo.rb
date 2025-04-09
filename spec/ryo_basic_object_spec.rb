# frozen_string_literal: true

require_relative "setup"
require "ostruct"

RSpec.describe Ryo::BasicObject do
  describe "Ryo::BasicObject()" do
    context "when given a Hash" do
      subject { [point.x, point.y] }
      let(:point) { Ryo::BasicObject(x: 0, y: 0) }
      it { is_expected.to eq([0, 0]) }
    end

    context "when given an OpenStruct" do
      subject { [point.x, point.y] }
      let(:point) { Ryo::BasicObject(OpenStruct.new(x: 0, y: 0)) }
      it { is_expected.to eq([0, 0]) }

      context "when verifying the object is a Ryo object" do
        subject { Ryo === point }
        it { is_expected.to be(true) }
      end
    end
  end

  describe ".from" do
    context "when given an instance of Ryo::BasicObject" do
      subject { Ryo.from(point) }
      let(:point) { Ryo::BasicObject(x: 5, y: 10) }
      it { is_expected.to eq(point) }
    end

    context "when given nested Hash objects" do
      subject { point.x.to_i }
      let(:point) { Ryo::BasicObject.from({x: {to_i: 4}}) }
      it { is_expected.to eq(4) }
    end

    context "when given an Array that contains nested Hash objects" do
      subject { points[0].x.to_i }
      let(:points) { Ryo::BasicObject.from([{x: {to_i: 4}}]) }
      it { is_expected.to eq(4) }
    end

    context "with a prototype" do
      let(:point_a) { Ryo::BasicObject.from(x: {to_i: 0}) }
      let(:point_b) { Ryo::BasicObject.from({y: {to_i: 2}}, point_a) }

      context "when traversing to the prototype (point_a)" do
        subject { point_b.x.to_i }
        it { is_expected.to eq(0) }
      end

      context "when verifying a nested Hash doesn't inherit the prototype (point_a)" do
        subject { point_b.y.x }
        it { is_expected.to be_nil }
      end
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
end
