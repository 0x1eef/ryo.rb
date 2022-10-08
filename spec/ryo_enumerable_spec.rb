# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo::Enumerable do
  describe ".each" do
    context "when verifying each traverses through the prototype chain" do
      subject { Ryo.each(point_c).map { [_1, _2] } }
      let(:point_a) { Ryo(x: 0) }
      let(:point_b) { Ryo({y: 5}, point_a) }
      let(:point_c) { Ryo({}, point_b) }
      it { is_expected.to eq([["y", 5], ["x", 0]]) }
    end
  end

  describe ".map" do
    let(:point_a) { Ryo::BasicObject(x: 4, y: 4) }
    let(:point_b) { Ryo::BasicObject({x: 2, y: 2}, point_a) }
    subject(:point_c) { Ryo.map(point_b) { _2 * 2 } }

    context "when verifying the map operation" do
      it { is_expected.to eq({x: 4, y: 4}) }
    end

    context "when verifying the map operation on the prototype" do
      subject { point_a }
      before { Ryo.map!(point_b) { _2 * 2 } }
      it { is_expected.to eq({x: 8, y: 8}) }
    end

    context "when verifying the map operation returns a new object" do
      subject { Ryo.kernel(:equal?).bind_call(point_b, point_c) }
      it { is_expected.to be(false) }
    end
  end

  describe ".select" do
    context "with prototype chain traversal" do
      subject { Ryo.select(point_b) { _1 == "y" and _2 == 4 } }
      let(:point_a) { Ryo::BasicObject(x: 1, y: 2) }
      let(:point_b) { Ryo::BasicObject({x: 3, y: 4}, point_a) }

      context "when verifying the filter operation" do
        it { is_expected.to eq(y: 4) }
      end

      context "when verifying the filter operation on the prototype" do
        subject { point_a.y }
        before { Ryo.select!(point_b) { _1 == "x" } }
        it { is_expected.to eq(nil) }
      end
    end
  end

  describe ".reject" do
    context "with prototype chain traversal" do
      subject { Ryo.reject(point_b) { _1 == "x" } }
      let(:point_a) { Ryo::BasicObject(x: 1, y: 2) }
      let(:point_b) { Ryo::BasicObject({x: 3, y: 4}, point_a) }

      context "when verifying the filter operation" do
        it { is_expected.to eq(y: 4) }
      end

      context "when verifying the filter operation on the prototype" do
        subject { point_a.y }
        before { Ryo.reject!(point_b) { _1 == "y" } }
        it { is_expected.to eq(nil) }
      end
    end
  end

  describe ".any?" do
    let(:point_a) { Ryo::BasicObject(y: 10) }
    let(:point_b) { Ryo::BasicObject({x: 5}, point_a) }

    context "when an iteration returns a truthy value" do
      subject { Ryo.any?(point_b) { _2 > 5} }
      it { is_expected.to be(true) }
    end

    context "when an iteration fails to return a truthy value" do
      subject { Ryo.any?(point_b) { _2 > 20 } }
      it { is_expected.to be(false) }
    end
  end

  describe ".all?" do
    let(:point_a) { Ryo::BasicObject(y: 10) }
    let(:point_b) { Ryo::BasicObject({x: 5}, point_a) }
    let(:point_c) { Ryo::BasicObject({z: 0}, point_b) }

    context "when every iteration returns a truthy value" do
      subject { Ryo.all?(point_c) { _2 < 11 } }
      it { is_expected.to be(true) }
    end

    context "when an iteration fails to return a truthy value" do
      subject { Ryo.all?(point_c) { _2 < 5 } }
      it { is_expected.to be(false) }
    end
  end

  describe ".find" do
    let(:point_a) { Ryo::BasicObject(x: 5) }
    let(:point_b) { Ryo::BasicObject({y: 10}, point_a) }
    let(:point_c) { Ryo::BasicObject({z: 15}, point_b) }

    context "when an iteration yields true on point_a" do
      subject { Ryo.find(point_c) { _2 == 5 } }
      it { is_expected.to be(point_a) }
    end

    context "when an iteration yields true on point_b" do
      subject { Ryo.find(point_c) { _2 == 10 } }
      it { is_expected.to be(point_b) }
    end

    context "when an iteration yields true on point_c" do
      subject { Ryo.find(point_c) { _2 == 15 } }
      it { is_expected.to be(point_c) }
    end

    context "when an iteration never yields true" do
      subject { Ryo.find(point_c) { _2 == 20 } }
      it { is_expected.to eq(nil) }
    end

    context "with a depth of zero" do
      context "when the condition matches for point_a" do
        subject { Ryo.find(point_c, depth: 0) { _2 == 5 } }
        it { is_expected.to be_nil}
      end

      context "when the condition matches for point_b" do
        subject { Ryo.find(point_c, depth: 0) { _2 == 10 } }
        it { is_expected.to be_nil }
      end

      context "when the condition matches for point_c" do
        subject { Ryo.find(point_c, depth: 0) { _2 == 15 } }
        it { is_expected.to be(point_c) }
      end
    end

    context "with a depth of one" do
      context "when the condition matches for point_a" do
        subject { Ryo.find(point_c, depth: 1) { _2 == 5 } }
        it { is_expected.to be_nil}
      end

      context "when the condition matches for point_b" do
        subject { Ryo.find(point_c, depth: 1) { _2 == 10 } }
        it { is_expected.to be(point_b) }
      end

      context "when the condition matches for point_c" do
        subject { Ryo.find(point_c, depth: 1) { _2 == 15 } }
        it { is_expected.to be(point_c) }
      end
    end

    context "with a depth of two" do
      context "when the condition matches for point_a" do
        subject { Ryo.find(point_c, depth: 2) { _2 == 5 } }
        it { is_expected.to be(point_a) }
      end

      context "when the condition matches for point_b" do
        subject { Ryo.find(point_c, depth: 2) { _2 == 10 } }
        it { is_expected.to be(point_b) }
      end

      context "when the condition matches for point_c" do
        subject { Ryo.find(point_c, depth: 2) { _2 == 15 } }
        it { is_expected.to be(point_c) }
      end
    end

    context "with a depth of three (or higher)" do
      context "when the condition matches for point_a" do
        subject { Ryo.find(point_c, depth: 3) { _2 == 5 } }
        it { is_expected.to be(point_a) }
      end

      context "when the condition matches for point_b" do
        subject { Ryo.find(point_c, depth: 3) { _2 == 10 } }
        it { is_expected.to be(point_b) }
      end

      context "when the condition matches for point_c" do
        subject { Ryo.find(point_c, depth: 3) { _2 == 15 } }
        it { is_expected.to be(point_c) }
      end
    end
  end
end
