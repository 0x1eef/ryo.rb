# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo do
  describe ".set_prototype_of" do
    context "when the prototype of point is changed to point_b" do
      subject { point_c.y }
      let(:point_a) { Ryo(x: 0, y: 0) }
      let(:point_b) { Ryo(y: 5) }
      let(:point_c) { Ryo({}, point_a) }

      before { Ryo.set_prototype_of(point_c, point_b) }
      it { is_expected.to eq(5) }
    end
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

  describe ".assign" do
    let(:point_a) { Ryo(x: 0, y: 0) }
    let(:point_b) { Ryo(y: 10) }

    context "when point_b is assigned to point_a" do
      subject { Ryo.assign(point_a, point_b) }
      it { is_expected.to eq("x" => 0, "y" => 10) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end

    context "when a Ryo object and Hash object are assigned to point_a" do
      subject { Ryo.assign(point_a, point_b, {move: fn}) }
      let(:fn) { Ryo.fn {} }
      it { is_expected.to eq("x" => 0, "y" => 10, "move" => fn) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end
  end

  describe ".properties_of" do
    context "when verifying properties of the prototype (point_a) aren't included" do
      subject { Ryo.properties_of(point_b) }
      let(:point_a) { Ryo(x: 0) }
      let(:point_b) { Ryo({y: 0}, point_a) }
      it { is_expected.to eq(["y"]) }
    end
  end

  describe ".delete" do
    let(:point) { Ryo(x: 0) }

    context "when a property is deleted" do
      subject { point.x }
      before { Ryo.delete(point, "x") }
      it { is_expected.to be_nil }
    end
  end

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

  describe ".from" do
    context "when given a nested Hash object" do
      subject { point.x.to_i }
      let(:point) { Ryo.from({x: {to_i: 4}}) }
      it { is_expected.to eq(4) }
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
        subject { ary.map { Ryo === _1 ? _1.x.to_i : _1 } }
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
      subject { ary.map { Ryo === _1 ? _1.x.to_i : _1 } }
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

  describe "dup" do
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

      context "when verifying the dup was mutated" do
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

  describe ".ryo?" do
    subject { Ryo.ryo?(object) }

    context "when given an instance of Ryo::BasicObject" do
      let(:object) { Ryo::BasicObject(x: 1, y: 1) }
      it { is_expected.to be(true) }
    end

    context "when given an instance of Ryo::Object" do
      let(:object) { Ryo::Object(x: 2, y: 2) }
      it { is_expected.to be(true) }
    end

    context "when given an instance of Object" do
      let(:object) { Object.new }
      it { is_expected.to be(false) }
    end

    context "when given an instance of Hash" do
      let(:object) { {} }
      it { is_expected.to be(false) }
    end
  end
end
