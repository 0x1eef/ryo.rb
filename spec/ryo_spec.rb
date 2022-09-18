# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo do
  describe ".set_prototype_of" do
    context "when the prototype of point is changed to point_2" do
      subject { point.y }
      let(:point_1) { Ryo(x: 0, y: 0) }
      let(:point_2) { Ryo(y: 5) }
      let(:point) { Ryo({}, point_1) }

      before { Ryo.set_prototype_of(point, point_2) }
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
    let(:point_1) { Ryo(x: 0, y: 0) }
    let(:point_2) { Ryo(y: 10) }

    context "when point_2 is assigned to point_1" do
      subject { Ryo.assign(point_1, point_2) }
      it { is_expected.to eq("x" => 0, "y" => 10) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end

    context "when a Ryo object and Hash object are assigned to point_1" do
      subject { Ryo.assign(point_1, point_2, {move: fn}) }
      let(:fn) { Ryo.fn {} }
      it { is_expected.to eq("x" => 0, "y" => 10, "move" => fn) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end
  end

  describe ".properties_of" do
    context "when requesting the properties of an object with a prototype" do
      subject { Ryo.properties_of(point) }
      let(:point_x) { Ryo(x: 0) }
      let(:point) { Ryo({y: 0}, point_x) }
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
    context "when given a set of nested Hash objects" do
      subject { coords.points.point.x.int }
      let(:coords) { Ryo.from(points: {point: {x: {int: 4}}}) }
      it { is_expected.to eq(4) }
    end

    context "when given a Hash nested in an Array" do
      subject { coords.points[0].x.int }
      let(:coords) { Ryo.from(points: [{x: {int: 4}}]) }
      it { is_expected.to eq(4) }
    end

    context "when given an Array that contains Hash objects" do
      context "when given one Hash object" do
        subject { coords[0].point.x.int }
        let(:coords) { Ryo.from([{point: {x: {int: 4}}}]) }
        it { is_expected.to eq(4) }
      end

      context "when given two Hash objects" do
        subject { coords.map { _1.point.x.int } }
        let(:coords) { Ryo.from([{point: {x: {int: 4}}}, {point: {x: {int: 3}}}]) }
        it { is_expected.to eq([4, 3]) }
      end

      context "when given a mix of Hash objects and other objects" do
        subject { coords.map { Ryo === _1 ? _1.point.x.int : _1 } }
        let(:coords) { Ryo.from([{point: {x: {int: 4}}}, "foo"]) }
        it { is_expected.to eq([4, "foo"]) }
      end

      context "when given a mix of Hash objects, and Ryo objects" do
        subject { coords.map(&:x) }
        let(:coords) { Ryo.from([{x: 1}, Ryo::BasicObject(x: 2)]) }
        it { is_expected.to eq([1, 2]) }
      end

      context "when given an object that implements #each but not #each_pair" do
        subject { Ryo.from(each_obj.new).map { Ryo === _1 ? _1.point.x.int : _1 } }
        let(:each_obj) do
          Class.new {
            def each
              arr = [{point: {x: {int: 4}}}, "foo"]
              arr.each { yield(_1) }
            end
          }
        end
        it { is_expected.to eq([4, "foo"]) }
      end
    end

    context "when given an object that does implement #each / #each_pair" do
      subject(:from) { Ryo.from(Object.new) }
      it { expect { from }.to raise_error(TypeError, %r{does not implement #each / #each_pair}) }
    end
  end

  describe "clone" do
    subject(:clone) { Ryo.clone(point) }
    let(:point_x) { Ryo::BasicObject(x: 1) }
    let(:point_y) { Ryo::BasicObject({y: 2}, point_x) }
    let(:point) { Ryo::BasicObject({}, point_y) }

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
