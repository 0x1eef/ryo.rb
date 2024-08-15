# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo::Keywords do
  describe ".function" do
    let(:point) { Ryo(move: Ryo.fn { |x, y| [x, y] }) }

    context "when the function requires argument(s)" do
      context "when the required argument is not given" do
        subject { point.move.() }
        it { expect { is_expected }.to raise_error(ArgumentError) }
      end

      context "when the required argument is given" do
        subject { point.move.(30, 50) }
        it { is_expected.to eq([30, 50]) }
      end
    end

    context "when the function receives a block" do
      subject { point.move.() { "block" } }
      let(:point) { Ryo(move: Ryo.fn { |&b| b.() }) }
      it { is_expected.to eq("block") }
    end
  end

  describe ".delete" do
    let(:point_a) { Ryo(x: 0) }
    let(:point_b) { Ryo({x: 1}, point_a) }

    context "with no prototype" do
      context "when a property is deleted" do
        subject { point_a.x }
        before { Ryo.delete(point_a, "x") }
        it { is_expected.to be_nil }
      end
    end

    context "with a prototype" do
      context "when a property is deleted from point_a" do
        subject { point_b.x }
        before { Ryo.delete(point_a, "x") }
        it { is_expected.to eq(1) }
      end

      context "when a property is deleted from point_b" do
        subject { point_b.x }
        before { Ryo.delete(point_b, "x") }
        it { is_expected.to eq(nil) }
      end

      context "when a property is deleted from both point_a / point_b" do
        subject { point_b.x }
        before { [point_a, point_b].each { Ryo.delete(_1, "x") } }
        it { is_expected.to be(nil) }
      end
    end
  end

  describe ".in?" do
    let(:point_a) { Ryo(x: 0) }
    let(:point_b) { Ryo({y: 1}, point_a) }
    let(:point_c) { Ryo({z: 2}, point_b) }

    context "when given 'x' as a property name" do
      subject { Ryo.in?(point_c, "x") }
      it { is_expected.to be(true) }
    end

    context "when given 'y' as a property name" do
      subject { Ryo.in?(point_c, "y") }
      it { is_expected.to be(true) }
    end

    context "when given 'z' as a property name" do
      subject { Ryo.in?(point_c, "z") }
      it { is_expected.to be(true) }
    end

    context "when given 'w' as a property name" do
      subject { Ryo.in?(point_c, "w") }
      it { is_expected.to be(false) }
    end
  end
end
