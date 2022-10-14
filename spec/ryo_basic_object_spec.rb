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
        it { is_expected.to eq(nil) }
      end
    end
  end
end
