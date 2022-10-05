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
end
