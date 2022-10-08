# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo::Enumerable do
  describe ".each" do
    context "when verifying each traverses the prototype chain" do
      subject { Ryo.each(point).map { [_1, _2] } }
      let(:point_x) { Ryo(x: 0) }
      let(:point_y) { Ryo({y: 5}, point_x) }
      let(:point) { Ryo({}, point_y) }
      it { is_expected.to eq([["y", 5], ["x", 0]]) }
    end
  end

  describe "map" do
    let(:point) { Ryo::BasicObject(x: 2, y: 2) }
    let(:m_point) { Ryo.map(point) { _2 * 2 } }

    context "when verifying the map operation" do
      subject { [m_point.x, m_point.y] }
      it { is_expected.to eq([4, 4]) }
    end

    context "when veriying map returns a new Ryo object" do
      subject { Ryo.kernel(:equal?).bind_call(point, m_point) }
      it { is_expected.to be(false) }
    end
  end

  describe "select" do
    context "with prototype chain traversal" do
      subject { Ryo.select(point) { _1 == "y" and _2 == 4 } }
      let(:base) { Ryo::BasicObject(x: 1, y: 2) }
      let(:point) { Ryo::BasicObject({x: 3, y: 4}, base) }

      context "when verifying the filter" do
        it { is_expected.to eq(y: 4) }
      end

      context "when verifying the filter on the prototype" do
        subject { super().then { base.y } }
        it { is_expected.to eq(nil) }
      end
    end
  end

  describe "reject" do
    context "with prototype chain traversal" do
      subject { Ryo.reject(point) { _1 == "x" || _2 == 2 } }
      let(:base) { Ryo::BasicObject(x: 1, y: 2) }
      let(:point) { Ryo::BasicObject({x: 3, y: 4}, base) }

      context "when verifying the filter" do
        it { is_expected.to eq(y: 4) }
      end

      context "when verifying the filter on the prototype" do
        subject { super().then { base.y } }
        it { is_expected.to eq(nil) }
      end
    end
  end

  describe ".any?" do
    let(:base) { Ryo::BasicObject(y: 10) }
    let(:point) { Ryo::BasicObject({x: 5}, base) }

    context "when an iteration returns a truthy value" do
      subject { Ryo.any?(point) { _2 > 5} }
      it { is_expected.to be(true) }
    end

    context "when an iteration fails to return a truthy value" do
      subject { Ryo.any?(point) { _2 > 20 } }
      it { is_expected.to be(false) }
    end
  end

  describe ".find" do
    let(:point_a) { Ryo::BasicObject(x: 5) }
    let(:point_b) { Ryo::BasicObject({y: 10}, point_a) }
    let(:point_c) { Ryo::BasicObject({z: 15}, point_b) }

    context "when an iteration yields true on point_a" do
      subject { Ryo.find(point_c) { _2 == 5 } }
      it { is_expected.to eq(point_a) }
    end

    context "when an iteration yields true on point_b" do
      subject { Ryo.find(point_c) { _2 == 10 } }
      it { is_expected.to eq(point_b) }
    end

    context "when an iteration yields true on point_c" do
      subject { Ryo.find(point_c) { _2 == 15 } }
      it { is_expected.to eq(point_c) }
    end

    context "when an iteration never yields true" do
      subject { Ryo.find(point_c) { _2 == 20 } }
      it { is_expected.to eq(nil) }
    end
  end
end
