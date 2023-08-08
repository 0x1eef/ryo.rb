# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo do
  describe ".from" do
    context "when given an instance of Ryo::Object" do
      subject { Ryo.from(point) }
      let(:point) { Ryo(x: 5, y: 10) }
      it { is_expected.to eq(point) }
    end

    context "when given { key => Hash<Symbol, Integer> }" do
      subject { point.x.to_i }
      let(:point) { Ryo.from({x: {to_i: 4}}) }
      it { is_expected.to eq(4) }
    end

    context "when given { key => Array<String> }" do
      subject { Ryo.from(key: %w[foo bar baz]) }
      it { is_expected.to be_instance_of(Ryo::Object) }
      it { is_expected.to eq("key" => %w[foo bar baz]) }
    end

    context "when given { key => Array<String, Ryo::BasicObject> }" do
      subject { Ryo.from(key: ["foo", point]) }
      let(:point) { Ryo::BasicObject(x: 0, y: 0) }
      it { is_expected.to be_instance_of(Ryo::Object) }
      it { is_expected.to eq("key" => ["foo", point]) }

      context "with equal?" do
        subject { super().key[-1] }
        it { is_expected.to be(point) }
      end
    end

    context "when given an Array that contains Hash objects" do
      context "when given one Hash object" do
        subject { ary[0].x.to_i }
        let(:ary) { Ryo.from([{x: {to_i: 4}}]) }
        it { is_expected.to eq(4) }
      end

      context "when given two Hash objects" do
        subject { ary.map { _1.x.to_i } }
        let(:ary) { Ryo.from([{x: {to_i: 4}}, {x: {to_i: 3}}]) }
        it { is_expected.to eq([4, 3]) }
      end

      context "when given a mix of Hash objects, and other objects" do
        subject { ary.map { (Ryo === _1) ? _1.x.to_i : _1 } }
        let(:ary) { Ryo.from([{x: {to_i: 4}}, "foo"]) }
        it { is_expected.to eq([4, "foo"]) }
      end

      context "when given a mix of Hash objects, and Ryo objects" do
        subject { ary.map(&:x) }
        let(:ary) { Ryo.from([{x: 1}, Ryo::BasicObject(x: 2)]) }
        it { is_expected.to eq([1, 2]) }
      end
    end

    context "when given an object that implements #each" do
      subject { ary.map { (Ryo === _1) ? _1.x.to_i : _1 } }
      let(:ary) do
        Ryo.from Class.new {
          def each
            arr = [{x: {to_i: 4}}, "foo"]
            arr.each { yield(_1) }
          end
        }.new
      end
      it { is_expected.to eq([4, "foo"]) }
    end

    context "when given an object that implements #each_pair" do
      subject { [point.x, point.y] }
      let(:point) do
        Ryo.from Class.new {
          def each_pair
            yield("x", 5)
            yield("y", 10)
          end
        }.new
      end
      it { is_expected.to eq([5, 10]) }
    end

    context "when given an object that doesn't implement #each or #each_pair" do
      subject(:from) { Ryo.from(Object.new) }
      it { expect { from }.to raise_error(TypeError, %r{does not implement #each / #each_pair}) }
    end
  end

  describe ".dup" do
    subject(:dup) { Ryo.dup(point_c) }
    let(:point_a) { Ryo::BasicObject(x: 1) }
    let(:point_b) { Ryo::BasicObject({y: 2}, point_a) }
    let(:point_c) { Ryo::BasicObject({}, point_b) }

    context "when the duplicate is mutated" do
      before { dup.x = 5 }

      context "when verifying the source wasn't mutated" do
        subject { point_c.x }
        it { is_expected.to eq(1) }
      end

      context "when verifying the duplicate was mutated" do
        subject { dup.x }
        it { is_expected.to eq(5) }
      end
    end

    context "when verifying the source and duplicate are distinct objects" do
      subject { Ryo.kernel(:equal?).bind_call(point_c, dup) }
      it { is_expected.to eq(false) }
    end

    context "when verifying the source and duplicate are eql?" do
      subject { point_c == dup }
      it { is_expected.to be(true) }
    end

    context "when verifying the prototype chain of the source and duplicate are eql?" do
      subject { Ryo.prototype_chain_of(point_c) == Ryo.prototype_chain_of(dup) }
      it { is_expected.to eq(true) }
    end
  end
end
