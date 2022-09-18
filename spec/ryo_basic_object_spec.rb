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
    context "when given nested Hash objects" do
      subject { coords.point.x.int }
      let(:coords) { Ryo::BasicObject.from(point: {x: {int: 4}}) }
      it { is_expected.to eq(4) }
    end

    context "when given nested Hash objects in an Array" do
      subject { coords.points[0].x.int }
      let(:coords) { Ryo::BasicObject.from(points: [{x: {int: 4}}]) }
      it { is_expected.to eq(4) }
    end

    context "with a prototype" do
      let(:point_x) { Ryo::BasicObject.from(x: {int: 0}) }
      let(:point) { Ryo::BasicObject.from({y: {int: 2}}, point_x) }

      context "when traversing to the prototype" do
        subject { point.x.int }
        it { is_expected.to eq(0) }
      end

      context "when verifying a nested Hash object didn't inherit the prototype" do
        subject { point.y.x }
        it { is_expected.to eq(nil) }
      end
    end
  end
end
